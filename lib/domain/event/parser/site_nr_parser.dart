import 'package:petitparser/parser.dart';

import 'event_parser.dart';
import 'generic_parsers.dart';

/// The [ComponentCode] in an [Event] begins with a site number.
/// Each known processing plant has a unique number, also called a Meyn layout number.
///
/// e.g. 4321 = Maple Leaf - London - Canada
///
/// The default site number  comes from the the [SysmacProjectFile] name.
///
/// You can override the site number by using a [SiteNumberTag] in one of the comments:
/// * Format: [SiteNr=&lt;number&gt;]
/// * Examples: [SiteNr=123] or [sitenr=123] or [ siteNr = 123 ]
class SiteNumberTag extends EventTag {
  final int number;

  SiteNumberTag(this.number);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SiteNumberTag &&
          runtimeType == other.runtimeType &&
          number == other.number;

  @override
  int get hashCode => number.hashCode;

  @override
  String toString() {
    return 'SiteNumberTag{number: $number}';
  }
}

class SiteNumberTagParser extends EventTagParser {
  SiteNumberTagParser()
      : super((char('[') &
                whiteSpaceParser.optional() &
                stringIgnoreCase('SiteNr') &
                whiteSpaceParser.optional() &
                char('=') &
                whiteSpaceParser.optional() &
                intParser &
                whiteSpaceParser.optional() &
                char(']'))
            .map((values) => SiteNumberTag(values[6] as int)));
}
