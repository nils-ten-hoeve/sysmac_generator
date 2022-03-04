import 'package:petitparser/parser.dart';

import 'event_parser.dart';
import 'generic_parsers.dart';

/// Format: [PanelNr=#]
/// Example: [PanelNr=6] or [Panelnr=06] or [ PanelNr = 12 ]
class PanelNumberTag extends EventTag {
  final int number;

  PanelNumberTag(this.number);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PanelNumberTag &&
          runtimeType == other.runtimeType &&
          number == other.number;

  @override
  int get hashCode => number.hashCode;

  @override
  String toString() {
    return 'PanelNumberTag{number: $number}';
  }
}

class PanelNumberTagParser extends EventTagParser {
  PanelNumberTagParser()
      : super((char('[') &
                whiteSpaceParser.optional() &
                stringIgnoreCase('PanelNr') &
                whiteSpaceParser.optional() &
                char('=') &
                whiteSpaceParser.optional() &
                intParser &
                whiteSpaceParser.optional() &
                char(']'))
            .map((values) => PanelNumberTag(values[6] as int)));
}
