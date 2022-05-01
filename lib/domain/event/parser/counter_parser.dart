import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:petitparser/parser.dart';
import 'package:sysmac_generator/domain/event/parser/attribute_parser.dart';

import 'event_parser.dart';
import 'generic_parsers.dart';

/// You can use counters when the data type uses an array.
/// Counters are added by adding the following text to the [DataType] comment:
///
/// [cnt <skip=skip rules> <array=array number>]
///
///
///

/// etcetera
/// {insert CounterRuleExampleTest}
///
/// TODO {insert CounterRuleArrayExampleTest}
///
/// TODO {insert CounterRuleArrayExampleTest}
///
/// TODO {insert CounterRuleSkipArrayExampleTest}
///
/// SkipCounterRule
///
/// Skipping counter values when using arrays:
/// {@insert SkipEvenCounterRule}
/// {@insert SkipUnevenCounterRule}
/// {@insert SkipSingleCounterRule}
/// {@insert SkipMaxCounterRule}
/// {@insert SkipMinMaxCounterRule}
/// You can combine the rules above by separating them with a comma, e.g.:
/// s=e,5: skips even counter values and counter value 5
/// s=2,4: skips counter value 2 and counter value 4
/// s=2-4,8: skips counter value 2-4 and counter value 8
class CounterTag extends EventTag {
  final int array;
  final List<SkipRule> skipRules;

  CounterTag(this.array, this.skipRules);

  @override
  String toString() {
    return 'CounterTag{array: $array, skipRules: $skipRules}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterTag &&
          runtimeType == other.runtimeType &&
          array == other.array &&
          const ListEquality().equals(skipRules, other.skipRules);

  @override
  int get hashCode => array.hashCode ^ skipRules.hashCode;
}

class CounterAttributesParser extends AttributesParser {
  CounterAttributesParser()
      : super([ArrayAttributeParser(), SkipAttributeParser()]);
}

abstract class CounterAttribute {}

/// <array=array number> is optional:
///
/// no array attribute or array=0: counter increases when any array is increased and will not reset within the array
/// array=1: counter increases when the last array is increased, the counter is reset if the second last array is increased
/// array=2: counter increases when the second last array is increased, the counter is reset if the third last array is increased
class ArrayAttribute extends CounterAttribute {
  final int number;

  ArrayAttribute({this.number = 0});

  @override
  String toString() {
    return 'ArrayAttribute{number: $number}';
  }
}

class ArrayAttributeParser extends AttributeParser {
  ArrayAttributeParser()
      : super(
            (stringIgnoreCase('array') &
                    whiteSpaceParser.optional() &
                    string('=') &
                    whiteSpaceParser.optional() &
                    intParser)
                .map((values) => ArrayAttribute(number: values[4])),
            Multiplicity.zeroOrOnce());
}

/// <skip=skip rules> are optional and can be used to skip numbers.
/// e.g.: the counters always start at 0.
/// Use skip=0, if you want the counter to start at 1.
class SkipAttribute extends CounterAttribute {
  static final log = Logger('$SkipAttribute');

  final List<SkipRule> skipRules;

  SkipAttribute(this.skipRules) {
    _removeTooManySkipEvenOrUnEvenRules();
  }

  void _removeTooManySkipEvenOrUnEvenRules() {
    var evenAndUnevenSkipRules =
        skipRules.where(_isSkipEvenOrUnEvenRule).toList();
    if (evenAndUnevenSkipRules.length > 1) {
      log.warning('Multiple ${SkipEvenRule}s and or ${SkipUnEvenRule}s found.');
      var lastEvenAndUnEvenSkipRules = skipRules.last;
      skipRules.removeWhere(_isSkipEvenOrUnEvenRule);
      skipRules.add(lastEvenAndUnEvenSkipRules);
    }
  }

  bool _isSkipEvenOrUnEvenRule(skipRule) =>
      skipRule is SkipEvenRule || skipRule is SkipUnEvenRule;
}

class SkipAttributeParser extends AttributeParser {
  SkipAttributeParser()
      : super(
            (stringIgnoreCase('skip') &
                    whiteSpaceParser.optional() &
                    string('=') &
                    whiteSpaceParser.optional() &
                    SkipRulesParser())
                .map((values) {
              return SkipAttribute(
                  (values[4] as List).whereType<SkipRule>().toList());
            }),
            Multiplicity.zeroOrOnce());
}

class SkipRulesParser extends AttributesParser {
  SkipRulesParser()
      : super([
          SkipEvenParser(),
          SkipUnEvenParser(),
          SkipRangeParser(),
          SkipUntilParser(),
          SkipSingleNumberParser(),
        ]);
}

abstract class SkipRule {
  /// returns true if the current counter value needs to be skipped
  /// according to this rule, otherwise it returns false
  bool appliesTo(int counterValue);

  /// returns the next available value according to this rule
  int getNextValue(int counterValue);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkipRule && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class SkipEvenRule extends SkipRule {
  @override
  bool appliesTo(int counterValue) => _isEven(counterValue);

  @override
  int getNextValue(int counterValue) => counterValue + 1;

  bool _isEven(int counterValue) => counterValue % 2 == 0;
}

class SkipUnEvenRule extends SkipRule {
  @override
  bool appliesTo(int counterValue) => _isUnEven(counterValue);

  @override
  int getNextValue(int counterValue) => counterValue + 1;

  bool _isUnEven(int counterValue) => counterValue % 2 != 0;
}

class SkipMinMaxRule extends SkipRule {
  final int min, max;

  SkipMinMaxRule({this.min = 0, this.max = maxInt});

  @override
  bool appliesTo(int counterValue) =>
      counterValue >= min && counterValue <= max;

  @override
  int getNextValue(int counterValue) => max + 1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is SkipMinMaxRule &&
          runtimeType == other.runtimeType &&
          min == other.min &&
          max == other.max;

  @override
  int get hashCode => super.hashCode ^ min.hashCode ^ max.hashCode;

  @override
  String toString() {
    return 'SkipMinMaxRule{min: $min, max: $max}';
  }
}

/// * e or even: skips even numbers
class SkipEvenParser extends AttributeParser {
  SkipEvenParser()
      : super(
            stringIgnoreCase('e') &
                stringIgnoreCase('ven').repeat(0, 1).map((_) => SkipEvenRule()),
            Multiplicity.zeroOrOnce());
}

/// * u or uneven: skips uneven numbers
class SkipUnEvenParser extends AttributeParser {
  SkipUnEvenParser()
      : super(
            stringIgnoreCase('u') &
                stringIgnoreCase('neven')
                    .repeat(0, 1)
                    .map((_) => SkipUnEvenRule()),
            Multiplicity.zeroOrOnce());
}

/// * <number> : skips number
class SkipSingleNumberParser extends AttributeParser {
  SkipSingleNumberParser()
      : super(
            intParser.map((number) => SkipMinMaxRule(min: number, max: number)),
            Multiplicity.zeroOrMore());
}

/// * -<number> : skips up and including number
class SkipUntilParser extends AttributeParser {
  SkipUntilParser()
      : super(
            (string('-') & whiteSpaceParser.optional() & intParser)
                .map((values) => SkipMinMaxRule(max: values[2])),
            Multiplicity.zeroOrMore());
}

/// * <min>-<max> : skips all numbers between and including min and max numbers
class SkipRangeParser extends AttributeParser {
  SkipRangeParser()
      : super(
            (intParser &
                    whiteSpaceParser.optional() &
                    string('-') &
                    whiteSpaceParser.optional() &
                    intParser)
                .map(
                    (values) => SkipMinMaxRule(min: values[0], max: values[4])),
            Multiplicity.zeroOrMore());
}

class CounterTagParser extends EventTagParser {
  static final log = Logger('$EventTagParser');

  CounterTagParser()
      : super((char('[') &
                whiteSpaceParser.optional() &
                stringIgnoreCase('cnt') &
                whiteSpaceParser.optional() &
                CounterAttributesParser() &
                whiteSpaceParser.optional() &
                char(']'))
            .map((values) => _map(values)));

  static int _findArrayNumber(List<CounterAttribute> counterAttributes) {
    var arrayAttributes = counterAttributes.whereType<ArrayAttribute>();
    if (arrayAttributes.isNotEmpty) {
      if (arrayAttributes.length > 1) {
        log.warning(
            '$CounterTagParser found multiple array number attributes: $arrayAttributes');
      }
      var arrayAttribute = arrayAttributes.last;
      return arrayAttribute.number;
    } else {
      return 0;
    }
  }

  static List<SkipRule> _findSkipRules(
      List<CounterAttribute> counterAttributes) {
    List<SkipRule> skipRules = [];
    var skipAttributes = counterAttributes.whereType<SkipAttribute>();
    for (var skipAttribute in skipAttributes) {
      skipRules.addAll(skipAttribute.skipRules);
    }
    return skipRules;
  }

  static _map(List values) {
    var counterAttributes = values[4].cast<CounterAttribute>();
    var arrayNumber = _findArrayNumber(counterAttributes);
    var skipRules = _findSkipRules(counterAttributes);
    return CounterTag(arrayNumber, skipRules);
  }
}
