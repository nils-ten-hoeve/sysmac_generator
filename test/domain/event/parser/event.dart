import 'package:sysmac_cmd/domain/event/parser/component_code.dart';
import 'package:sysmac_cmd/domain/event/parser/event.dart';
import 'package:test/test.dart';

main() {
  group('$eventParser', () {
    String text = '12 30M2 34';
    test("'$text' has correct result", () {
      var result = eventParser.parse(text);
      expect(result.value, [
        '1',
        '2',
        ' ',
        ComponentCode(pageNumber: 30, letters: 'M', columnNumber: 2),
        ' ',
        '3',
        '4'
      ]);
    });
  });
}
