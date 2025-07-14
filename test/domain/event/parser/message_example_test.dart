import '../../../../bin/sysmac_generator.dart';

import 'example.dart';

class EventMessageExample extends EventExample {
  @override
  String get explanation =>
      'The event message is the EventGlobal comments and its '
      'DataType comments chained together, following the hierarchical '
      'structure from [root to leaf]'
      '(https://en.wikipedia.org/wiki/Tree_(data_structure))\n\n'
      'It is recommended to use lowercase letters in comments where possible '
      '(e.g. abbreviations like PLC in capital letters is ok). '
      '$SysmacGenerator will change the first letter of the message to a '
      'capital letter and add a period at the end when needed.';

  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withId.withExpression.withMessage;

  @override
  Definition createDefinition() => Definition()
    ..variableComment = 'the event message is'
    ..addStruct('Events', 'all comments chained together,')
    ..addStructBool(
        'Event1', 'following the hierarchical structure from root to leaf')
    ..addStructBool('Event2', 'making all messages unique')
    ..addExpectedEvent(
      groupName1: 'Event1',
      expression: 'EventGlobal.Event1',
      message:
          'The event message is all comments chained together, following the hierarchical structure from root to leaf.',
    )
    ..addExpectedEvent(
      groupName1: 'Event2',
      expression: 'EventGlobal.Event2',
      message:
          'The event message is all comments chained together, making all messages unique.',
    );
}

void main() {
  EventMessageExample().executeTest();
}
