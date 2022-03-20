import 'package:petitparser/parser.dart';
import 'package:sysmac_generator/util/sentence.dart';

import 'event_parser.dart';
import 'generic_parsers.dart';

/// Often extra information is needed for the operator or technician on how to solve an event..
///
/// By default the event has the following solution text when the event has a
/// [ComponentCode]: See component <Component Code> on electric diagram
/// &lt;Site Number&gt;DE&lt;Panel Number&gt; on page &lt;Page Number&gt;
/// at column &lt;Column Number&gt;.
///
/// You can add additional solutions by using a [SolutionTag] in one of the comments:
/// * Format: [solution=&lt;solution to solve the problem&gt;]
/// * Notes: you may use:
///   * upper or lower case (lower case is recommended for consistency)
///   * spaces (spaces are not recommended: keep [EventTag]s short)
/// * Examples:
///   * [solution=solution to solve the problem]   (=true)
class SolutionTag extends EventTag {
  final String solution;

  SolutionTag(String solution) : solution = Sentence.normalize(solution);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SolutionTag &&
          runtimeType == other.runtimeType &&
          solution == other.solution;

  @override
  int get hashCode => solution.hashCode;

  @override
  String toString() {
    return 'SolutionTag{solution: $solution}';
  }
}

class SolutionTagParser extends EventTagParser {
  SolutionTagParser()
      : super((char('[') &
                whiteSpaceParser.optional() &
                stringIgnoreCase('solution') &
                whiteSpaceParser.optional() &
                string('=') &
                any().starLazy(char(']')).flatten() &
                char(']'))
            .map((values) => SolutionTag(values[5])));
}
