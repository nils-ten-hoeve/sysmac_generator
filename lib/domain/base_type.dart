import 'package:fluent_regex/fluent_regex.dart';

import 'data_type.dart';

/// A [BaseType] is used in a [DataType] and refers to an internal type within
/// (Sysmac)[https://industrial.omron.eu/en/products/sysmac-platform]
abstract class BaseType {
  final List<ArrayRange> arrayRanges = [];

  @override
  String toString() {
    if (arrayRanges.isEmpty) {
      return runtimeType.toString();
    } else {
      return 'ARRAY$arrayRanges OF $runtimeType';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseType &&
          runtimeType == other.runtimeType &&
          toString() == other.toString();

  @override
  int get hashCode => toString().hashCode;
}

class ArrayRange {
  static final minName = 'min';
  static final maxName = 'max';
  static final FluentRegex _numberRegex =
      FluentRegex().digit(Quantity.oneOrMoreTimes());
  static final FluentRegex regex = FluentRegex()
      .group(_numberRegex, type: GroupType.captureNamed(minName))
      .literal('..')
      .group(_numberRegex, type: GroupType.captureNamed(maxName))
      .literal(',', Quantity.zeroOrOneTime());

  final int min;
  final int max;

  ArrayRange(String expression)
      : min = _numberFromExpression(expression, minName),
        max = _numberFromExpression(expression, maxName);

  ArrayRange.minMax(this.min, this.max);

  @override
  String toString() {
    return '$min..$max';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArrayRange &&
          runtimeType == other.runtimeType &&
          min == other.min &&
          max == other.max;

  @override
  int get hashCode => min.hashCode ^ max.hashCode;

  static _numberFromExpression(String expression, String groupName) {
    var value = regex.firstMatch(expression)!.namedGroup(groupName)!;
    return int.parse(value);
  }
}

/// A [BaseType] that refers to an existing [DataType]:
class DataTypeReference extends BaseType {
  final DataType dataType;

  DataTypeReference({
    required this.dataType,
    required List<ArrayRange> arrayRanges,
  }) {
    this.arrayRanges.addAll(arrayRanges);
  }

  /// not showing data type in to String because the DataType is shown
  /// See: [DataType.children]
// @override
// String toString() {
//   return super.toString() + '{$dataType}';
// }
}

class UnknownBaseType extends BaseType {
  final String expression;

  UnknownBaseType(this.expression);

  @override
  String toString() {
    if (arrayRanges.isEmpty) {
      return expression;
    } else {
      return 'ARRAY$arrayRanges OF $expression';
    }
  }
}

class Struct extends BaseType {}

class Enum extends BaseType {}

/// Nx PLC [BaseType] e.g.: a NJ PLC data type
/// See [https://www.myomron.com/index.php?action=kb&article=1628]
abstract class NxType extends BaseType {
  String get name =>
      runtimeType.toString().replaceFirst('Nx', '').toUpperCase();
}

class NxInt extends NxType {}

class NxDInt extends NxType {}

class NxLInt extends NxType {}

class NxUInt extends NxType {}

class NxWord extends NxType {}

class NxUDInt extends NxType {}

class NxDWord extends NxType {}

class NxULInt extends NxType {}

class NxLWord extends NxType {}

class NxReal extends NxType {}

class NxLReal extends NxType {}

class NxBool extends NxType {}

class NxString extends NxType {}

class NxSInt extends NxType {}

class NxUSInt extends NxType {}

class NxByte extends NxType {}

class NxTime extends NxType {}

class NxDate extends NxType {}

class NxDateAndType extends NxType {
  @override
  String get name => 'DATE_AND_TIME';
}

class NxTimeOfDay extends NxType {
  @override
  String get name => 'TIME_OF_DAY';
}

/// A Visual Basic [BaseType] e.g.:a HMI data type
/// See [https://www.myomron.com/index.php?action=kb&article=1628]
abstract class VbType extends BaseType {
  String get name => runtimeType.toString().replaceFirst('Vb', '');
}

class VbShort extends VbType {}

class VbInteger extends VbType {}

class VbLong extends VbType {}

class VbUShort extends VbType {}

class VbUInteger extends VbType {}

class VbULong extends VbType {}

class VbSingle extends VbType {}

class VbDouble extends VbType {}

class VbDecimal extends VbType {}

class VbBoolean extends VbType {}

class VbString extends VbType {}

class VbChar extends VbType {}

class VbSByte extends VbType {}

class VbByte extends VbType {}

class VbDateTime extends VbType {}

class VbTimeSpan extends VbType {
  @override
  String get name => 'System.TimeSpan';
}
