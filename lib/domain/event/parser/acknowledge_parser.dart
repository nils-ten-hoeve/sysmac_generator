import 'package:petitparser/core.dart';
import 'package:petitparser/parser.dart';

import 'event_parser.dart';
import 'generic_parsers.dart';

/// Often you want the operator to acknowledge an event.
/// This makes sure that the event stays visible in the HMI,
/// until it is deliberately acknowledged.
/// This can be handy if the event is shortly active or when an event requires
/// the attention of the operator.
///
/// By default events need to be acknowledged unless they are of [Priority]: INFO
///
/// You can override if an event needs to be acknowledged using a
/// [AcknowledgeTag] in one of the comments:
/// * Format: [ack&lt;nowledge&gt;&lt;=true or =false&gt;]
/// * Notes: you may use:
///   * ack or acknowledged (ack is recommended: keep [EventTag]s short)
///   * upper or lower case (lower case is recommended for consistency)
///   * spaces (spaces are not recommended: keep [EventTag]s short)
/// * Examples:
///   * [ack]   (=true)
///   * [ acknowledge ]   (=true)
///   * [ ack=true ]
///   * [ACKNOWLEDGE=false]
///   * [ack = false]
class AcknowledgeTag extends EventTag {
  final bool acknowledge;

  AcknowledgeTag(this.acknowledge);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcknowledgeTag &&
          runtimeType == other.runtimeType &&
          acknowledge == other.acknowledge;

  @override
  int get hashCode => acknowledge.hashCode;

  @override
  String toString() {
    return 'AcknowledgeTag{acknowledge: $acknowledge}';
  }
}

/// Pareses the attribute value of a [AcknowledgeTag]
class AcknowledgeValueParser extends EventTagParser {
  AcknowledgeValueParser() : super(_createParser());

  static Parser _createParser() {
    return (_trueParser() | _falseParser()).optional();
  }

  static Parser _trueParser() =>
      (string('=') & whiteSpaceParser.optional() & stringIgnoreCase('true'))
          .map((value) => true);

  static Parser _falseParser() =>
      (string('=') & whiteSpaceParser.optional() & stringIgnoreCase('false'))
          .map((value) => false);
}

class AcknowledgeTagParser extends EventTagParser {
  AcknowledgeTagParser()
      : super((char('[') &
                whiteSpaceParser.optional() &
                stringIgnoreCase('ack') &
                stringIgnoreCase('nowledge').optional() &
                whiteSpaceParser.optional() &
                AcknowledgeValueParser() &
                whiteSpaceParser.optional() &
                char(']'))
            .map((values) => values[5] == null
                ? AcknowledgeTag(true)
                : values[5] == true
                    ? AcknowledgeTag(true)
                    : AcknowledgeTag(false)));
}
