import 'package:collection/collection.dart';
import 'package:fluent_regex/fluent_regex.dart';
import 'package:sysmac_cmd/domain/data_type.dart';
import 'package:sysmac_cmd/infrastructure/sysmac/data_type.dart';

class BaseTypeFactory {
  BaseTypeSubFactories baseTypeSubFactories = BaseTypeSubFactories();

  BaseType createFromExpression(String expression) {
    var factory = baseTypeSubFactories
        .firstWhere((factory) => factory.regex.hasMatch(expression));
    return factory.create(expression);
  }
}

/// A [BaseType] is used in a [DataType] and refers to an internal type within
/// (Sysmac)[https://industrial.omron.eu/en/products/sysmac-platform]
abstract class BaseType {
  final List<ArrayRange> arrayRanges = [];

  @override
  String toString() {
    if (arrayRanges.isEmpty) {
      return runtimeType.toString();
    } else {
      return arrayRanges.toString() + runtimeType.toString();
    }
  }
}

abstract class BaseTypeSubFactory {
  RegExp get regex;

  BaseType create(String expression);
}

class BaseTypeSubFactories extends DelegatingList<BaseTypeSubFactory> {
  BaseTypeSubFactories()
      : super([
          ArrayFactory(),
          StructFactory(),
          EnumFactory(),
          ...NxTypeFactories(),
          ...VbTypeFactories(),
          UnknownBaseTypeFactory(),
        ]);
}

class UnknownBaseType extends BaseType {
  final String expression;

  UnknownBaseType(this.expression);

  @override
  String toString() {
    return 'UnknownBaseType{expression: $expression}';
  }
}

class UnknownBaseTypeFactory extends BaseTypeSubFactory {
  @override
  RegExp get regex => FluentRegex().anyCharacter(Quantity.oneOrMoreTimes());

  @override
  BaseType create(String expression) => UnknownBaseType(expression);
}

class Struct extends BaseType {}

class StructFactory extends BaseTypeSubFactory {
  final Struct _struct = Struct();
  final RegExp _regex =
      FluentRegex().startOfLine().literal('$Struct'.toUpperCase()).endOfLine();

  @override
  RegExp get regex => _regex;

  @override
  BaseType create(String expression) => _struct;
}

class Enum extends BaseType {}

class EnumFactory extends BaseTypeSubFactory {
  final Enum _enum = Enum();
  final RegExp _regex =
      FluentRegex().startOfLine().literal('$Enum'.toUpperCase()).endOfLine();

  @override
  RegExp get regex => _regex;

  @override
  BaseType create(String expression) => _enum;
}

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

class NxTypeFactory extends BaseTypeSubFactory {
  final NxType _nxType;
  final RegExp _regex;

  NxTypeFactory(this._nxType)
      : _regex = FluentRegex().startOfLine().literal(_nxType.name).endOfLine();

  @override
  NxType create(String expression) => _nxType;

  @override
  RegExp get regex => _regex;
}

class NxTypeFactories extends DelegatingList<NxTypeFactory> {
  NxTypeFactories()
      : super([
          NxTypeFactory(NxInt()),
          NxTypeFactory(NxDInt()),
          NxTypeFactory(NxLInt()),
          NxTypeFactory(NxUInt()),
          NxTypeFactory(NxWord()),
          NxTypeFactory(NxUDInt()),
          NxTypeFactory(NxDWord()),
          NxTypeFactory(NxULInt()),
          NxTypeFactory(NxLWord()),
          NxTypeFactory(NxReal()),
          NxTypeFactory(NxLReal()),
          NxTypeFactory(NxBool()),
          NxTypeFactory(NxString()),
          NxTypeFactory(NxSInt()),
          NxTypeFactory(NxUSInt()),
          NxTypeFactory(NxByte()),
          NxTypeFactory(NxTime()),
          NxTypeFactory(NxDate()),
          NxTypeFactory(NxDateAndType()),
          NxTypeFactory(NxTimeOfDay()),
        ]);
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

class VbTypeFactory extends BaseTypeSubFactory {
  final VbType _vbType;
  final RegExp _regex;

  VbTypeFactory(this._vbType)
      : _regex = FluentRegex().startOfLine().literal(_vbType.name).endOfLine();

  @override
  VbType create(String expression) => _vbType;

  @override
  RegExp get regex => _regex;
}

class VbTypeFactories extends DelegatingList<VbTypeFactory> {
  VbTypeFactories()
      : super([
          VbTypeFactory(VbShort()),
          VbTypeFactory(VbInteger()),
          VbTypeFactory(VbLong()),
          VbTypeFactory(VbUShort()),
          VbTypeFactory(VbUInteger()),
          VbTypeFactory(VbULong()),
          VbTypeFactory(VbSingle()),
          VbTypeFactory(VbDouble()),
          VbTypeFactory(VbDecimal()),
          VbTypeFactory(VbBoolean()),
          VbTypeFactory(VbString()),
          VbTypeFactory(VbChar()),
          VbTypeFactory(VbSByte()),
          VbTypeFactory(VbByte()),
          VbTypeFactory(VbDateTime()),
          VbTypeFactory(VbTimeSpan()),
        ]);
}

class ArrayFactory extends BaseTypeSubFactory {
  static final rangeName = 'range';
  static final typeName = 'type';
  static final RegExp _regex = FluentRegex()
      .startOfLine()
      .literal('ARRAY')
      .literal('[')
      .group(ArrayRange.regex,
          type: GroupType.captureNamed(rangeName),
          quantity: Quantity.oneOrMoreTimes())
      .literal('] OF ')
      .group(
          FluentRegex().characterSet(
              CharacterSet().addLetters(CaseType.lowerAndUpper),
              Quantity.oneOrMoreTimes()),
          type: GroupType.captureNamed(typeName));

  @override
  BaseType create(String expression) {
    var baseType = _createBaseType(expression);
    var arrayRanges = _createArrayRanges(expression);
    baseType.arrayRanges.addAll(arrayRanges);
    return baseType;
  }

  BaseType _createBaseType(String expression) {
    var typeExpression = _regex.firstMatch(expression)!.namedGroup(typeName)!;
    return BaseTypeFactory().createFromExpression(typeExpression);
  }

  List<ArrayRange> _createArrayRanges(String expression) {
    var rangeExpressions = ArrayRange.regex.allMatches(expression);
    return rangeExpressions
        .map(
            (match) => ArrayRange(expression.substring(match.start, match.end)))
        .toList();
  }

  @override
  RegExp get regex => _regex;
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

  @override
  String toString() {
    return '$min..$max';
  }

  static _numberFromExpression(String expression, String groupName) {
    var value = regex.firstMatch(expression)!.namedGroup(groupName)!;
    return int.parse(value);
  }
}

/// A [BaseType] that refers to an existing [DataType]:
class DataTypeReference extends BaseType {
  final DataType dataType;

  DataTypeReference(this.dataType, List<ArrayRange> arrayRanges) {
    this.arrayRanges.addAll(arrayRanges);
  }

  @override
  String toString() {
    return super.toString()+ '{$dataType}';
  }
}

class DataTypeReferenceFactory {
  /// Replaces all the [UnknownBaseType]s with [DataTypeReference]s
  /// when the path can be found
  void replaceWherePossible(DataTypeTree dataTypeTree) {
    for (NameSpace child in dataTypeTree.descendants) {
      if (child is DataType) {
        var baseType = child.baseType;
        if (baseType is UnknownBaseType) {
          var dataTypeReference=createFromUnknownDataType(dataTypeTree, baseType);
          if (dataTypeReference!=null) {
            child.baseType=dataTypeReference;
          }
        }
      }
    }
  }

  DataTypeReference? createFromUnknownDataType(DataTypeTree dataTypeTree, UnknownBaseType baseType) {
    String path = baseType.expression;
    var referencedDataType = dataTypeTree.findNamePathString(path);
    if (referencedDataType != null && referencedDataType is DataType) {
      var arrayRanges = baseType.arrayRanges;
      return DataTypeReference(referencedDataType, arrayRanges);
    } else {
      return null;
    }
  }
}
