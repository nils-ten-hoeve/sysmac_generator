import 'package:collection/collection.dart';
import 'package:fluent_regex/fluent_regex.dart';

import '../domain/base_type.dart';
import '../domain/data_type.dart';
import '../domain/namespace.dart';

class BaseTypeFactory {
  BaseTypeSubFactories baseTypeSubFactories = BaseTypeSubFactories();

  BaseType createFromExpression(String expression) {
    var factory = baseTypeSubFactories
        .firstWhere((factory) => factory.regex.hasMatch(expression));
    return factory.create(expression);
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

class UnknownBaseTypeFactory extends BaseTypeSubFactory {
  @override
  RegExp get regex => FluentRegex().anyCharacter(Quantity.oneOrMoreTimes());

  @override
  BaseType create(String expression) => UnknownBaseType(expression);
}

class StructFactory extends BaseTypeSubFactory {
  final Struct _struct = Struct();
  final RegExp _regex =
      FluentRegex().startOfLine().literal('$Struct'.toUpperCase()).endOfLine();

  @override
  RegExp get regex => _regex;

  @override
  BaseType create(String expression) => _struct;
}

class EnumFactory extends BaseTypeSubFactory {
  final Enum _enum = Enum();
  final RegExp _regex =
      FluentRegex().startOfLine().literal('$Enum'.toUpperCase()).endOfLine();

  @override
  RegExp get regex => _regex;

  @override
  BaseType create(String expression) => _enum;
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

class DataTypeReferenceFactory {
  /// Replaces all the [UnknownBaseType]s with [DataTypeReference]s
  /// when the path can be found
  void replaceWherePossible(DataTypeTree dataTypeTree) {
    for (NameSpace child in dataTypeTree.descendants) {
      if (child is DataType) {
        var baseType = child.baseType;
        if (baseType is UnknownBaseType) {
          var dataTypeReference =
              createFromUnknownDataType(dataTypeTree, baseType);
          if (dataTypeReference != null) {
            child.baseType = dataTypeReference;
          }
        }
      }
    }
  }

  DataTypeReference? createFromUnknownDataType(
      DataTypeTree dataTypeTree, UnknownBaseType baseType) {
    String path = baseType.expression;
    var referencedDataType = dataTypeTree.findNamePathString(path);
    if (referencedDataType != null && referencedDataType is DataType) {
      var arrayRanges = baseType.arrayRanges;
      return DataTypeReference(
        dataType: referencedDataType,
        arrayRanges: arrayRanges,
      );
    } else {
      return null;
    }
  }
}
