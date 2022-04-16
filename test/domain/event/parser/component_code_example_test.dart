import 'package:petitparser/src/matcher/matches_skipping.dart';
import 'package:sysmac_generator/domain/event/parser/component_code_parser.dart';
import 'package:test/test.dart';

import 'example.dart';

class EventComponentCodeExample extends EventExample {
  @override
  bool get showSysmacFileNameTable => true;

  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withExpression.withComponentCode.withMessage;

  @override
  String get explanation =>
      "{ImportDartDoc path='lib/domain/event/parser/component_code_parser.dart|$ComponentCode' }"
      "\n\n"
      "{ImportDartDoc path='lib/domain/event/parser/component_code_parser.dart|$ComponentCodeTag' }";

  @override
  Definition createDefinition() => Definition()
    ..addStruct('Events')
    ..addStructBool('Event1', '[110s3] system air pressure too low')
    ..addExpectedEvent(
      groupName1: 'Event1',
      expression: 'EventGlobal.Event1',
      message: 'System air pressure too low.',
      componentCode: ComponentCode(
        site: site,
        electricPanel: electricPanel,
        pageNumber: 110,
        letters: 's',
        columnNumber: 3,
      ).toCode(),
      solution:
          'See component 4321.DE06.110S3 on electric diagram 4321.DE06 on page 110 at column 3.',
    );
}

main() {
  EventComponentCodeExample().executeTest();

  var componentCodeTagParser = ComponentCodeTagParser();
  group('$ComponentCodeTagParser', () {
    test("'123 [30M2] 456' has correct result", () {
      var result = componentCodeTagParser.matchesSkipping('123 [30M2] 456');
      expect(result[0],
          ComponentCodeTag(pageNumber: 30, letters: 'M', columnNumber: 2));
    });
    test("'123 [ 30M2] 456' has correct result", () {
      var result = componentCodeTagParser.matchesSkipping('123 [ 30M2] 456');
      expect(result[0],
          ComponentCodeTag(pageNumber: 30, letters: 'M', columnNumber: 2));
    });
    test("'123 [30M2 ] 456' has correct result", () {
      var result = componentCodeTagParser.matchesSkipping('123 [30M2 ] 456');
      expect(result[0],
          ComponentCodeTag(pageNumber: 30, letters: 'M', columnNumber: 2));
    });
    test("'123 [30m2] 456' has correct result (capital case)", () {
      var result = componentCodeTagParser.matchesSkipping('123 [30m2] 456');
      expect(result[0],
          ComponentCodeTag(pageNumber: 30, letters: 'M', columnNumber: 2));
    });
    test("'123 [30M0] 456' has no result (invalid column number)", () {
      var result = componentCodeTagParser.matchesSkipping('123 [30M0] 456');
      expect(result.isEmpty, true);
    });
    test("'123   [30 M1]    456' has no result (invalid space in between)", () {
      var result =
          componentCodeTagParser.matchesSkipping('123   [30 M1]    456');
      expect(result.isEmpty, true);
    });
  });
}
