import 'package:sysmac_generator/domain/event/parser/component_code_parser.dart';
import 'package:sysmac_generator/domain/event/parser/event_parser.dart';
import 'package:test/test.dart';

main() {
  var eventTagsParser = EventTagsParser();
  group('$EventTagsParser', () {
    String text = '12 30M2 34';
    test("'$text' has correct result", () {
      var result = eventTagsParser.parse(text);
      expect(result.value, [
        '1',
        '2',
        ' ',
        ComponentCodeTag(pageNumber: 30, letters: 'M', columnNumber: 2),
        ' ',
        '3',
        '4'
      ]);
    });
  });
}
