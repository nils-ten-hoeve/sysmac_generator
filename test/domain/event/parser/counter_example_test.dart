import 'package:logging/logging.dart';
import 'package:petitparser/matcher.dart';
import 'package:recase/recase.dart';
import 'package:sysmac_generator/domain/base_type.dart';
import 'package:sysmac_generator/domain/event/parser/counter_parser.dart';
import 'package:sysmac_generator/infrastructure/variable.dart';
import 'package:test/test.dart';

import 'example.dart';

class EventArrayCounterExample extends EventExample {
  @override
  bool get showSysmacFileNameTable => false;

  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withExpression.withMessage;

  @override
  String get explanation =>
      "{ImportDartDoc path='lib/domain/event/parser/counter_parser.dart|$CounterTag'}\n"
      "&lt;comma separated attributes&gt; are optional:\n"
      "{ImportDartDoc path='lib/domain/event/parser/counter_parser.dart|$ArrayAttribute'}\n"
      // "{ImportDartDoc path='lib/domain/event/parser/counter_parser.dart|$ContinueAttribute'}\n"
      "{ImportDartDoc path='lib/domain/event/parser/counter_parser.dart|$SkipAttribute'}\n";

  @override
  Definition createDefinition() {
    var line = 'Line';
    var plucker = 'Plucker';
    var beam = 'Beam';
    var motor = 'Motor';
    var workCenter = 'WorkCenter';
    var workUnit = 'WorkUnit';
    var events = 'Events';
    var equipmentModule = 'EquipmentModule';
    var controlModule = 'ControlModule';
    var mtrCtrl = 'MtrCtrl';
    var eventsDol = 'EventsDol';
    var isolatorSwitchOff = 'IsolatorSwitchOff';
    var isolatorSwitchOffMessage = 'isolator switch is off';

    var definition = Definition()
      ..addStruct('Events')
      ..addStructReference(
        dataTypeName: line,
        dataTypeExpression: '$workCenter\\$line\\$events',
        dataTypeComment: '$line [cnt]',
        dataTypeArrayRanges: [ArrayRange.minMax(1, 2)],
      )

      //Line
      ..goToRoot()
      ..addNameSpace(workCenter)
      ..addNameSpace(line)
      ..addStruct(events)
      ..addStructReference(
          dataTypeName: plucker,
          dataTypeArrayRanges: [ArrayRange.minMax(0, 2)],
          dataTypeExpression: '$workUnit\\$plucker\\$events',
          dataTypeComment: '${plucker.toLowerCase()} [cnt skip=0,2,4-6]')

      //Plucker
      ..goToRoot()
      ..addNameSpace(workUnit)
      ..addNameSpace(plucker)
      ..addStruct(events)
      ..addStructReference(
          dataTypeName: beam,
          dataTypeArrayRanges: [
            ArrayRange.minMax(0, 1),
            ArrayRange.minMax(0, 1)
          ],
          dataTypeExpression: '$equipmentModule\\$beam\\$events',
          dataTypeComment:
              '${beam.toLowerCase()} [cnt array=-2, skip=e]-[cnt skip=u]')

      //PluckerBeam
      ..goToRoot()
      ..addNameSpace(equipmentModule)
      ..addNameSpace(beam)
      ..addStruct(events)
      ..addStructReference(
          dataTypeName: motor,
          dataTypeArrayRanges: [ArrayRange.minMax(1, 2)],
          dataTypeExpression: '$controlModule\\$mtrCtrl\\$eventsDol',
          dataTypeComment: '${motor.toLowerCase()} [cnt skip=0]')

      //Motor
      ..goToRoot()
      ..addNameSpace(controlModule)
      ..addNameSpace(mtrCtrl)
      ..addStruct(eventsDol)
      ..addStructBool(isolatorSwitchOff, isolatorSwitchOffMessage);

    var pluckerNumbers = [1, 3, 7];
    var beam1Numbers = [1, 3];
    var beam2Numbers = [0, 2];

    for (var lineIndex = 1; lineIndex <= 2; lineIndex++) {
      for (var pluckerIndex = 0; pluckerIndex <= 2; pluckerIndex++) {
        for (var beamIndex1 = 0; beamIndex1 <= 1; beamIndex1++) {
          for (var beamIndex2 = 0; beamIndex2 <= 1; beamIndex2++) {
            for (var motorIndex = 1; motorIndex <= 2; motorIndex++) {
              definition.addExpectedEvent(
                groupName1: line.titleCase,
                expression: '$eventGlobalVariableName.'
                    '$line($lineIndex).'
                    '$plucker($pluckerIndex).'
                    '$beam($beamIndex1,$beamIndex2).'
                    '$motor($motorIndex).'
                    '$isolatorSwitchOff',
                message: '$line ${lineIndex - 1} '
                    '${plucker.toLowerCase()} ${pluckerNumbers[pluckerIndex]} '
                    '${beam.toLowerCase()} ${beam1Numbers[beamIndex1]}-${beam2Numbers[beamIndex2]} '
                    '${motor.toLowerCase()} $motorIndex '
                    '$isolatorSwitchOffMessage.',
              );
            }
          }
        }
      }
    }
    return definition;
  }
}

void main() {
  EventArrayCounterExample().executeTest();

  var parser = CounterTagParser();
  group('$CounterTagParser', () {
    group('No Attributes', () {
      test("'false' has no result", () {
        var result = parser.parse('false');
        expect(result.isFailure, true);
      });
      test("'[cnt]' results in a $CounterTag", () {
        var result = parser.parse('[cnt]');
        expect(result.value, CounterTag(skipRules: []));
      });
      test("' [ cnt ] ' results in a $CounterTag", () {
        var result = parser.matchesSkipping(' [ cnt ] ');
        expect(result.first, CounterTag(skipRules: []));
      });
    });

    group('$ArrayAttribute', () {
      test("' [ cnt array  = -3 ] ' results in a $CounterTag(array=3)", () {
        var result = parser.matchesSkipping(' [ cnt array  = -3 ] ');
        expect(result.first, CounterTag(array: 3, skipRules: []));
      });

      test(
          "' [ cnt array  = -3, array = -4 ] ' results in a $CounterTag(array=4)",
          () {
        String logMsg = '';
        Logger.root.onRecord.listen((LogRecord rec) {
          logMsg = rec.message;
        });

        var result =
            parser.matchesSkipping(' [ cnt array  = -3, array = -4 ] ');
        expect(result.first, CounterTag(array: 4, skipRules: []));
        expect(
            logMsg,
            'CounterTagParser found multiple array number attributes: '
            '(ArrayAttribute{number: 3}, ArrayAttribute{number: 4})');
      });
    });

    group('$ContinueAttribute', () {
      test(
          "' [ cnt  ] ' results in a $CounterTag(resetWhenArrayCounterResets=true)",
          () {
        var result = parser.matchesSkipping(' [ cnt  ] ');
        expect(result.first,
            CounterTag(skipRules: [], resetWhenArrayCounterResets: true));
      });

      test(
          "' [ cnt cont ] ' results in a $CounterTag(resetWhenArrayCounterResets=false)",
          () {
        var result = parser.matchesSkipping(' [ cnt cont ] ');
        expect(result.first,
            CounterTag(skipRules: [], resetWhenArrayCounterResets: false));
      });

      test(
          "' [cnt continue] ' results in a $CounterTag(resetWhenArrayCounterResets=false)",
          () {
        var result = parser.matchesSkipping(' [ cnt cont ] ');
        expect(result.first,
            CounterTag(skipRules: [], resetWhenArrayCounterResets: false));
      });
    });

    group('$SkipAttribute', () {
      test(
          "' [cnt skip= E ] ' results in a $CounterTag(skipRules=SkipEvenRule)",
          () {
        var result = parser.matchesSkipping(' [cnt skip= E ] ');
        expect(result.first, CounterTag(skipRules: [SkipEvenRule()]));
      });

      test("'[cnt skip=Even]' results in a $CounterTag(skipRules=SkipEvenRule)",
          () {
        var result = parser.matchesSkipping('[cnt skip=Even]');
        expect(result.first, CounterTag(skipRules: [SkipEvenRule()]));
      });

      test(
          "' [cnt skip= u ] ' results in a $CounterTag(skipRules=SkipEvenRule)",
          () {
        var result = parser.matchesSkipping(' [cnt skip= u ] ');
        expect(result.first, CounterTag(skipRules: [SkipUnEvenRule()]));
      });

      test(
          "'[cnt skip=uneveN]' results in a $CounterTag(skipRules=SkipEvenRule)",
          () {
        var result = parser.matchesSkipping('[cnt skip=uneveN]');
        expect(result.first, CounterTag(skipRules: [SkipUnEvenRule()]));
      });

      test(
          "'[cnt skip=even, uneveN]' results in a $CounterTag(skipRules=SkipEvenRule)",
          () {
        String logMsg2 = '';
        Logger.root.onRecord.listen((LogRecord rec) {
          logMsg2 = rec.message;
        });
        var result = parser.matchesSkipping('[cnt skip=even, uneveN]');
        expect(result.first, CounterTag(skipRules: [SkipUnEvenRule()]));
        expect(logMsg2, 'Multiple SkipEvenRules and or SkipUnEvenRules found.');
      });

      test("'[cnt skip=3]' results in a $CounterTag(skipRules=$SkipMinMaxRule)",
          () {
        var result = parser.matchesSkipping('[cnt skip=3]');
        expect(result.first,
            CounterTag(skipRules: [SkipMinMaxRule(min: 3, max: 3)]));
      });

      test(
          "'[cnt skip=-3]' results in a $CounterTag(skipRules=$SkipMinMaxRule)",
          () {
        var result = parser.matchesSkipping('[cnt skip=-3]');
        expect(result.first,
            CounterTag(skipRules: [SkipMinMaxRule(min: 0, max: 3)]));
      });

      test(
          "'[cnt skip=3-5]' results in a $CounterTag(skipRules=$SkipMinMaxRule)",
          () {
        var result = parser.matchesSkipping('[cnt skip=3-5]');
        expect(result.first,
            CounterTag(skipRules: [SkipMinMaxRule(min: 3, max: 5)]));
      });

      group('Combined', () {
        test(
            "'[cnt skip=even, uneveN]' results in a $CounterTag(skipRules=SkipEvenRule)",
            () {
          String logMsg2 = '';
          Logger.root.onRecord.listen((LogRecord rec) {
            logMsg2 = rec.message;
          });
          var result = parser.matchesSkipping('[cnt skip=even, uneveN]');
          expect(result.first, CounterTag(skipRules: [SkipUnEvenRule()]));
          expect(
              logMsg2, 'Multiple SkipEvenRules and or SkipUnEvenRules found.');
        });

        test(
            "'[cnt skip=3,5]' results in a $CounterTag(skipRules=$SkipMinMaxRule)",
            () {
          var result = parser.matchesSkipping('[cnt skip=3,5]');
          expect(
              result.first,
              CounterTag(skipRules: [
                SkipMinMaxRule(min: 3, max: 3),
                SkipMinMaxRule(min: 5, max: 5),
              ]));
        });

        test(
            "'[cnt skip=-3, 5-7]' results in a $CounterTag(skipRules=$SkipMinMaxRule)",
            () {
          var result = parser.matchesSkipping('[cnt skip=-3, 5-7]');
          expect(
              result.first,
              CounterTag(skipRules: [
                SkipMinMaxRule(min: 0, max: 3),
                SkipMinMaxRule(min: 5, max: 7)
              ]));
        });
      });
    });

    group('Combined Attributes', () {
      test(
          "'[cnt array=-2, continue, skip=-3]' results in a "
          "$CounterTag(array=-2, resetWhenArrayCounterResets=false, skipRules: =$SkipMinMaxRule)",
          () {
        var result = parser.matchesSkipping('[ cnt skip=-3, array= -2, cont]');
        expect(
            result.first,
            CounterTag(
                array: 2,
                resetWhenArrayCounterResets: false,
                skipRules: [SkipMinMaxRule(min: 0, max: 3)]));
      });
    });
  });
}
