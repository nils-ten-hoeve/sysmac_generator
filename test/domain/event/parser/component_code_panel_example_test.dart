import 'package:petitparser/src/matcher/matches_skipping.dart';
import 'package:sysmac_generator/domain/event/parser/Panel_nr_parser.dart';
import 'package:sysmac_generator/domain/event/parser/component_code_parser.dart';
import 'package:sysmac_generator/domain/sysmac_project.dart';
import 'package:test/test.dart';

import 'example.dart';

class EventComponentCodePanelExample extends EventExample {
  @override
  bool get showSysmacFileNameTable => true;

  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withExpression.withComponentCode.withMessage;

  @override
  String get explanation =>
      "{ImportDartDoc path='lib/domain/event/parser/panel_nr_parser.dart|$PanelNumberTag' }";

  @override
  Definition createDefinition() => Definition()
    ..addStruct('Events')
    ..addStructReference(
      dataTypeName: 'MainPanel',
      dataTypeExpression: 'sMainPanel',
      dataTypeComment: '[PanelNr=1]',
    )
    ..addStructReference(
      dataTypeName: 'SecondPanel',
      dataTypeExpression: 'sSecondPanel',
      dataTypeComment: '[PanelNr=DE02]',
    )
    ..goToRoot()
    ..addStruct('sMainPanel')
    ..addStructBool(
      dataTypeName: 'event1',
      dataTypeComment: '[30Q1] plucker1 motor1 overloaded',
    )
    ..goToRoot()
    ..addStruct('sSecondPanel')
    ..addStructBool(
      dataTypeName: 'event2',
      dataTypeComment: '[30Q1] plucker5 motor1 overloaded',
    )
    ..addExpectedEvent(
      groupName1: 'Main Panel',
      message: 'Plucker1 motor1 overloaded.',
      expression: 'EventGlobal.MainPanel.event1',
      componentCode: ComponentCode(
              site: Site(4321),
              electricPanel: ElectricPanel(number: 1, name: ''),
              pageNumber: 30,
              letters: 'Q',
              columnNumber: 1)
          .toCode(),
      solution:
          'See component 4321.DE01.30Q1 on electric diagram 4321.DE01 on page 30 at column 1.',
    )
    ..addExpectedEvent(
      groupName1: 'Second Panel',
      expression: 'EventGlobal.SecondPanel.event2',
      message: 'Plucker5 motor1 overloaded.',
      componentCode: ComponentCode(
              site: Site(4321),
              electricPanel: ElectricPanel(number: 2, name: ''),
              pageNumber: 30,
              letters: 'Q',
              columnNumber: 1)
          .toCode(),
      solution:
          'See component 4321.DE02.30Q1 on electric diagram 4321.DE02 on page 30 at column 1.',
    );
}

main() {
  EventComponentCodePanelExample().executeTest();

  var parser = PanelNumberTagParser();
  group('$PanelNumberTagParser', () {
    test("'[PanelNr=123]' has correct result", () {
      var result = parser.parse('[PanelNr=123]');
      expect(result.value, PanelNumberTag(123));
    });
    test("'456 [Panelnr=123]789' has correct result", () {
      var result = parser.matchesSkipping('456 [Panelnr=123]789');
      expect(result[0], PanelNumberTag(123));
    });
    test("'456[ PanelNr = 123 ]789' has correct result", () {
      var result = parser.matchesSkipping('456[ PanelNr = 123 ]789');
      expect(result[0], PanelNumberTag(123));
    });
    test("'456[ PanelNr =  ]789' has no result", () {
      var result = parser.matchesSkipping('456[ PanelNr =  ]789');
      expect(result.isEmpty, true);
    });
    test("'456[ PanelNr :12  ]789' has no result", () {
      var result = parser.matchesSkipping('456[ PanelNr :12  ]789');
      expect(result.isEmpty, true);
    });
    test("'456[ PanelNr =-12  ]789' has no result", () {
      var result = parser.matchesSkipping('456[ PanelNr =-12  ]789');
      expect(result.isEmpty, true);
    });
  });
}
