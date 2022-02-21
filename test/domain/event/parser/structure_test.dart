import 'package:sysmac_cmd/domain/event/event.dart';
import 'package:test/test.dart';

import 'example.dart';

class EventStructureExample extends EventExample {
  // @override
  // Variable get eventGlobalVariable {
  //   DataType sEvent = DataType(name: 'sEvent', baseType: Struct(), comment: '');
  //   DataType group = DataType(name: 'group', baseType: Struct(), comment: '');
  //   sEvent.children.add(group);
  //   group.children.add(DataType(
  //       name: 'event1', baseType: VbBoolean(), comment: 'first event'));
  //   group.children.add(DataType(
  //       name: 'event2', baseType: VbBoolean(), comment: 'second event'));
  //   return Variable(
  //       name: 'EventGlobal',
  //       comment: '',
  //       baseType: DataTypeReference(sEvent, []));
  // }

  @override
  String get explanation => 'Events are defined in the EventGlobal variable. '
      'Each boolean in the EventGlobal variable structure is an event:';

  @override
  void testEventGroups(List<EventGroup> eventGroups) {
    expect(eventGroups.length, 1);
    expect(eventGroups.first.children.length, 2);
  }

  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withExpression.withMessage;

  @override
  Definition get definition => Definition()
    ..addStruct('sEvent')
    ..addEvent(
      dataTypeName: 'event1',
      dataTypeComment: 'first event',
      groupName1: 'event1',
      message: 'First event',
    )
    ..addEvent(
      dataTypeName: 'event2',
      dataTypeComment: 'second event',
      groupName1: 'event2',
      message: 'Second event',
    );
}

main() {
  EventStructureExample().writeMarkDownTemplateFile();
  EventStructureExample().test();
}
