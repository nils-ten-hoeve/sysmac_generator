import 'package:sysmac_generator/domain/base_type.dart';
import 'package:sysmac_generator/infrastructure/variable.dart';

import 'example.dart';

class EventGlobalExample extends EventExample {
  @override
  get title => eventGlobalVariableName;

  @override
  String get explanation => 'Events are defined in a global variable with'
      ' the name: $eventGlobalVariableName. '
      'Each $VbBoolean in the $eventGlobalVariableName variable structure '
      'is an event.';

  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withId.withExpression.withMessage;

  @override
  Definition createDefinition() => Definition()
    ..addStruct('Events')
    ..addStructBool('Event1', 'first event')
    ..addStructBool('Event2', 'second event')
    ..addExpectedEvent(
      groupName1: 'Event1',
      expression: 'EventGlobal.Event1',
      message: 'First event.',
    )
    ..addExpectedEvent(
      groupName1: 'Event2',
      expression: 'EventGlobal.Event2',
      message: 'Second event.',
    );
}

void main() {
  EventGlobalExample().executeTest();
}
