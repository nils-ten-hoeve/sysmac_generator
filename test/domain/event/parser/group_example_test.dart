import 'package:recase/recase.dart';

import 'example.dart';

class EventGroupExample extends EventExample {
  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withExpression.withGroupName1.withGroupName2;

  @override
  String get explanation =>
      'The program is organized in a logical structure so that code can be located '
      'easily. We follow the ISA 88 standard. This means that the programs '
      '(and events) are organized from big and generic to small and specific '
      ', e.g.:\n'
      '* Enterprise (big & generic level, e.g. Tyson)\n'
      '* Site (e.g. Union City - USA)\n'
      '* Area (e.g. Evisceration Department)\n'
      '* Work Center (e.g. Evisceration Line)\n'
      '* Work Unit (e.g. Maestro)\n'
      '* Equipment Module (e.g. Maestro Pump)\n'
      '* Control module (small & specific level, e.g. Maestro Pump Level Sensor)\n'
      '\n\n'
      'Events are structured the same. Each Work center or Work unit has a '
      'event group that contains alarms of Equipment modules and control modules'
      '\n\n'
      'Each member of the EventGroup datatype will automatically become a '
      'alarm group.:\n\n'
      'Each member that starts with the sam name will become part of the same '
      'alarm group.';

  var rapidEvents = 'RapidEvents';

  @override
  Definition createDefinition() {
    var definition = Definition()..addStruct(rapidEvents);

    _add(definition, ['Transp'], 3);
    _add(definition, ['Transp', 'Mtr'], 4);
    _add(definition, ['WbCarStpr'], 5);
    _add(definition, ['WbCarStpr', 'Cyl'], 6);
    _add(definition, ['WbCutTopCm'], 10);
    _add(definition, ['WbCutTopCm', 'Mtr'], 11);
    _add(definition, ['WbCutTopCm', 'Pos', 'Act'], 12);
    _add(definition, ['WbCutBotCm'], 7);
    _add(definition, ['WbCutBotCm', 'Mtr'], 8);
    _add(definition, ['WbCutBotCm', 'Pos', 'Act'], 9);
    _add(definition, ['BckmtCarStpr'], 1);
    _add(definition, ['BckmtCarStpr', 'Cyl'], 2);
    return definition;
  }

  void _add(Definition definition, List<String> names, int id) {
    var someAlarmText = 'Some alarm.';
    definition
      ..goToPath([rapidEvents])
      ..addStruct(names.join())
      ..addEvent(
        dataTypeName: 'Event',
        dataTypeComment: someAlarmText,
        groupName1: names[0].titleCase,
        groupName2:
            names.where((name) => names.indexOf(name) != 0).toList().join(' '),
        expression: 'EventGlobal.${names.join()}.Event',
        message: someAlarmText,
        id: id.toString(),
      );
  }
}

main() {
  EventGroupExample().executeTest();
}
