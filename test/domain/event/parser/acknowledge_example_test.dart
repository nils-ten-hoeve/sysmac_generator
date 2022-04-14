import 'package:petitparser/src/matcher/matches_skipping.dart';
import 'package:sysmac_generator/domain/event/event.dart';
import 'package:sysmac_generator/domain/event/parser/acknowledge_parser.dart';
import 'package:test/test.dart';

import 'example.dart';

class EventAcknowledgeExample extends EventExample {
  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withExpression.withMessage.withAcknowledge;

  @override
  String get explanation =>
      "{ImportDartDoc path='lib/domain/event/parser/acknowledge_parser.dart|$AcknowledgeTag' }";

  @override
  Definition createDefinition() {

    return Definition()
      ..addStruct('Events')
      ..addStructBool(
        dataTypeName: 'Event1',
        dataTypeComment: '[ack]needs to be acknowledged',
      )
      ..addStructBool(
        dataTypeName: 'Event2',
        dataTypeComment:
            '[ acknowledge = false]does not need to be acknowledged',
      )
      ..addStructBool(
        dataTypeName: 'Event3',
        dataTypeComment:
            '[priority=info]info priority does not need to be acknowledged by default',
      )
      ..addStructBool(
        dataTypeName: 'Event4',
        dataTypeComment:
            '[priority=h]other priorities need to be acknowledged by default',
      )
      ..addExpectedEvent(
        groupName1: 'Event1',
        expression: 'EventGlobal.Event1',
        message: 'Needs to be acknowledged.',
        acknowledge: true,
      )
      ..addExpectedEvent(
        groupName1: 'Event2',
        expression: 'EventGlobal.Event2',
        message: 'Does not need to be acknowledged.',
        acknowledge: false,
      )
      ..addExpectedEvent(
        groupName1: 'Event3',
        expression: 'EventGlobal.Event3',
        priority: EventPriorities.info,
        message: 'Info priority does not need to be acknowledged by default.',
        acknowledge: false,
      )
      ..addExpectedEvent(
        groupName1: 'Event4',
        expression: 'EventGlobal.Event4',
        priority: EventPriorities.high,
        message: 'Other priorities need to be acknowledged by default.',
        acknowledge: true,
      );
  }
}

main() {
  EventAcknowledgeExample().executeTest();

  var parser = AcknowledgeTagParser();
  group('$AcknowledgeTagParser', () {
    group('Acknowledge only', () {
      group('Without spaces', () {
        var input1 = '1234[ack]5678';
        test("Parsing: '$input1' results in ${true}", () {
          var result = parser.matchesSkipping(input1);
          expect(result[0], AcknowledgeTag(true));
        });

        var input2 = '1234[acknowledge]5678';
        test("Parsing: '$input2' results in ${true}", () {
          var result = parser.matchesSkipping(input2);
          expect(result[0], AcknowledgeTag(true));
        });

        var input3 = '1234[ACK]5678';
        test("Parsing: '$input3' results in ${true}", () {
          var result = parser.matchesSkipping(input3);
          expect(result[0], AcknowledgeTag(true));
        });

        var input4 = '1234[ACKNOWLEDGE]5678';
        test("Parsing: '$input4' results in ${true}", () {
          var result = parser.matchesSkipping(input4);
          expect(result[0], AcknowledgeTag(true));
        });
      });

      group('With spaces', () {
        var input1 = '1234[ ack  ]5678';
        test("Parsing: '$input1' results in ${true}", () {
          var result = parser.matchesSkipping(input1);
          expect(result[0], AcknowledgeTag(true));
        });

        var input2 = '1234[  acknowledge ]5678';
        test("Parsing: '$input2' results in ${true}", () {
          var result = parser.matchesSkipping(input2);
          expect(result[0], AcknowledgeTag(true));
        });

        var input3 = '1234[ ACK ]5678';
        test("Parsing: '$input3' results in ${true}", () {
          var result = parser.matchesSkipping(input3);
          expect(result[0], AcknowledgeTag(true));
        });

        var input4 = '1234[  ACKNOWLEDGE   ]5678';
        test("Parsing: '$input4' results in ${true}", () {
          var result = parser.matchesSkipping(input4);
          expect(result[0], AcknowledgeTag(true));
        });
      });
    });
    group('Acknowledge = true', () {
      group('Without spaces', () {
        var input1 = '1234[ack=true]5678';
        test("Parsing: '$input1' results in ${true}", () {
          var result = parser.matchesSkipping(input1);
          expect(result[0], AcknowledgeTag(true));
        });

        var input2 = '1234[acknowledge=true]5678';
        test("Parsing: '$input2' results in ${true}", () {
          var result = parser.matchesSkipping(input2);
          expect(result[0], AcknowledgeTag(true));
        });

        var input3 = '1234[ACK=TRUE]5678';
        test("Parsing: '$input3' results in ${true}", () {
          var result = parser.matchesSkipping(input3);
          expect(result[0], AcknowledgeTag(true));
        });

        var input4 = '1234[ACKNOWLEDGE=TRUE]5678';
        test("Parsing: '$input4' results in ${true}", () {
          var result = parser.matchesSkipping(input4);
          expect(result[0], AcknowledgeTag(true));
        });
      });

      group('With spaces', () {
        var input1 = '1234[  ack=true  ]5678';
        test("Parsing: '$input1' results in ${true}", () {
          var result = parser.matchesSkipping(input1);
          expect(result[0], AcknowledgeTag(true));
        });

        var input2 = '1234[ acknowledge = true ]5678';
        test("Parsing: '$input2' results in ${true}", () {
          var result = parser.matchesSkipping(input2);
          expect(result[0], AcknowledgeTag(true));
        });

        var input3 = '1234[  ACK = TRUE   ]5678';
        test("Parsing: '$input3' results in ${true}", () {
          var result = parser.matchesSkipping(input3);
          expect(result[0], AcknowledgeTag(true));
        });

        var input4 = '1234[ ACKNOWLEDGE  =  TRUE ]5678';
        test("Parsing: '$input4' results in ${true}", () {
          var result = parser.matchesSkipping(input4);
          expect(result[0], AcknowledgeTag(true));
        });
      });
    });

    group('Acknowledge = false', () {
      group('Without spaces', () {
        var input1 = '1234[ack=false]5678';
        test("Parsing: '$input1' results in false", () {
          var result = parser.matchesSkipping(input1);
          expect(result[0], AcknowledgeTag(false));
        });

        var input2 = '1234[acknowledge=false]5678';
        test("Parsing: '$input2' results in false", () {
          var result = parser.matchesSkipping(input2);
          expect(result[0], AcknowledgeTag(false));
        });

        var input3 = '1234[ACK=FALSE]5678';
        test("Parsing: '$input3' results in false", () {
          var result = parser.matchesSkipping(input3);
          expect(result[0], AcknowledgeTag(false));
        });

        var input4 = '1234[ACKNOWLEDGE=FALSE]5678';
        test("Parsing: '$input4' results in false", () {
          var result = parser.matchesSkipping(input4);
          expect(result[0], AcknowledgeTag(false));
        });
      });

      group('With spaces', () {
        var input1 = '1234[  ack=false  ]5678';
        test("Parsing: '$input1' results in false", () {
          var result = parser.matchesSkipping(input1);
          expect(result[0], AcknowledgeTag(false));
        });

        var input2 = '1234[ acknowledge = false ]5678';
        test("Parsing: '$input2' results in false", () {
          var result = parser.matchesSkipping(input2);
          expect(result[0], AcknowledgeTag(false));
        });

        var input3 = '1234[  ACK = FALSE   ]5678';
        test("Parsing: '$input3' results in false", () {
          var result = parser.matchesSkipping(input3);
          expect(result[0], AcknowledgeTag(false));
        });

        var input4 = '1234[ ACKNOWLEDGE  =  FALSE ]5678';
        test("Parsing: '$input4' results in false", () {
          var result = parser.matchesSkipping(input4);
          expect(result[0], AcknowledgeTag(false));
        });
      });
    });
  });
}
