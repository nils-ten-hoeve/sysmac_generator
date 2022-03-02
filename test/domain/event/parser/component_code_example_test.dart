import 'package:petitparser/src/matcher/matches_skipping.dart';
import 'package:sysmac_generator/domain/event/parser/component_code.dart';
import 'package:test/test.dart';

import 'example.dart';


class ComponentCodeEventExample extends EventExample {

  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withExpression.withComponentCode.withMessage;

  @override
  String get explanation =>
      "{ImportDartDoc path='lib/domain/event/parser/component_code.dart|ComponentCode' }"
      ""
      "Each event should have a reference to a [ComponentCode] where possible."
      "A component code can be placed anywhere in a comment, but will be"
      "filtered out as a separate [ComponentCode] [Event] property."
      ""
      "Component codes are normally placed in the comments of the event "
      "structure that defines the EventGlobal Variable. "
      "You should not use component code in "
      "a structure of a library project, because this component "
      "code will be used in all the projects where it is used. "
      "Here use [IndirectComponentCode]'s instead.";

  @override
  Definition get definition => Definition()
    ..addStruct('sEvent')
    ..addEvent(
        dataTypeName: 'event1',
        dataTypeComment: '110s3 system air pressure too low',
        groupName1: 'Event1',
        message: 'System air pressure too low',
        componentCode: ComponentCode(site: site, electricPanel: electricPanel, pageNumber: 110, letters: 's', columnNumber: 3).toText());
}


main() {
  // var example = ComponentCodeEventExample();
  // group('class: $ComponentCodeEventExample', () {
  //   test('Correctly generated ${EventGroup}s', () {
  //     expect(example.generatedEventGroups, example.expectedEventGroups);
  //   });
  // });
  ComponentCodeEventExample().executeTest();

  group('$componentCodeParser', () {
    test("'123 30M2 456' has correct result", () {
      var result = componentCodeParser.matchesSkipping('123 30M2 456');
      expect(result[0],
          PartialComponentCode(pageNumber: 30, letters: 'M', columnNumber: 2));
    });
    test("'123 30m2 456' has correct result (capital case)", () {
      var result = componentCodeParser.matchesSkipping('123 30m2 456');
      expect(result[0],
          PartialComponentCode(pageNumber: 30, letters: 'M', columnNumber: 2));
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