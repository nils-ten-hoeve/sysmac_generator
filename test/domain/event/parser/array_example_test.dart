import 'package:recase/recase.dart';
import 'package:sysmac_generator/domain/base_type.dart';
import 'package:sysmac_generator/infrastructure/event.dart';
import 'package:sysmac_generator/infrastructure/variable.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'example.dart';

class EventArrayExample extends EventExample {
  @override
  bool get showSysmacFileNameTable => false;

  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withExpression.withGroupName1.withMessage;

  @override
  String get explanation =>
      "You can use arrays in the structure of the $eventGlobalVariableName.";

  @override
  Definition createDefinition() {
    var controlModules = 'ControlModules';
    var mtrCtrl = 'MtrCtrl';
    var eventsDol = 'EventsDol';

    var pluckerMotor = 'PluckerMotor';
    var pluckerMotorMessage = pluckerMotor.sentenceCase.toLowerCase();
    var isolatorSwitchOff = 'IsolatorSwitchOff';
    var isolatorSwitchOffMessage = 'isolator switch is off';
    var protectionTripped = 'ProtectionTripped';
    var protectionTrippedMessage = 'protection tripped';

    var fuse = 'Fuse';
    var fuseMessage = 'fuse tripped';
    var definition = Definition()
      ..addStruct('Events')
      ..addStructBool(fuse, fuseMessage, [ArrayRange.minMax(0, 2)])
      ..addStructReference(
        dataTypeName: pluckerMotor,
        dataTypeExpression: '$controlModules\\$mtrCtrl\\$eventsDol',
        dataTypeComment: pluckerMotorMessage,
        dataTypeArrayRanges: [ArrayRange.minMax(1, 2), ArrayRange.minMax(1, 3)],
      )
      ..goToRoot()
      ..addNameSpace(controlModules)
      ..addNameSpace(mtrCtrl)
      ..addStruct(eventsDol)
      ..addStructBool(isolatorSwitchOff, isolatorSwitchOffMessage)
      ..addStructBool(protectionTripped, protectionTrippedMessage);

    for (var f = 0; f <= 2; f++) {
      definition.addExpectedEvent(
        groupName1: fuse,
        expression: '$eventGlobalVariableName.$fuse($f)',
        message: fuseMessage.sentenceCase + '.',
      );
    }

    for (var x = 1; x <= 2; x++) {
      for (var y = 1; y <= 3; y++) {
        definition.addExpectedEvent(
          groupName1: pluckerMotor.titleCase,
          expression:
              '$eventGlobalVariableName.$pluckerMotor($x,$y).$isolatorSwitchOff',
          message:
              '${pluckerMotorMessage.sentenceCase} $isolatorSwitchOffMessage.',
        );
        definition.addExpectedEvent(
          groupName1: pluckerMotor.titleCase,
          expression:
              '$eventGlobalVariableName.$pluckerMotor($x,$y).$protectionTripped',
          message:
              '${pluckerMotorMessage.sentenceCase} $protectionTrippedMessage.',
        );
      }
    }
    return definition;
  }
}

main() {
  EventArrayExample().executeTest();

  group('class: $ArrayCounter', () {
    var eventGroup = EventArrayExample().createDefinition().eventGlobalVariable;

    group('Empty', () {
      var arrayValues = NoArrayValues().toList();
      test('arrayValues', () {
        expect(arrayValues, [
          '',
        ]);
      });

      group('Fuse', () {
        var fuseNode = eventGroup.children.first;
        var arrayValues = ArrayValues(fuseNode).toList();
        test('arrayValues', () {
          expect(arrayValues, [
            '(0)',
            '(1)',
            '(2)',
          ]);
        });

        group('PluckerMotors', () {
          var pluckerMotorNode = eventGroup.children.last;
          var arrayValues = ArrayValues(pluckerMotorNode).toList();

          test('arrayValues', () {
            expect(arrayValues, [
              '(1,1)',
              '(1,2)',
              '(1,3)',
              '(2,1)',
              '(2,2)',
              '(2,3)',
            ]);
          });
        });
      });
    });
  });
}
