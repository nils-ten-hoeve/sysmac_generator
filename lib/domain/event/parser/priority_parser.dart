import 'package:petitparser/core.dart';
import 'package:petitparser/parser.dart';
import 'package:recase/recase.dart';
import 'package:sysmac_generator/domain/event/event.dart';

import 'event_parser.dart';
import 'generic_parsers.dart';

/// The default priority is: Medium
///
/// You can override the priority by using a [PriorityTag] in one of the comments:
/// * Format: [prio&lt;rity&gt;=&lt;priority name or abbreviation&gt;]
/// * Notes: you may use:
///   * prio= or priority= (prio= recommended: keep [EventTag]s short)
///   * upper or lower case (lower case is recommended for consistency)
///   * spaces (spaces are not recommended: keep [EventTag]s short)
/// * Examples:
///   * [prio=f]
///   * [ Prio = High ]
///   * [ PRIORITY=I ]
///   * [prio=medium high]
///   * [priority=MediumHigh]
class PriorityTag extends EventTag {
  final EventPriorityOld priority;

  PriorityTag(this.priority);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriorityTag &&
          runtimeType == other.runtimeType &&
          priority == other.priority;

  @override
  int get hashCode => priority.hashCode;

  @override
  String toString() {
    return 'PriorityTag{priority: $priority}';
  }
}

/// Pareses the attribute value of a [PriorityTag]
class PriorityValueParser extends EventTagParser {
  PriorityValueParser() : super(_createParser());

  static Parser _createParser() {
    var values = _createValues();
    var valueKeys = _longToShortValueKeys(values);
    List<Parser> parsers = [];
    for (var priorityText in valueKeys) {
      var priority = values[priorityText];
      parsers.add(stringIgnoreCase(priorityText).map((value) => priority));
    }
    return ChoiceParser(parsers);
  }

  static Map<String, EventPriorityOld> _createValues() {
    Map<String, EventPriorityOld> values = {};
    for (var priority in EventPriorities()) {
      values[priority.abbreviation] = priority;
      values[priority.name] = priority;
      values[priority.name.pascalCase] = priority;
    }
    return values;
  }

  static List<String> _longToShortValueKeys(
      Map<String, EventPriorityOld> values) {
    var keys = values.keys.toList();
    keys.sort((text1, text2) => text1.length.compareTo(text2.length) * -1);
    return keys;
  }
}

class PriorityTagParser extends EventTagParser {
  PriorityTagParser()
      : super((char('[') &
                whiteSpaceParser.optional() &
                stringIgnoreCase('prio') &
                stringIgnoreCase('rity').optional() &
                whiteSpaceParser.optional() &
                char('=') &
                whiteSpaceParser.optional() &
                PriorityValueParser() &
                whiteSpaceParser.optional() &
                char(']'))
            .map((values) => PriorityTag(values[7])));
}
