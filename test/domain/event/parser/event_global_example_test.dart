
import 'example.dart';

class EventGlobalEventExample extends EventExample {
  @override
  String get explanation => 'Events are defined in the EventGlobal variable. '
      'Each boolean in the EventGlobal variable structure is an event:';

  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withId.withExpression.withMessage;

  @override
  Definition get definition => Definition()
    ..addStruct('sEvent')
    ..addEvent(
      dataTypeName: 'event1',
      dataTypeComment: 'first event',
      groupName1: 'Event1',
      message: 'First event',
    )
    ..addEvent(
      dataTypeName: 'event2',
      dataTypeComment: 'second event',
      groupName1: 'Event2',
      message: 'Second event',
    );
}

main() {
  // var example = BasicEventExample();
  // group('class: $BasicEventExample', () {
  //   test('Correctly generated ${EventGroup}s', () {
  //     expect(example.generatedEventGroups, example.expectedEventGroups);
  //   });
  // });
  EventGlobalEventExample().executeTest();
}
