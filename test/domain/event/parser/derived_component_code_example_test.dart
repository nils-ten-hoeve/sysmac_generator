import 'package:petitparser/src/matcher/matches_skipping.dart';
import 'package:recase/recase.dart';
import 'package:sysmac_generator/domain/event/parser/component_code_parser.dart';
import 'package:sysmac_generator/domain/event/parser/derived_component_code_parser.dart';
import 'package:sysmac_generator/infrastructure/variable.dart';
import 'package:test/test.dart';

import 'example.dart';

class EventDerivedComponentCodeExample extends EventExample {
  @override
  bool get showSysmacFileNameTable => true;

  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withExpression.withComponentCode.withMessage;

  @override
  String get explanation =>
      "{ImportDartDoc path='lib/domain/event/parser/derived_component_code_parser.dart|DerivedComponentCodeTag' }"
      "\n\n"
      "* ${ComponentCodeTag}s are project specific and are therefore defined in "
      "the structure of the EvenGlobal variable\n"
      "* ${DerivedComponentCodeTag}s are often used in generic event "
      "definitions such as function block structures that are reused "
      "(in the project or in a library project).";

  @override
  Definition createDefinition() {
    var brushMotor = 'BrushMotor';
    var controlModules = 'ControlModules';
    var mtrCtrl = 'MtrCtrl';
    var eventsDol = 'EventsDol';
    var disabledOnHmi = 'DisabledOnHmi';
    var isolatorSwitchOff = 'IsolatorSwitchOff';
    var protectionTripped = 'ProtectionTripped';
    var forwardReplayTimeOut = 'ForwardRelayTimeout';
    var reverseRelayTimeOut = 'ReverseRelayTimeout';
    return Definition()
      ..addStruct('Events')
      ..addStructReference(
          dataTypeName: brushMotor,
          dataTypeExpression: '$controlModules\\$mtrCtrl\\$eventsDol',
          dataTypeComment: '[30M1][70Q2][110K1][110K3]brush motor')
      ..goToRoot()
      ..addNameSpace(controlModules)
      ..addNameSpace(mtrCtrl)
      ..addStruct(eventsDol)
      ..addStructBool(disabledOnHmi, 'disabled on touch screen')
      ..addStructBool(isolatorSwitchOff, '[s] isolator switch is off')
      ..addStructBool(protectionTripped, '[Q] protection tripped')
      ..addStructBool(forwardReplayTimeOut, '[k1] forward relay timeout')
      ..addStructBool(reverseRelayTimeOut, '[K2] reverse relay timeout')
      ..addExpectedEvent(
        groupName1: brushMotor.titleCase,
        expression: '$eventGlobalVariableName.$brushMotor.$disabledOnHmi',
        message: 'Brush motor disabled on touch screen.',
        componentCode: ComponentCode(
          site: site,
          electricPanel: electricPanel,
          pageNumber: 30,
          letters: 'm',
          columnNumber: 1,
        ).toCode(),
        solution:
            'See component 4321.DE06.30M1 on electric diagram 4321.DE06 on page 30 at column 1.',
      )
      ..addExpectedEvent(
        groupName1: brushMotor.titleCase,
        expression: '$eventGlobalVariableName.$brushMotor.$isolatorSwitchOff',
        message: 'Brush motor isolator switch is off.',
        componentCode: ComponentCode(
          site: site,
          electricPanel: electricPanel,
          pageNumber: 30,
          letters: 's',
          columnNumber: 1,
        ).toCode(),
        solution:
            'See component 4321.DE06.30S1 on electric diagram 4321.DE06 on page 30 at column 1.',
      )
      ..addExpectedEvent(
        groupName1: brushMotor.titleCase,
        expression: '$eventGlobalVariableName.$brushMotor.$protectionTripped',
        message: 'Brush motor protection tripped.',
        componentCode: ComponentCode(
          site: site,
          electricPanel: electricPanel,
          pageNumber: 70,
          letters: 'Q',
          columnNumber: 2,
        ).toCode(),
        solution:
            'See component 4321.DE06.70Q2 on electric diagram 4321.DE06 on page 70 at column 2.',
      )
      ..addExpectedEvent(
        groupName1: brushMotor.titleCase,
        expression:
            '$eventGlobalVariableName.$brushMotor.$forwardReplayTimeOut',
        message: 'Brush motor forward relay timeout.',
        componentCode: ComponentCode(
          site: site,
          electricPanel: electricPanel,
          pageNumber: 110,
          letters: 'K',
          columnNumber: 1,
        ).toCode(),
        solution:
            'See component 4321.DE06.110K1 on electric diagram 4321.DE06 on page 110 at column 1.',
      )
      ..addExpectedEvent(
        groupName1: brushMotor.titleCase,
        expression: '$eventGlobalVariableName.$brushMotor.$reverseRelayTimeOut',
        message: 'Brush motor reverse relay timeout.',
        componentCode: ComponentCode(
          site: site,
          electricPanel: electricPanel,
          pageNumber: 110,
          letters: 'K',
          columnNumber: 3,
        ).toCode(),
        solution:
            'See component 4321.DE06.110K3 on electric diagram 4321.DE06 on page 110 at column 3.',
      );
  }
}

void main() {
  EventDerivedComponentCodeExample().executeTest();

  var parser = DerivedComponentCodeTagParser();
  group('$DerivedComponentCodeTagParser', () {
    test("'123 [s] 456' has correct result", () {
      var result = parser.matchesSkipping('123 [s] 456');
      expect(result[0], DerivedComponentCodeTag(letters: 'S'));
    });
    test("'123 [ Q ] 456' has correct result", () {
      var result = parser.matchesSkipping('123 [ Q ] 456');
      expect(result[0], DerivedComponentCodeTag(letters: 'Q'));
    });
    test("'123 [Jb ] 456' has correct result", () {
      var result = parser.matchesSkipping('123 [Jb ] 456');
      expect(result[0], DerivedComponentCodeTag(letters: 'JB'));
    });
    test("'123 [k1] 456' has correct result", () {
      var result = parser.matchesSkipping('123 [k1] 456');
      expect(result[0], DerivedComponentCodeTag(letters: 'K', indexNumber: 1));
    });
    test("'123 [ K2] 456' has correct result", () {
      var result = parser.matchesSkipping('123 [ K2] 456');
      expect(result[0], DerivedComponentCodeTag(letters: 'K', indexNumber: 2));
    });
    test("'123 [-] 456' has no result (not a letter)", () {
      var result = parser.matchesSkipping('123 [-] 456');
      expect(result.isEmpty, true);
    });
  });
}
