import 'package:petitparser/petitparser.dart';
import 'package:sysmac_cmd/domain/event/parser/event.dart';

class ComponentCode implements EventMetaData {
  final int pageNumber;
  final String letters;
  final int columnNumber;

  ComponentCode({
    required this.pageNumber,
    required this.letters,
    required this.columnNumber,
  });

  @override
  String toString() {
    return 'VisibleComponentCode{pageNumber: $pageNumber, letters: $letters, columnNumber: $columnNumber}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComponentCode &&
          runtimeType == other.runtimeType &&
          pageNumber == other.pageNumber &&
          letters == other.letters &&
          columnNumber == other.columnNumber;

  @override
  int get hashCode =>
      pageNumber.hashCode ^ letters.hashCode ^ columnNumber.hashCode;
}

final _pageNumberParser = digit().plus().flatten().map(int.parse);

final _letterParser = letter()
    .repeat(1, 4)
    .flatten()
    .map((String value) => value.toUpperCase());

final _columnNumberParser =
    pattern('1-8').times(1).flatten().map(int.parse);

/// A [componentCodeParser] finds and converts the following string format to a
/// [ComponentCode] object:
///
/// Format: <pageNumber><letters><pageNumber>
/// Example: 30M2
final componentCodeParser =
    (_pageNumberParser & _letterParser & _columnNumberParser).map((values) =>
        ComponentCode(
            pageNumber: values[0],
            letters: values[1],
            columnNumber: values[2]));
