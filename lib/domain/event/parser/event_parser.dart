import 'package:petitparser/context.dart';
import 'package:petitparser/core.dart';
import 'package:petitparser/parser.dart';
import 'package:sysmac_generator/domain/data_type.dart';
import 'package:sysmac_generator/domain/event/event.dart';
import 'package:sysmac_generator/domain/event/parser/component_code_parser.dart';
import 'package:sysmac_generator/domain/event/parser/site_nr_parser.dart';

/// In order to generate [Event]s we need more information.
/// This information is stored in [EventTag]s.
///
/// [EventTag]s can be used inside:
/// * the comment of the EventGlobal variable.
/// * the comments of all the [DataType]s that are used inside the EventGlobal variable.
///
/// The format of an [EventTag] is normally some text between square brackets, e.g.: [30M2]
///
/// [EventTag] are not be directly visible in the [Event] message!
class EventTag {
// all relevant tag information as final field values!

  /// The [EventTag] can be converted to a replacement text
  /// using all [EventTag] objects of an [Event]
//TODO String replacementText(List<EventMetaData> eventMetaData);
}

/// The [EventTagParser] converts the text representation of [EventTag]s
/// into [EventTag] objects.
/// See [petitparser](https://pub.dev/packages/petitparser)
/// This is a wrapper class (for documentation)
class EventTagParser extends Parser {
  /// The parser converts [EventTag]s into [EventTag] objects
  /// See [petitparser](https://pub.dev/packages/petitparser)
  final Parser _parser;

  EventTagParser(Parser parser) : _parser = parser;

  @override
  Parser copy() {
    return _parser.copy();
  }

  @override
  Result parseOn(Context context) {
    return _parser.parseOn(context);
  }
}

/// The [EventTagsParser] combines all [EventTagParser]s.
///
/// [EventTagsParser.parse] results in an array of [EventTag] objects or remaining characters.

class EventTagsParser extends EventTagParser {
  static final _remainingCharactersParser = any().flatten();

  EventTagsParser()
      : super((ComponentCodeTagParser() |
                SiteNumberTagParser() |
                _remainingCharactersParser)
            .star());
}
