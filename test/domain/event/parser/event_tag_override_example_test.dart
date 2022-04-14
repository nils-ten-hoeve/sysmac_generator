import 'package:sysmac_generator/domain/event/event.dart';

import 'example.dart';

class EventTagOverrideExample extends EventExample {
  @override
  String get explanation =>
      'You can override EventTags. This means that tags in comments of '
      'higher structure members can be undone by tags in the comments '
      'of lower structure members.';

  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withId.withExpression.withPriority.withAcknowledge;

  @override
  Definition createDefinition() => Definition()
    ..variableComment = '[ack=false]'
    ..addStruct('Events', '[prio=info]')
    ..addStructBool(
      dataTypeName: 'Event1',
      dataTypeComment: '',
    )
    ..addStructBool(
      dataTypeName: 'Event2',
      dataTypeComment: '[ack]',
    )
    ..addStructBool(
      dataTypeName: 'Event3',
      dataTypeComment: '[prio=critical]',
    )
    ..addExpectedEvent(
      groupName1: 'Event1',
      expression: 'EventGlobal.Event1',
      message: '',
      priority: EventPriorities.info,
      acknowledge: false,
    )
    ..addExpectedEvent(
      groupName1: 'Event2',
      expression: 'EventGlobal.Event2',
      message: '',
      priority: EventPriorities.info,
      acknowledge: true,
    )
    ..addExpectedEvent(
      groupName1: 'Event3',
      expression: 'EventGlobal.Event3',
      message: '',
      priority: EventPriorities.critical,
      acknowledge: false,
    );
}

main() {
  EventTagOverrideExample().executeTest();
}
