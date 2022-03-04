import 'package:petitparser/parser.dart';

import 'event_parser.dart';
import 'generic_parsers.dart';

/// The [ComponentCode] in an [Event] contains a electric panel number.
/// Each electric Meyn panel within a [Site] has a unique number.
/// This number can also be found in the electrical schematic
///
/// e.g. DE06 = Eviseration Line 1 panel (at 4321 Maple Leaf - London - Canada)
///
/// The default panel number  comes from the the [SysmacProjectFile] name.
///
/// You can override the panel number by using a [PanelNumberTag] in one of the comments:
/// * Format: [PanelNr=&lt;DE&gt;&lt;number&gt;]
/// * Examples: [PanelNr=6] or [PanelNr=DE6] or [Panelnr=de06] or [ PanelNr = 12 ]
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
                stringIgnoreCase('de').optional() &
                intParser &
                whiteSpaceParser.optional() &
                char(']'))
            .map((values) => PanelNumberTag(values[7] as int)));
}
