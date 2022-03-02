import 'package:recase/recase.dart';
import 'package:sysmac_generator/domain/base_type.dart';
import 'package:sysmac_generator/domain/data_type.dart';
import 'package:sysmac_generator/domain/event/event.dart';
import 'package:sysmac_generator/domain/event/parser/component_code.dart';
import 'package:sysmac_generator/domain/event/parser/event.dart';
import 'package:sysmac_generator/domain/namespace.dart';
import 'package:sysmac_generator/domain/sysmac_project.dart';
import 'package:sysmac_generator/domain/variable.dart';

class EventService {
  // final GlobalVariableService globalVariableService;

  final Site site;
  final ElectricPanel electricPanel;
  static final _groupNameIndex = 1;

  EventService({required this.site, required this.electricPanel});

  List<EventGroup> createFromVariable(List<Variable> variables) {
    List<List<NameSpace>> eventPaths = _createEventPaths(variables);

    List<EventGroup> eventGroups = [];
    EventCounter eventCounter = EventCounter();
    for (var eventPath in eventPaths) {
      if (_newEventGroup(eventGroups, eventPath)) {
        EventGroup eventGroup =
            EventGroup(eventPath[_groupNameIndex].name.titleCase);
        eventGroups.add(eventGroup);
      }
      EventGroup eventGroup = eventGroups.last;
      eventGroup.children
          .addAll(_createEvents(eventGroup, eventPath, eventCounter));
    }

    return eventGroups;
  }

  bool _newEventGroup(List<EventGroup> eventGroups, List<NameSpace> eventPath) {
    return eventGroups.isEmpty ||
        !eventPath[_groupNameIndex]
            .name
            .toLowerCase()
            .startsWith(eventGroups.last.name.toLowerCase());
  }

  List<List<NameSpace>> _createEventPaths(List<Variable> variables) {
    List<List<NameSpace>> eventPaths = [];

    for (var variable in variables) {
      eventPaths.addAll(variable.findPaths((nameSpace) =>
          nameSpace is DataType &&
          nameSpace.baseType is VbBoolean &&
          nameSpace.children.isEmpty));
    }

    _sortOnFirstDataTypeNames(eventPaths);

    return eventPaths;
  }

  /// Sort on the name of the first [DataType] members of the EventGlobal variable
  void _sortOnFirstDataTypeNames(List<List<NameSpace>> eventPaths) {
    eventPaths.sort((a, b) => a[1].name.compareTo(b[1].name));
  }

  List<Event> _createEvents(EventGroup eventGroup, List<NameSpace> eventPath,
      EventCounter eventCounter) {
    String expression = _createExpression(eventPath);
    var parsedComments = _parseComments(eventPath);
    var metaData = _findMetaData(parsedComments);

    String groupName1 = eventGroup.name;
    String groupName2 = eventPath[_groupNameIndex].name.titleCase;
    if (groupName1 == groupName2) {
      groupName2 = '';
    }
    String id = eventCounter.next;
    String componentCode = _findComponentCode(metaData);

    String message = _findMessage(parsedComments);
    String explanation = ''; //TODO
    bool popup = false; //TODO
    bool acknowledge = false; //TODO
    EventPriority priority = EventPriorities.medium; //TODO

    Event event = Event(
      groupName1: groupName1,
      groupName2: groupName2,
      id: id,
      componentCode: componentCode,
      expression: expression,
      priority: priority,
      message: message,
      explanation: explanation,
      popup: popup,
      acknowledge: acknowledge,
    );
    return [
      event
    ]; //TODO return multiple events if eventPath contains DataTypes with baseType.array!=null
  }

  String _createExpression(List<NameSpace> eventPath) {
    List<NameSpace> filteredEventPath = eventPath
        .where((nameSpace) => nameSpace is! Site && nameSpace is! ElectricPanel)
        .toList();
    return filteredEventPath.map((nameSpace) => nameSpace.name).join('.');
  }

  List<dynamic> _findMetaData(List<dynamic> parsedComments) => parsedComments
      .where((parsedComment) => parsedComments is! String)
      .toList();

  //TODO Add to documentation: start with lowe case letters! First letter will be changed to upper case
  String _joinComments(List<NameSpace> eventPath) => eventPath
      .map((nameSpace) =>
          (nameSpace is NameSpaceWithComment) ? nameSpace.comment : '')
      .join(' ');

  List<dynamic> _parseComments(List<NameSpace> eventPath) {
    String joinedComments = _joinComments(eventPath);
    var result= eventParser.parse(joinedComments).value;
    result.insert(0, electricPanel);
    result.insert(0, site);
    return result;
  }

  String _findMessage(List parsedComments) => _upperCaseFirstLetter(
      parsedComments.whereType<String>().join().trim().replaceAll('  ', ' '));

  String _upperCaseFirstLetter(String trimmedSentence) {
    if (trimmedSentence.isEmpty) {
      return trimmedSentence;
    } else if (trimmedSentence.length == 1) {
      return trimmedSentence.substring(0, 1).toUpperCase();
    } else {
      return trimmedSentence.substring(0, 1).toUpperCase() +
          trimmedSentence.substring(1);
    }
  }

  String _findComponentCode(List<dynamic> metaData) {
    var partialComponentCodes =
        metaData.whereType<PartialComponentCode>().toList();
    if (partialComponentCodes.isNotEmpty) {
      var partialComponentCode = partialComponentCodes.first;
      return ComponentCode(
        site: _findSite(metaData),
        electricPanel: _findElectricPanel(metaData),
        pageNumber: partialComponentCode.pageNumber,
        letters: partialComponentCode.letters,
        columnNumber: partialComponentCode.columnNumber,
      ).toText();
    }
    return partialComponentCodes.isEmpty
        ? ''
        : partialComponentCodes.first.toText();
  }

  ElectricPanel _findElectricPanel(List<dynamic> metaData) =>
      metaData.whereType<ElectricPanel>().last;

  Site _findSite(List<dynamic> metaData) => metaData.whereType<Site>().last;

}

class EventCounter {
  int value = 1;

  String get next => (value++).toString();
}
