import 'example.dart';

class EventGlobalExample extends EventExample {
  @override
  get title => 'EventGlobal';

  @override
  String get explanation => 'Events are defined in the EventGlobal variable. '
      'Each boolean in the EventGlobal variable structure is an event:';

  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withId.withExpression.withMessage;

  @override
  Definition createDefinition() => Definition()
    ..addStruct('Events')
    ..addEvent(
      dataTypeName: 'Event1',
      dataTypeComment: 'first event',
      groupName1: 'Event1',
      expression: 'EventGlobal.Event1',
      message: 'First event.',
    )
    ..addEvent(
      dataTypeName: 'Event2',
      dataTypeComment: 'second event',
      groupName1: 'Event2',
      expression: 'EventGlobal.Event2',
      message: 'Second event.',
    );
}

main() {
  EventGlobalExample().executeTest();
}
