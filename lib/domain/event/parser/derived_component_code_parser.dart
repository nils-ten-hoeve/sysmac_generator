import 'package:petitparser/petitparser.dart';
import 'package:sysmac_generator/domain/event/parser/component_code_parser.dart';
import 'package:sysmac_generator/domain/event/parser/event_parser.dart';

import 'generic_parsers.dart';

/// [DerivedComponentCodeTag]s derive from a [ComponentCodeTag].
///
/// It will try to find the best matching [ComponentCodeTag] :
/// * First it will use the [ComponentCodeTag] with the same letter
///   combination. It will use the [ComponentCodeTag] with the corresponding
///   indexNumber when multiple [ComponentCodeTag]s have the same
///   letter combination.
/// * Otherwise it will try to find the first [ComponentCodeTag] and replace
///   the letters with those of the [DerivedComponentCodeTag]
///
/// [DerivedComponentCodeTag]:
/// * Format: [&lt;letters&gt;&lt;indexNumber&gt;]
/// * Notes:
///   * you may use upper or lower case
///     (upper case is recommended for consistency)
///   * you may use spaces (spaces are not recommended: keep [EventTag]s short)
///   * the indexNumber is optional and only needed when multiple
///     [ComponentCodeTag]s have the same letter combinations. Note that the
///     indexNumber starts at 1 for the first matching [ComponentCodeTag]
/// * Examples: [s] or [ Q ] or  [Jb ] or [k1] or [ k2]
class DerivedComponentCodeTag extends EventTag {
  final String letters;
  final int indexNumber;

  DerivedComponentCodeTag({
    required String letters,
    this.indexNumber = 1,
  }) : letters = letters.toUpperCase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DerivedComponentCodeTag &&
          runtimeType == other.runtimeType &&
          letters == other.letters &&
          indexNumber == other.indexNumber;

  @override
  int get hashCode => letters.hashCode ^ indexNumber.hashCode;

  /// The creation of the component code is done by the [EventService]
  @override
  String toString() {
    return 'DerivedComponentCodeTag{letters: $letters, columnNumber: $indexNumber}';
  }
}

class DerivedComponentCodeTagParser extends EventTagParser {
  static final _letterParser = letter()
      .repeat(1, 4)
      .flatten()
      .map((String value) => value.toUpperCase());

  static final _indexNumberParser = digit().plus().flatten().map(int.parse);

  DerivedComponentCodeTagParser()
      : super((char('[') &
                whiteSpaceParser.optional() &
                _letterParser &
                _indexNumberParser.optional() &
                whiteSpaceParser.optional() &
                char(']'))
            .map((values) => DerivedComponentCodeTag(
                letters: values[2], indexNumber: values[3] ?? 1)));
}
