import 'package:petitparser/petitparser.dart';

import 'event_parser.dart';
import 'generic_parsers.dart';

/// maximum value of int= 2 ^ 32bits.
const int maxInt = 4294967296;

class Multiplicity {
  final int min, max;

  Multiplicity({required this.min, required this.max});

  Multiplicity.zeroOrOnce()
      : min = 0,
        max = 1;

  Multiplicity.once()
      : min = 1,
        max = 1;

  Multiplicity.zeroOrMore()
      : min = 0,
        max = maxInt;

  Multiplicity.onceOrMore()
      : min = 1,
        max = maxInt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Multiplicity &&
          runtimeType == other.runtimeType &&
          min == other.min &&
          max == other.max;

  @override
  int get hashCode => min.hashCode ^ max.hashCode;
}

/// The [AttributeParser] converts the text representation of [EventTag]s
/// into objects that represent attribute values.
/// See [petitparser](https://pub.dev/packages/petitparser)
/// This class wraps and implements a [Parser] so that we can extend
/// [AttributesParser]s
abstract class AttributeParser extends Parser {
  /// The parser converts [EventTag]s into [EventTag] objects
  /// See [petitparser](https://pub.dev/packages/petitparser)
  final Parser _parser;
  final Multiplicity multiplicity;

  AttributeParser(Parser parser, this.multiplicity) : _parser = parser;

  @override
  Parser copy() {
    return _parser.copy();
  }

  @override
  Result parseOn(Context context) {
    return _parser.parseOn(context);
  }
}

/// parsed a comma separated string to a list of objects
/// that represents the values between the comma's, using attributeParsers
abstract class AttributesParser extends EventTagParser {
  AttributesParser(List<Parser> attributeParsers)
      : super(_createParser(attributeParsers));

  static Parser _createParser(List<Parser> attributeParsers) =>
      (((whiteSpaceParser.optional() &
                          _createAttributeParser(attributeParsers) &
                          whiteSpaceParser.optional())
                      .plus() &
                  (string(',') &
                      whiteSpaceParser.optional() &
                      _createAttributeParser(attributeParsers) &
                      whiteSpaceParser.optional())) |
              (whiteSpaceParser.optional() &
                      _createAttributeParser(attributeParsers) &
                      whiteSpaceParser.optional())
                  .star())
          .map((values) {
        //TODO convert to function block
        var objects = _getAllObjectsIn(values);
        return objects;
      });

  //TODO verify attributeParsers.multiplicity

  static Parser _createAttributeParser(List<Parser> attributeParsers) {
    Parser? parser;
    for (var attributeParser in attributeParsers) {
      if (parser == null) {
        parser = attributeParser;
      } else {
        parser = parser | attributeParser;
      }
    }
    return parser!; // will throw null exception when no attributesParsers are given.
    // This is a design time error and therefore should not happen at normal run time.
  }

  static List _getAllObjectsIn(value) {
    var objects = [];
    if (value is Iterable) {
      for (var element in value) {
        objects.addAll(_getAllObjectsIn(element));
      }
    } else if (value != null && value is! String) {
      objects.add(value);
    }
    return objects;
  }
}
