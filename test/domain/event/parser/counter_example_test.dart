import 'package:logging/logging.dart';
import 'package:petitparser/matcher.dart';
import 'package:sysmac_generator/domain/event/parser/counter_parser.dart';
import 'package:test/test.dart';

main() {
  var parser = CounterTagParser();
  group('$CounterTagParser', () {
    test("'false' has no result", () {
      var result = parser.parse('false');
      expect(result.isFailure, true);
    });
    test("'[cnt]' results in a $CounterTag", () {
      var result = parser.parse('[cnt]');
      expect(result.value, CounterTag(0, []));
    });

    test("' [ cnt ] ' results in a $CounterTag", () {
      var result = parser.matchesSkipping(' [ cnt ] ');
      expect(result.first, CounterTag(0, []));
    });

    test("' [ cnt array=2 ] ' results in a $CounterTag(array=2)", () {
      var result = parser.matchesSkipping(' [ cnt array=2 ] ');
      expect(result.first, CounterTag(2, []));
    });

    group('$ArrayAttribute', () {
      test("' [ cnt array  = 3 ] ' results in a $CounterTag(array=3)", () {
        var result = parser.matchesSkipping(' [ cnt array  = 3 ] ');
        expect(result.first, CounterTag(3, []));
      });

      test(
          "' [ cnt array  = 3, array = 4 ] ' results in a $CounterTag(array=4)",
          () {
        String logMsg = '';
        Logger.root.onRecord.listen((LogRecord rec) {
          logMsg = rec.message;
        });

        var result = parser.matchesSkipping(' [ cnt array  = 3, array = 4 ] ');
        expect(result.first, CounterTag(4, []));
        expect(logMsg,
            'CounterTagParser found multiple array number attributes: (ArrayAttribute{number: 3}, ArrayAttribute{number: 4})');
      });
    });

    group('$SkipAttribute', () {
      test(
          "' [cnt skip= E ] ' results in a $CounterTag(skipRules=SkipEvenRule)",
          () {
        var result = parser.matchesSkipping(' [cnt skip= E ] ');
        expect(result.first, CounterTag(0, [SkipEvenRule()]));
      });

      test("'[cnt skip=Even]' results in a $CounterTag(skipRules=SkipEvenRule)",
          () {
        var result = parser.matchesSkipping('[cnt skip=Even]');
        expect(result.first, CounterTag(0, [SkipEvenRule()]));
      });

      test(
          "' [cnt skip= u ] ' results in a $CounterTag(skipRules=SkipEvenRule)",
          () {
        var result = parser.matchesSkipping(' [cnt skip= u ] ');
        expect(result.first, CounterTag(0, [SkipUnEvenRule()]));
      });

      test(
          "'[cnt skip=uneveN]' results in a $CounterTag(skipRules=SkipEvenRule)",
          () {
        var result = parser.matchesSkipping('[cnt skip=uneveN]');
        expect(result.first, CounterTag(0, [SkipUnEvenRule()]));
      });

      test(
          "'[cnt skip=even, uneveN]' results in a $CounterTag(skipRules=SkipEvenRule)",
          () {
        String logMsg2 = '';
        Logger.root.onRecord.listen((LogRecord rec) {
          logMsg2 = rec.message;
        });
        var result = parser.matchesSkipping('[cnt skip=even, uneveN]');
        expect(result.first, CounterTag(0, [SkipUnEvenRule()]));
        expect(logMsg2, 'Multiple SkipEvenRules and or SkipUnEvenRules found.');
      });

      test("'[cnt skip=3]' results in a $CounterTag(skipRules=$SkipMinMaxRule)",
          () {
        var result = parser.matchesSkipping('[cnt skip=3]');
        expect(result.first, CounterTag(0, [SkipMinMaxRule(min: 3, max: 3)]));
      });

      test(
          "'[cnt skip=-3]' results in a $CounterTag(skipRules=$SkipMinMaxRule)",
          () {
        var result = parser.matchesSkipping('[cnt skip=-3]');
        expect(result.first, CounterTag(0, [SkipMinMaxRule(min: 0, max: 3)]));
      });

      test(
          "'[cnt skip=3-5]' results in a $CounterTag(skipRules=$SkipMinMaxRule)",
          () {
        var result = parser.matchesSkipping('[cnt skip=3-5]');
        expect(result.first, CounterTag(0, [SkipMinMaxRule(min: 3, max: 5)]));
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
          expect(result.first, CounterTag(0, [SkipUnEvenRule()]));
          expect(
              logMsg2, 'Multiple SkipEvenRules and or SkipUnEvenRules found.');
        });

        test(
            "'[cnt skip=3,5]' results in a $CounterTag(skipRules=$SkipMinMaxRule)",
            () {
          var result = parser.matchesSkipping('[cnt skip=3,5]');
          expect(
              result.first,
              CounterTag(0, [
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
              CounterTag(0, [
                SkipMinMaxRule(min: 0, max: 3),
                SkipMinMaxRule(min: 5, max: 7)
              ]));
        });
      });
    });
  });
}
