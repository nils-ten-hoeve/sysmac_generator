import 'package:sysmac_cmd/domain/base_type.dart';
import 'package:sysmac_cmd/domain/data_type.dart';
import 'package:sysmac_cmd/domain/event.dart';
import 'package:sysmac_cmd/domain/namespace.dart';
import 'package:sysmac_cmd/domain/variable.dart';
import 'package:sysmac_cmd/infrastructure/variable.dart';

class EventService {
  final GlobalVariableService globalVariableService;

  EventService(this.globalVariableService);

  List<EventGroup> createFromVariable(List<Variable> variables) {
    List<List<NameSpace>> eventPaths = _createEventPaths();

    List<EventGroup> eventGroups = [];
    EventCounter eventCounter = EventCounter();
    for (var eventPath in eventPaths) {
      if (_newEventGroup(eventGroups, eventPath)) {
        EventGroup eventGroup = EventGroup(eventPath[1].name);
        eventGroups.add(eventGroup);
      }
      EventGroup eventGroup = eventGroups.last;
      eventGroup.children
          .addAll(_createEvents(eventGroup, eventPath, eventCounter));
    }

    for (var group in eventGroups) {
      print(group);//TODO remove after test
    }

    return eventGroups;
  }

  bool _newEventGroup(List<EventGroup> eventGroups, List<NameSpace> eventPath) {
    return eventGroups.isEmpty ||
        !eventPath[1]
            .name
            .toLowerCase()
            .startsWith(eventGroups.last.name.toLowerCase());
  }

  List<List<NameSpace>> _createEventPaths() {
    List<List<NameSpace>> eventPaths = [];

    var eventGlobalVariables =
        globalVariableService.findVariablesWithEventGlobalName();

    for (var eventGlobalVariable in eventGlobalVariables) {
      eventPaths.addAll(eventGlobalVariable.findPaths((nameSpace) =>
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
    String groupName1 = eventGroup.name;
    String groupName2 =  groupName1==eventPath[1].name?'':eventPath[1].name;
    String id = eventCounter.next;
    String componentCode = ''; //TODO
    String expression =
        eventPath.map((nameSpace) => nameSpace.name).join('.'); //TODO arrays;
    EventPriority priority = EventPriorities().first; //TODO
    String message = eventPath
        .map((nameSpace) => (nameSpace is DataType) ? nameSpace.comment : '')
        .join(
            ' '); //TODO message only (no meta), ensure correct use of letter case and remove double spaces and
    String explanation = ''; //TODO
    bool popup = false; //TODO
    bool acknowledge = false; //TODO
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
}

class EventCounter {
  int value = 0;

  String get next => (value++).toString();
}
