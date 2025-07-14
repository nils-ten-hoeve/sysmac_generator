import 'package:petitparser/src/matcher/matches_skipping.dart';
import 'package:sysmac_generator/domain/event/parser/solution_parser.dart';
import 'package:test/test.dart';

import 'example.dart';

class EventSolutionExample extends EventExample {
  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withExpression.withMessage.withSolution;

  @override
  String get explanation =>
      "{ImportDartDoc path='lib/domain/event/parser/solution_parser.dart|$SolutionTag' }";

  @override
  Definition createDefinition() {
    var examples = 'Examples';

    return Definition()
      ..addStruct('Events')
      ..addStructReference(
        dataTypeName: examples,
        dataTypeExpression: examples,
      )
      ..goToRoot()
      ..addStruct(examples)
      ..addStructBool('Event1', 'information')
      ..addExpectedEvent(
        groupName1: examples,
        expression: 'EventGlobal.Examples.Event1',
        message: 'Information.',
      )
      ..addStructBool('Event2', '[20U1]motor over torque')
      ..addExpectedEvent(
        groupName1: examples,
        expression: 'EventGlobal.Examples.Event2',
        message: 'Motor over torque.',
        componentCode: '4321.DE06.20U1',
        solution:
            'See component 4321.DE06.20U1 on electric diagram 4321.DE06 on page 20 at column 1.',
      )
      ..addStructBool(
        'Event3',
        '[30S1]main panel emergency stop channel error [solution=Check the emergency stop button and wiring. Repair if needed. Then push and pull the emergency stop button and reset the safety system.]',
      )
      ..addExpectedEvent(
        groupName1: examples,
        expression: 'EventGlobal.Examples.Event3',
        message: 'Main panel emergency stop channel error.',
        componentCode: '4321.DE06.30S1',
        solution:
            'Check the emergency stop button and wiring. Repair if needed. Then push and pull the emergency stop button and reset the safety system. See component 4321.DE06.30S1 on electric diagram 4321.DE06 on page 30 at column 1.',
      );
  }
}

void main() {
  EventSolutionExample().executeTest();

  var parser = SolutionTagParser();
  group('$SolutionTagParser', () {
    group('Without spaces', () {
      var input1 = '1234[solution]5678';
      test("Parsing: '$input1' returns no results", () {
        var result = parser.matchesSkipping(input1);
        expect(result.isEmpty, true);
      });

      var input2 = '1234[solution=]5678';
      test("Parsing: '$input2' results in  a $SolutionTag containing ''", () {
        var result = parser.matchesSkipping(input2);
        expect(result[0], SolutionTag(''));
      });
      var input3 = '1234[solution=abc  def]5678';
      test("Parsing: '$input3' results in a $SolutionTag containing 'Abc def.'",
          () {
        var result = parser.matchesSkipping(input3);
        expect(result[0], SolutionTag('Abc def.'));
      });

      var input4 = '1234[SOLUTION=abc  def.]5678';
      test("Parsing: '$input4' results in a $SolutionTag containing 'Abc def.'",
          () {
        var result = parser.matchesSkipping(input4);
        expect(result[0], SolutionTag('Abc def.'));
      });
    });
    group('With spaces', () {
      var input1 = '1234[ solution ]5678';
      test("Parsing: '$input1' returns no results", () {
        var result = parser.matchesSkipping(input1);
        expect(result.isEmpty, true);
      });

      var input2 = '1234[ solution =   ]5678';
      test("Parsing: '$input2' results in  a $SolutionTag containing ''", () {
        var result = parser.matchesSkipping(input2);
        expect(result[0], SolutionTag(''));
      });
      var input3 = '1234[  solution = abc  def  ]5678';
      test("Parsing: '$input3' results in a $SolutionTag containing 'Abc def.'",
          () {
        var result = parser.matchesSkipping(input3);
        expect(result[0], SolutionTag('Abc def.'));
      });

      var input4 = '1234[  SOLUTION  =  abc  def.  ]5678';
      test("Parsing: '$input4' results in a $SolutionTag containing 'Abc def.'",
          () {
        var result = parser.matchesSkipping(input4);
        expect(result[0], SolutionTag('Abc def.'));
      });
    });
  });
}
