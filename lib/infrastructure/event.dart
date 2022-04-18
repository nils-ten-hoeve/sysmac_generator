import 'dart:developer';

import 'package:recase/recase.dart';
import 'package:sysmac_generator/domain/base_type.dart';
import 'package:sysmac_generator/domain/data_type.dart';
import 'package:sysmac_generator/domain/event/event.dart';
import 'package:sysmac_generator/domain/event/parser/acknowledge_parser.dart';
import 'package:sysmac_generator/domain/event/parser/component_code_parser.dart';
import 'package:sysmac_generator/domain/event/parser/derived_component_code_parser.dart';
import 'package:sysmac_generator/domain/event/parser/event_parser.dart';
import 'package:sysmac_generator/domain/event/parser/panel_nr_parser.dart';
import 'package:sysmac_generator/domain/event/parser/priority_parser.dart';
import 'package:sysmac_generator/domain/event/parser/site_nr_parser.dart';
import 'package:sysmac_generator/domain/event/parser/solution_parser.dart';
import 'package:sysmac_generator/domain/namespace.dart';
import 'package:sysmac_generator/domain/sysmac_project.dart';
import 'package:sysmac_generator/util/sentence.dart';

class EventService {
  final Site site;
  final ElectricPanel electricPanel;
  final List<NameSpace> eventGlobalVariables;

  EventService({
    required this.site,
    required this.electricPanel,
    required this.eventGlobalVariables,
  });

  List<EventGroup> get eventGroups => EventGroupFactory(this).create();
}

class EventGroupFactory {
  final EventService eventService;
  final EventCounter eventCounter = EventCounter();
  Set<String>? _cachedGroupNames;

  EventGroupFactory(this.eventService);

  List<EventGroup> create() {
    List<Event> allEvents = [];
    for (var eventGlobalVariable in eventService.eventGlobalVariables) {
      allEvents.addAll(EventFactory(this, eventGlobalVariable).createAll());
    }

    List<EventGroup> eventGroups = [];
    for (var groupName in groupNames) {
      var eventGroup = EventGroup(groupName);
      eventGroup.children
          .addAll(allEvents.where((event) => event.groupName1 == groupName));
      eventGroups.add(eventGroup);
    }
    return eventGroups;
  }

  Set<String> get groupNames {
    if (_cachedGroupNames == null) {
      List<String> allNames = [];
      for (var eventGlobalVariable in eventService.eventGlobalVariables) {
        allNames.addAll(eventGlobalVariable.children
            .map((eventGlobalVariableChild) =>
                eventGlobalVariableChild.name.titleCase)
            .toList());
      }

      allNames.sort((a, b) => a.compareTo(b));
      _cachedGroupNames =
          allNames.map((name) => _findUniqueName(name, allNames)).toSet();
    }
    return _cachedGroupNames!;
  }

  String _findUniqueName(String originalName, List<String> allNames) {
    var words = originalName.titleCase.split(' ');
    var uniqueName = originalName;
    var matches = _startingWithTheSame(allNames, originalName).length;
    while (words.isNotEmpty) {
      var nameCandidate = words.join(' ');
      var foundMatches = _startingWithTheSame(allNames, nameCandidate).length;
      if (foundMatches > matches) {
        matches = foundMatches;
        uniqueName = nameCandidate;
      }
      words.removeAt(words.length - 1);
    }
    return uniqueName;
  }

  Iterable<String> _startingWithTheSame(
          List<String> strings, String stringToMatch) =>
      strings.where((string) =>
          string.toLowerCase().startsWith(stringToMatch.toLowerCase()));
}

/// [EventFactory] wil recursively create all events of a EvenGlobalNode.
/// It will contain all information necessary such as array counters
class EventFactory {
  static final _eventTagsParser = EventTagsParser();
  final EventGroupFactory eventGroupFactory;
  final EventFactory? parentFactory;
  final NameSpace eventGlobalNode;

  EventFactory(
    this.eventGroupFactory,
    this.eventGlobalNode, [
    this.parentFactory,
  ]);

  List<NameSpace> get eventPath => parentFactory == null
      ? [eventGlobalNode]
      : [...parentFactory!.eventPath, eventGlobalNode];

  EventCounter get eventCounter => eventGroupFactory.eventCounter;

  /// Recursively creates all events of a eventGlobalNode.
  List<Event> createAll() {
    List<Event> events = [];
    //TODO arrays
    if (eventGlobalNode is DataType &&
        (eventGlobalNode as DataType).baseType is VbBoolean) {
      events.add(_createEvent());
    }

    for (var child in eventGlobalNode.children) {
      events.addAll(EventFactory(eventGroupFactory, child, this).createAll());
    }
    return events;
  }

  // List<List<NameSpace>> _createEventPaths(List<Variable> variables) {
  //   List<List<NameSpace>> eventPaths = [];
  //
  //   for (var variable in variables) {
  //     eventPaths.addAll(variable.findPaths((nameSpace) =>
  //     nameSpace is DataType &&
  //         nameSpace.baseType is VbBoolean &&
  //         nameSpace.children.isEmpty));
  //   }
  //
  //   _sortOnFirstDataTypeNames(eventPaths);
  //
  //   return eventPaths;
  // }

  Event _createEvent() {
    var parsedComments = _parseComments(eventPath);
    var eventTags = _findEventTags(parsedComments);
    var groupName1 = _findGroupName();
    var groupName2 = _findGroupName2(groupName1, eventPath);
    var priority = _findPriority(eventTags);
    var componentCode = _createComponentCode(eventTags, eventPath);
    var message = _createMessage(parsedComments);
    Event event = Event(
      groupName1: groupName1,
      groupName2: groupName2,
      id: eventCounter.next,
      componentCode: componentCode == null ? '' : componentCode.toCode(),
      expression: _createExpression(eventPath),
      priority: priority,
      message: message,
      solution: _findSolution(eventTags, componentCode),
      acknowledge: _findAcknowledge(eventTags, priority),
    );
    return event;
  }

  String _createExpression(List<NameSpace> eventPath) {
    List<NameSpace> filteredEventPath = eventPath
        .where((nameSpace) => nameSpace is! Site && nameSpace is! ElectricPanel)
        .toList();
    return filteredEventPath.map((nameSpace) => nameSpace.name).join('.');
  }

  List<EventTag> _findEventTags(List<dynamic> parsedComments) =>
      parsedComments.whereType<EventTag>().toList();

  String _joinComments(List<NameSpace> eventPath) {
    var joinedComments = '';
    for (var nameSpace in eventPath) {
      if (nameSpace is NameSpaceWithTypeAndComment) {
        if (joinedComments.isNotEmpty) {
          joinedComments += ' ';
        }
        joinedComments += nameSpace.comment;
        if (nameSpace.baseType is DataTypeReference) {
          var dataTypeReference = nameSpace.baseType as DataTypeReference;
          joinedComments += ' ' + dataTypeReference.dataType.comment;
        }
      }
    }
    return joinedComments;
  }

  List<dynamic> _parseComments(List<NameSpace> eventPath) {
    String joinedComments = _joinComments(eventPath);
    var result = _eventTagsParser.parse(joinedComments).value;

    result.insert(0, PanelNumberTag(electricPanel.number));
    result.insert(0, SiteNumberTag(site.number));
    return result;
  }

  ElectricPanel get electricPanel =>
      eventGroupFactory.eventService.electricPanel;

  Site get site => eventGroupFactory.eventService.site;

  String _createMessage(List parsedComments) =>
      Sentence.normalize(parsedComments.whereType<String>().join());

  ComponentCode? _createComponentCode(
      List<EventTag> eventTags, List<NameSpace> eventPath) {
    var componentCodeTag = _findComponentCodeTag(eventTags, eventPath);

    if (componentCodeTag == null) {
      return null;
    } else {
      return ComponentCode(
        site: Site(_findSiteNumberTag(eventTags).number),
        electricPanel: ElectricPanel(
            number: _findPanelNumberTag(eventTags).number,
            name: electricPanel.name),
        pageNumber: componentCodeTag.pageNumber,
        letters: componentCodeTag.letters,
        columnNumber: componentCodeTag.columnNumber,
      );
    }
  }

  PanelNumberTag _findPanelNumberTag(List<EventTag> eventTags) =>
      eventTags.whereType<PanelNumberTag>().last;

  SiteNumberTag _findSiteNumberTag(List<EventTag> eventTags) =>
      eventTags.whereType<SiteNumberTag>().last;

  EventPriority _findPriority(List<EventTag> eventTags) {
    var priorityTags = eventTags.whereType<PriorityTag>();
    if (priorityTags.isEmpty) {
      return EventPriorities.medium;
    } else {
      return priorityTags.last.priority;
    }
  }

  bool _findAcknowledge(List<EventTag> eventTags, EventPriority priority) {
    var acknowledgeTags = eventTags.whereType<AcknowledgeTag>();
    if (acknowledgeTags.isEmpty) {
      return priority != EventPriorities.info;
    } else {
      return acknowledgeTags.last.acknowledge;
    }
  }

  String _findGroupName2(
    String groupName1,
    List<NameSpace> eventPath,
  ) {
    var groupName2 = _createEventGroupName();
    if (groupName1 == groupName2) {
      return '';
    } else {
      return groupName2.substring(groupName1.length).trim();
    }
  }

  _findSolution(List<EventTag> eventTags, ComponentCode? componentCode) {
    var solutionTexts = eventTags
        .whereType<SolutionTag>()
        .map((solutionTag) => solutionTag.solution)
        .toList();
    if (componentCode != null) {
      solutionTexts.add(
          'See component ${componentCode.toCode()} on electric diagram ${componentCode.site.code}.${componentCode.electricPanel.code} on page ${componentCode.pageNumber} at column ${componentCode.columnNumber}.');
    }
    return solutionTexts.join(' ');
  }

  String _findGroupName() {
    var fullName = _createEventGroupName();
    var groupNames = eventGroupFactory.groupNames;
    return groupNames.firstWhere((groupName) => fullName.startsWith(groupName),
        orElse: () => '');
  }

  _eventPathString(List<NameSpace> eventPath) =>
      eventPath.map((nameSpace) => nameSpace.name).join('.');

  ComponentCodeTag? _findComponentCodeTag(
      List<EventTag> eventTags, List<NameSpace> eventPath) {
    var componentCodeTags = eventTags.whereType<ComponentCodeTag>().toList();
    var derivedComponentCodeTags =
        eventTags.whereType<DerivedComponentCodeTag>().toList();

    if (derivedComponentCodeTags.isEmpty) {
      if (componentCodeTags.isEmpty) {
        return null;
      } else {
        return componentCodeTags.first;
      }
    } else {
      return _createDerivedComponentCodeTag(
          derivedComponentCodeTags, eventPath, componentCodeTags);
    }
  }

  ComponentCodeTag? _createDerivedComponentCodeTag(
      List<DerivedComponentCodeTag> derivedComponentCodeTags,
      List<NameSpace> eventPath,
      List<ComponentCodeTag> componentCodeTags) {
    var derivedComponentCodeTag =
        _findDerivedComponentCode(derivedComponentCodeTags, eventPath);
    var componentCodeTagWithSameLetter = _findComponentCodeTagWithSameLetter(
        derivedComponentCodeTag, componentCodeTags, eventPath);
    if (componentCodeTagWithSameLetter == null) {
      return null;
    } else {
      return ComponentCodeTag(
          pageNumber: componentCodeTagWithSameLetter.pageNumber,
          letters: derivedComponentCodeTag.letters,
          columnNumber: componentCodeTagWithSameLetter.columnNumber);
    }
  }

  DerivedComponentCodeTag _findDerivedComponentCode(
      List<DerivedComponentCodeTag> derivedComponentCodeTags,
      List<NameSpace> eventPath) {
    if (derivedComponentCodeTags.length > 1) {
      log('The following event path contains more then 1 '
          '${DerivedComponentCodeTag}s: ${_eventPathString(eventPath)}');
    }
    return derivedComponentCodeTags.first;
  }

  ComponentCodeTag? _findComponentCodeTagWithSameLetter(
      DerivedComponentCodeTag derivedComponentCodeTag,
      List<ComponentCodeTag> componentCodeTags,
      List<NameSpace> eventPath) {
    if (componentCodeTags.isEmpty) {
      log('The following event path contains a $DerivedComponentCodeTag '
          'but no ${ComponentCodeTag}s": '
          '${_eventPathString(eventPath)}');
      return null;
    }

    var componentCodeTagsWithSameLetter = componentCodeTags
        .where((componentCodeTag) =>
            componentCodeTag.letters == derivedComponentCodeTag.letters)
        .toList();
    if (componentCodeTagsWithSameLetter.isEmpty) {
      return componentCodeTags.first;
    }

    var index = derivedComponentCodeTag.indexNumber;
    if (index < 1) {
      log('The following event path contains a $DerivedComponentCodeTag '
          'with an indexNumber <1: ${_eventPathString(eventPath)}');
      return componentCodeTagsWithSameLetter.first;
    }
    if (index > componentCodeTagsWithSameLetter.length) {
      log('The following event path contains a $DerivedComponentCodeTag '
          'with indexNumber > the number of ${ComponentCodeTag}s '
          'with the same letter: ${_eventPathString(eventPath)}');
      return componentCodeTags.first;
    }
    return componentCodeTagsWithSameLetter[index - 1];
  }

  String _createEventGroupName() => eventPath.length == 1
      ? eventPath[0].name.titleCase
      : eventPath[1].name.titleCase;
}

class EventCounter {
  int value = 1;

  String get next => (value++).toString();
}
