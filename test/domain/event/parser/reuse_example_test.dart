import 'example.dart';

class EventReuseExample extends EventExample {
  @override
  EventTableColumns get eventTableColumns => EventTableColumns()
      .withExpression
      .withGroupName1
      .withGroupName2
      .withMessage;

  @override
  String get explanation => 'You can reuse structures, e.g.:\n'
      '* You can re-use structures over and over again.\n'
      '* The re-used structures could be part of a library project, '
      'but they do not have to be. '
      'E.g. the structures with namespaces in the example below are '
      'normally part of the standard library used bij Meyn projects.\n';

  var rapidEvents = 'RapidEvents';

  // Equipment
  //   Transport
  //     sEvent
  //   CamHeight
  //     sEvent
  //   CarrierStopper
  //     sEvent
  // Cm
  //   MtrCtrl
  //     sEventVfd
  //   CylCtrl
  //     sEvent
  //   Ai
  //     sEvent
  //
  // Transp	Equipment\Transport\sEvent
  // TranspMtr	Cm\MtrCtrl\sEventVfd
  // WbCarStpr	Equipment\CarrierStopper\sEvent
  // WbCarStprCyl	Cm\CylCtrl\sEvent
  // WbCutTopCm	Equipment\CamHeight\sEvent
  // WbCutTopCmPosAct	Cm\Ai\sEvent
  // WbCutTopCmMtr	Cm\MtrCtrl\sEventDol
  // WbCutBotCm	Equipment\CamHeight\sEvent
  // WbCutBotCmPosAct	Cm\Ai\sEvent
  // WbCutBotCmMtr	Cm\MtrCtrl\sEventDol
  // BckmtCarStpr	Equipment\CarrierStopper\sEvent
  // BckmtCarStprCyl	Cm\CylCtrl\sEvent

  final _eventExample = 'event example';

  @override
  Definition createDefinition() {
    var equipmentModules = 'EquipmentModules';
    var transport = 'Transport';
    var events = 'Events';
    var eventsVfd = '${events}Vfd';
    var controlModules = 'ControlModules';
    var carrierStopper = 'CarrierStopper';
    var cylCtrl = 'CylCtrl';
    var transportEvent = 'TransportEvent';
    var eventGlobal = 'EventGlobal';
    var bckmtCarStprComment = 'Back meat harvester carrousel stopper';
    var bckmtCarStprCylComment = '$bckmtCarStprComment cylinder';
    var camHeight = 'CamHeight';
    var camHeightEvent = 'CamHeightEvent';
    var mtrCtrl = 'MtrCtrl';
    var vfdEvent = 'VfdEvent';
    var ai = 'AI';
    var analogInputEvent = 'AnalogInputEvent';
    var definition = Definition()..addStruct(rapidEvents);
    var carrierStopperEvent = 'CarrierStopperEvent';
    var cylinderEvent = 'CylinderEvent';

    var bckmtCarStpr = 'BckmtCarStpr';
    var carrierStopperDataType = '$equipmentModules\\$carrierStopper\\$events';
    _add(
      definition: definition,
      dataTypeName: bckmtCarStpr,
      dataTypeExpression: carrierStopperDataType,
      groupName1: 'Bckmt Car Stpr',
      eventExpression: '$eventGlobal.$bckmtCarStpr.$carrierStopperEvent',
      comment: bckmtCarStprComment,
    );
    var bckmtCarStprCyl = '${bckmtCarStpr}Cyl';
    var cylCtrlDataType = '$controlModules\\$cylCtrl\\$events';
    _add(
      definition: definition,
      dataTypeName: bckmtCarStprCyl,
      groupName1: 'Bckmt Car Stpr',
      groupName2: 'Cyl',
      dataTypeExpression: cylCtrlDataType,
      eventExpression: '$eventGlobal.$bckmtCarStprCyl.$cylinderEvent',
      comment: bckmtCarStprCylComment,
    );
    var transportComment = 'Transport';
    _add(
      definition: definition,
      dataTypeName: transport,
      dataTypeExpression: '$equipmentModules\\$transport\\$events',
      groupName1: 'Transport',
      eventExpression: '$eventGlobal.$transport.$transportEvent',
      comment: transportComment,
    );

    var transportMtr = 'TransportMtr';
    _add(
      definition: definition,
      dataTypeName: transportMtr,
      dataTypeExpression: '$controlModules\\$mtrCtrl\\$eventsVfd',
      groupName1: 'Transport',
      groupName2: 'Mtr',
      eventExpression: '$eventGlobal.$transportMtr.$vfdEvent',
      comment: '$transportComment motor',
    );

    _add(
      definition: definition,
      dataTypeName: 'WbCutBotCm',
      dataTypeExpression: '$equipmentModules\\$camHeight\\$events',
      groupName1: 'Wb Cut',
      groupName2: 'Bot Cm',
      eventExpression: '$eventGlobal.WbCutBotCm.$camHeightEvent',
      comment: 'Wishbone cutter bottom cam',
    );

    _add(
      definition: definition,
      dataTypeName: 'WbCutBotCmMtr',
      dataTypeExpression: '$controlModules\\$mtrCtrl\\$eventsVfd',
      groupName1: 'Wb Cut',
      groupName2: 'Bot Cm Mtr',
      eventExpression: '$eventGlobal.WbCutBotCmMtr.$vfdEvent',
      comment: 'Wishbone cutter bottom cam motor',
    );
    _add(
      definition: definition,
      dataTypeName: 'WbCutBotCmPos',
      dataTypeExpression: '$controlModules\\$ai\\$events',
      groupName1: 'Wb Cut',
      groupName2: 'Bot Cm Pos',
      eventExpression: '$eventGlobal.WbCutBotCmPos.$analogInputEvent',
      comment: 'Wishbone cutter bottom cam position sensor',
    );

    _add(
      definition: definition,
      dataTypeName: 'WbCutStpr',
      dataTypeExpression: carrierStopperDataType,
      groupName1: 'Wb Cut',
      groupName2: 'Stpr',
      eventExpression: '$eventGlobal.WbCutStpr.$carrierStopperEvent',
      comment: 'Wishbone cutter stopper',
    );

    _add(
      definition: definition,
      dataTypeName: 'WbCutStprCyl',
      dataTypeExpression: cylCtrlDataType,
      groupName1: 'Wb Cut',
      groupName2: 'Stpr Cyl',
      eventExpression: '$eventGlobal.WbCutStprCyl.$cylinderEvent',
      comment: 'Wishbone cutter stopper cylinder',
    );

    _add(
      definition: definition,
      dataTypeName: 'WbCutTopCm',
      dataTypeExpression: '$equipmentModules\\$camHeight\\$events',
      groupName1: 'Wb Cut',
      groupName2: 'Top Cm',
      eventExpression: '$eventGlobal.WbCutTopCm.$camHeightEvent',
      comment: 'Wishbone cutter top cam',
    );

    _add(
      definition: definition,
      dataTypeName: 'WbCutTopCmMtr',
      dataTypeExpression: '$controlModules\\$mtrCtrl\\$eventsVfd',
      groupName1: 'Wb Cut',
      groupName2: 'Top Cm Mtr',
      eventExpression: '$eventGlobal.WbCutTopCmMtr.$vfdEvent',
      comment: 'Wishbone cutter top cam motor',
    );
    _add(
      definition: definition,
      dataTypeName: 'WbCutTopCmPos',
      dataTypeExpression: '$controlModules\\$ai\\$events',
      groupName1: 'Wb Cut',
      groupName2: 'Top Cm Pos',
      eventExpression: '$eventGlobal.WbCutTopCmPos.$analogInputEvent',
      comment: 'Wishbone cutter top cam position sensor',
    );

    definition
      ..goToRoot()
      ..addNameSpace(equipmentModules)
      ..addNameSpace(transport)
      ..addStruct(events)
      ..addStructBool(transportEvent, _eventExample)
      ..goToPath([equipmentModules])
      ..addNameSpace(camHeight)
      ..addStruct(events)
      ..addStructBool(camHeightEvent, _eventExample)
      ..goToPath([equipmentModules])
      ..addNameSpace(carrierStopper)
      ..addStruct(events)
      ..addStructBool(carrierStopperEvent, _eventExample)
      ..goToRoot()
      ..addNameSpace(controlModules)
      ..addNameSpace(mtrCtrl)
      ..addStruct(eventsVfd)
      ..addStructBool(vfdEvent, _eventExample)
      ..goToPath([controlModules])
      ..addNameSpace(cylCtrl)
      ..addStruct(events)
      ..addStructBool(cylinderEvent, _eventExample)
      ..goToPath([controlModules])
      ..addNameSpace(ai)
      ..addStruct(events)
      ..addStructBool(analogInputEvent, _eventExample);

    return definition;
  }

  void _add({
    required Definition definition,
    required String dataTypeName,
    required String dataTypeExpression,
    required String eventExpression,
    required String comment,
    required String groupName1,
    String groupName2 = '',
  }) {
    definition.addStructReference(
        dataTypeName: dataTypeName,
        dataTypeExpression: dataTypeExpression,
        dataTypeComment: comment);

    definition.addExpectedEvent(
        groupName1: groupName1,
        groupName2: groupName2,
        expression: eventExpression,
        message: '$comment $_eventExample.');
  }
}

void main() {
  EventReuseExample().executeTest();
}
