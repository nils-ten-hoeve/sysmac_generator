import 'package:petitparser/src/matcher/matches_skipping.dart';
import 'package:sysmac_cmd/domain/base_type.dart';
import 'package:sysmac_cmd/domain/event/event.dart';
import 'package:sysmac_cmd/domain/event/parser/component_code.dart';
import 'package:sysmac_cmd/domain/variable.dart';
import 'package:test/test.dart';

import 'example.dart';

main() {
  group('$componentCodeParser', () {
    test("'123 30M2 456' has correct result", () {
      var result = componentCodeParser.matchesSkipping('123 30M2 456');
      expect(result[0],
          ComponentCode(pageNumber: 30, letters: 'M', columnNumber: 2));
    });
    test("'123 30m2 456' has correct result (capital case)", () {
      var result = componentCodeParser.matchesSkipping('123 30m2 456');
      expect(result[0],
          ComponentCode(pageNumber: 30, letters: 'M', columnNumber: 2));
    });
    test("'123 30M0 456' has no result (invalid column number)", () {
      var result = componentCodeParser.matchesSkipping('123 30M0 456');
      expect(result.isEmpty, true);
    });
    test("'123   30 M1    456' has no result (invalid space in between)", () {
      var result = componentCodeParser.matchesSkipping('123   30 M1    456');
      expect(result.isEmpty, true);
    });
  });
}

class EventComponentCodeExample extends EventExample {

  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withExpression.withComponentCode.withMessage;

  @override
  String get explanation =>
      "A component code can be placed anywhere in a comment. "
      "It will be filtered out and added to the component code "
      "field of the Event. Component codes are normaly placed in "
      "the comments of the event structure that defines the "
      "EventGlobal Variable. You should not use component code in "
      "a structure of a library project, because this component "
      "code will be used in all the projects where it is used. "
      "Here use [IndirectComponentCode]'s instead.";

  @override
  void testEventGroups(List<EventGroup> eventGroups) {
    // TODO: implement testEventGroups See above main
  }

  @override
  Definition get definition => Definition()
    ..addStruct('sEvent')
    ..addEvent(
        dataTypeName: 'event1',
        dataTypeComment: '110s3 system air pressure too low',
        groupName1: 'event1',
        message: 'System air pressure too low',
        componentCode: '110s3');
}
