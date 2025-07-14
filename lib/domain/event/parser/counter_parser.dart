import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:petitparser/parser.dart';
import 'package:sysmac_generator/domain/event/event.dart';
import 'package:sysmac_generator/domain/event/parser/attribute_parser.dart';
import 'package:sysmac_generator/infrastructure/event.dart';

import 'event_parser.dart';
import 'generic_parsers.dart';

/// You can use [CounterTag]s when the data type uses an array.
/// [CounterTag]'s are replaced with a counter value.
/// This counter increases every time one of the array values changes.
///
///  * Format: [cnt &lt;comma separated attributes&gt;]

class CounterTag extends EventTag
    implements
        EventCommentRenderer,
        ArrayCounterOnNextListener,
        ArrayCounterOnResetListener {
  /// array: 1= last [ArrayCounter], 2= preceding [ArrayCounter], 3= etc
  final int array;
  final List<SkipRule> skipRules;
  int value = -1;
  final bool resetWhenArrayCounterResets;

  CounterTag(
      {this.array = 1,
      required this.skipRules,
      this.resetWhenArrayCounterResets = true});

  // {
  //  onNext();
  // }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterTag &&
          runtimeType == other.runtimeType &&
          array == other.array &&
          const ListEquality().equals(skipRules, other.skipRules) &&
          value == other.value &&
          resetWhenArrayCounterResets == other.resetWhenArrayCounterResets;

  @override
  int get hashCode =>
      array.hashCode ^
      skipRules.hashCode ^
      value.hashCode ^
      resetWhenArrayCounterResets.hashCode;

  @override
  String toString() {
    return 'CounterTag{array: $array, skipRules: $skipRules, value: $value, resetWhenArrayCounterResets: $resetWhenArrayCounterResets}';
  }

  @override
  String render() => value.toString();

  @override
  void initListeners(EventFactory eventFactory) {
    var arrayCounters = eventFactory.arrayCountersInReverseOrder;
    if (array <= arrayCounters.length) {
      var arrayCounter = arrayCounters[array - 1];
      arrayCounter.onNextListeners.add(this);
      arrayCounter.onResetListeners.add(this);
    }
  }

  /// called by [ArrayValues] any time a new array value is needed
  @override
  void onNext() {
    value++;
    while (skipRules.any((skipRule) => skipRule.appliesTo(value))) {
      var skipRule =
          skipRules.firstWhere((skipRule) => skipRule.appliesTo(value));
      value = skipRule.getNextValue(value);
    }
  }

  /// called by [ArrayValues] any time a new array value is needed
  /// and the array value starts from the lowest value
  @override
  void onReset() {
    if (resetWhenArrayCounterResets) {
      value = -1;
      onNext();
    }
  }
}

class CounterAttributesParser extends AttributesParser {
  CounterAttributesParser()
      : super([
          ArrayAttributeParser(),
          ContinueAttributeParser(),
          SkipAttributeParser()
        ]);
}

abstract class CounterAttribute {}

///
///  * array=&lt;array number&gt; is optional:
///    * array number is a negative number and indicates on which previous array the counter increases.
///    * no [ArrayAttribute] or array=-1: counter increases when the last array value increases
///    * array=-2: counter increases when the 2nd last array value increases
///    * array=-3: counter increases when the 3rd last array value increases
///    * etc..
class ArrayAttribute extends CounterAttribute {
  /// array=-1: number=1
  /// array=-2: number=2
  /// etc...
  final int number;

  ArrayAttribute({int number = 1}) : number = (number > 0) ? number : 1;

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
                    string('-') &
                    intParser)
                .map((values) => ArrayAttribute(number: values[5])),
            Multiplicity.zeroOrOnce());
}

///
///  * &lt;cont&gt; or &lt;continue&gt; is optional.
///    * When the [CounterTag] contains a [ContinueAttribute]:
///      The counter restarts counting when the [ArrayCounter] restarts counting.
///    * When the [CounterTag] does not contain a [ContinueAttribute]:
///      The counter keeps counting when the [ArrayCounter] restarts counting.
class ContinueAttribute extends CounterAttribute {
  ContinueAttribute();
}

class ContinueAttributeParser extends AttributeParser {
  ContinueAttributeParser()
      : super(
            (stringIgnoreCase('cont') & stringIgnoreCase('inue').optional())
                .map((values) => ContinueAttribute()),
            Multiplicity.zeroOrOnce());
}

///
///  * skip=&lt;skip rules&gt; are optional and can be used to skip numbers:
///    * skip=e : skips even numbers
///    * skip=even : skips even numbers
///    * skip=u : skips uneven numbers
///    * skip=uneven : skips uneven numbers
///    * skip=0 : skips a number, in this case 0 is skipped so the counter starts at 1
///    * skip=-2 : skips up to a number, in this case numbers 0,1 and 3 are skipped
///    * skip=3-5: skips a range of numbers, in this case numbers 3,4 and 5 are skipped
///  * You can combine the skip rules above by separating them with a comma, e.g.:
///    * skip=e,5: skips even counter values and counter value 5
///    * skip=2,4: skips counter value 2 and counter value 4
///    * skip=2-4,8: skips counter value 2-4 and counter value 8
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

  bool _isSkipEvenOrUnEvenRule(SkipRule skipRule) =>
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

/// skip=e or skip=even: skips even numbers
class SkipEvenParser extends AttributeParser {
  SkipEvenParser()
      : super(
            stringIgnoreCase('e') &
                stringIgnoreCase('ven').repeat(0, 1).map((_) => SkipEvenRule()),
            Multiplicity.zeroOrOnce());
}

/// skip=u or skip=uneven: skips uneven numbers,
class SkipUnEvenParser extends AttributeParser {
  SkipUnEvenParser()
      : super(
            stringIgnoreCase('u') &
                stringIgnoreCase('neven')
                    .repeat(0, 1)
                    .map((_) => SkipUnEvenRule()),
            Multiplicity.zeroOrOnce());
}

/// skip=&lt;number&gt; : skips a number,
/// e.g.: The counters always start at 0. Use skip=0, if you want the counter to start at 1.
class SkipSingleNumberParser extends AttributeParser {
  SkipSingleNumberParser()
      : super(
            intParser.map((number) => SkipMinMaxRule(min: number, max: number)),
            Multiplicity.zeroOrMore());
}

/// skip=-&lt;number&gt; : skips up and including number,
/// e.g.: skip=-4 will start at 5
class SkipUntilParser extends AttributeParser {
  SkipUntilParser()
      : super(
            (string('-') & whiteSpaceParser.optional() & intParser)
                .map((values) => SkipMinMaxRule(max: values[2])),
            Multiplicity.zeroOrMore());
}

/// skip=&lt;min&gt;-&lt;max&gt; : skips all numbers between the given range,
/// e.g.: skip 2-4 will skip numbers 2, 3 and 4
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
      return 1;
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

  static bool _findContinues(List<CounterAttribute> counterAttributes) =>
      counterAttributes
          .any((counterAttribute) => counterAttribute is ContinueAttribute);

  static CounterTag _map(List values) {
    var counterAttributes = values[4].cast<CounterAttribute>();
    var arrayNumber = _findArrayNumber(counterAttributes);
    var continues = _findContinues(counterAttributes);
    var skipRules = _findSkipRules(counterAttributes);
    return CounterTag(
        array: arrayNumber,
        skipRules: skipRules,
        resetWhenArrayCounterResets: !continues);
  }
}
