import 'package:collection/collection.dart';
import 'package:petitparser/src/matcher/matches_skipping.dart';
import 'package:recase/recase.dart';
import 'package:sysmac_generator/domain/event/event.dart';
import 'package:sysmac_generator/domain/event/parser/priority_parser.dart';
import 'package:test/test.dart';

import 'example.dart';

class EventPriorityExample extends EventExample {
  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withExpression.withMessage.withPriority;

  @override
  String get explanation =>
      'Each [Event] has a priority so that the operator can see the [Event]s in order of importance. Meyn has defined the following priorities:\n\n'
      '${EventPriorities().asMarkDown}'
      '\n\n'
      "{ImportDartDoc path='lib/domain/event/parser/priority_parser.dart|$PriorityTag' }";

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
      ..addStructBool('EthercatError', '[prio=f]etherCAT error')
      ..addExpectedEvent(
        groupName1: examples,
        expression: 'EventGlobal.Examples.EthercatError',
        priority: EventPriorities.fatal,
        message: 'EtherCAT error.',
      )
      ..addStructBool(
          'EmergencyStopButton', '[Priority=Critical]emergency button pressed')
      ..addExpectedEvent(
        groupName1: examples,
        expression: 'EventGlobal.Examples.EmergencyStopButton',
        priority: EventPriorities.critical,
        message: 'Emergency button pressed.',
      )
      ..addStructBool('PumpMotorTripped', '[priority=h]pump motor tripped')
      ..addExpectedEvent(
        groupName1: examples,
        expression: 'EventGlobal.Examples.PumpMotorTripped',
        priority: EventPriorities.high,
        message: 'Pump motor tripped.',
      )
      ..addStructBool(
          'ScalderTemperatureTooHigh', 'scalder temperature too high')
      ..addExpectedEvent(
        groupName1: examples,
        expression: 'EventGlobal.Examples.ScalderTemperatureTooHigh',
        priority: EventPriorities.medium,
        message: 'Scalder temperature too high.',
      )
      ..addStructBool('PluckerMotorTripped', '[prio=LOW]plucker motor tripped')
      ..addExpectedEvent(
        groupName1: examples,
        expression: 'EventGlobal.Examples.PluckerMotorTripped',
        priority: EventPriorities.low,
        message: 'Plucker motor tripped.',
      )
      ..addStructBool('LineStopButton', '[PRIO = I]line stop button pressed')
      ..addExpectedEvent(
        groupName1: examples,
        expression: 'EventGlobal.Examples.LineStopButton',
        priority: EventPriorities.info,
        message: 'Line stop button pressed.',
        acknowledge: false,
      );
  }
}

class PriorityTextFactories
    extends DelegatingList<String Function(EventPriorityOld priority)> {
  PriorityTextFactories()
      : super([
          (priority) => priority.abbreviation.toLowerCase(),
          (priority) => priority.abbreviation.toUpperCase(),
          (priority) => priority.name,
          (priority) => priority.name.toLowerCase(),
          (priority) => priority.name.toUpperCase(),
          (priority) => priority.name.pascalCase,
          (priority) => priority.name.pascalCase.toLowerCase(),
          (priority) => priority.name.pascalCase.toUpperCase(),
        ]);
}

void main() {
  EventPriorityExample().executeTest();

  var parser = PriorityTagParser();
  group('$PriorityTagParser', () {
    for (var priority in EventPriorities()) {
      for (var priorityTextFactory in PriorityTextFactories()) {
        var priorityText = priorityTextFactory(priority);
        var priorityTitle = '$EventPriorityOld.${priority.name.pascalCase}';

        group("Parsing $EventPriorityOld: '$priorityText'", () {
          group('Without spaces', () {
            var input1 = '1234[prio=$priorityText]5678';
            test("Parsing: '$input1' results in $priorityTitle", () {
              var result = parser.matchesSkipping(input1);
              expect(result[0], PriorityTag(priority));
            });

            var input2 = '1234[priority=$priorityText]5678';
            test("Parsing: '$input2' results in $priorityTitle", () {
              var result = parser.matchesSkipping(input2);
              expect(result[0], PriorityTag(priority));
            });

            var input3 = '1234[PRIO=$priorityText]5678';
            test("Parsing: '$input3' results in $priorityTitle", () {
              var result = parser.matchesSkipping(input3);
              expect(result[0], PriorityTag(priority));
            });

            var input4 = '1234[PRIORITY=$priorityText]5678';
            test("Parsing: '$input4' results in $priorityTitle", () {
              var result = parser.matchesSkipping(input4);
              expect(result[0], PriorityTag(priority));
            });
          });

          group('With spaces', () {
            var input1 = '1234[  prio = $priorityText  ]5678';
            test("Parsing: '$input1' results in $priorityTitle", () {
              var result = parser.matchesSkipping(input1);
              expect(result[0], PriorityTag(priority));
            });

            var input2 = '1234[ priority  =  $priorityText ]5678';
            test("Parsing: '$input2' results in $priorityTitle", () {
              var result = parser.matchesSkipping(input2);
              expect(result[0], PriorityTag(priority));
            });

            var input3 = '1234[ PRIO = $priorityText]5678';
            test("Parsing: '$input3' results in $priorityTitle", () {
              var result = parser.matchesSkipping(input3);
              expect(result[0], PriorityTag(priority));
            });

            var input4 = '1234[PRIORITY  =  $priorityText  ]5678';
            test("Parsing: '$input4' results in $priorityTitle", () {
              var result = parser.matchesSkipping(input4);
              expect(result[0], PriorityTag(priority));
            });
          });
        });
      }
    }
  });
}
