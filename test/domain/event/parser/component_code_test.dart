import 'package:petitparser/src/matcher/matches_skipping.dart';
import 'package:sysmac_cmd/domain/event/parser/component_code.dart';
import 'package:test/test.dart';

main() {
  group('$componentCodeParser', ()  {
    test("'123 30M2 456' has correct result", ()  {
      var result=componentCodeParser.matchesSkipping('123 30M2 456');
      expect(result[0], ComponentCode(pageNumber: 30, letters: 'M', columnNumber: 2));

    });
    test("'123 30m2 456' has correct result (capital case)", ()  {
      var result=componentCodeParser.matchesSkipping('123 30m2 456');
      expect(result[0], ComponentCode(pageNumber: 30, letters: 'M', columnNumber: 2));
    });
    test("'123 30M0 456' has no result (invalid column number)", ()  {
      var result=componentCodeParser.matchesSkipping('123 30M0 456');
      expect(result.isEmpty, true);
    });
    test("'123   30 M1    456' has no result (invalid space in between)", ()  {
      var result=componentCodeParser.matchesSkipping('123   30 M1    456');
      expect(result.isEmpty, true);
    });
  });
}