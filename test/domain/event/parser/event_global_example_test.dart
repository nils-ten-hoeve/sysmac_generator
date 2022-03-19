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
    ..addStruct('sEvent')
    ..addEvent(
      dataTypeName: 'event1',
      dataTypeComment: 'first event',
      groupName1: 'Event1',
      expression: 'EventGlobal.event1',
      message: 'First event',
    )
    ..addEvent(
      dataTypeName: 'event2',
      dataTypeComment: 'second event',
      groupName1: 'Event2',
      expression: 'EventGlobal.event2',
      message: 'Second event',
    );
}

main() {
  EventGlobalExample().executeTest();
}
