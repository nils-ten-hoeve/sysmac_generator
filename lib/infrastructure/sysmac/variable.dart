import 'package:archive/archive.dart';
import 'package:sysmac_cmd/domain/data_type.dart';
import 'package:sysmac_cmd/infrastructure/sysmac/sysmac.dart';
import 'package:xml/xml.dart';

import 'base_type.dart';

const String nameSpacePathSeparator = '\\';
const String nameAttribute = 'Name';
const String dataTypeNameAttribute = 'DataTypeName';
const String commentAttribute = 'Comment';

class GlobalVariableService {
  final SysmacProjectFile sysmacProjectFile;
  static final eventGlobalVariableName = 'EventGlobal';

  GlobalVariableService(this.sysmacProjectFile);

  List<Variable> get variables {
    var projectIndexXml = sysmacProjectFile.projectIndexXml;

    var archiveXmlFiles = projectIndexXml.globalVariableArchiveXmlFiles();

    List<Variable> variables = [];
    for (var variableArchiveXmlFile in archiveXmlFiles) {
      variables.addAll(variableArchiveXmlFile.toVariables());
    }
    return variables;
  }

  List<Variable> findVariablesByName(String nameToFind) =>
      variables.where((variable) => variable.name == nameToFind).toList();

  List<Variable> findVariablesWithEventGlobalName() =>
      findVariablesByName(eventGlobalVariableName);
}

/// Represents an [ArchiveXml] with information of some [Variable]s within a given [nameSpacePath]
class GlobalVariableArchiveXmlFile extends ArchiveXml {
  final SysmacProjectFile sysmacProjectFile;
  final String nameSpacePath;
  final BaseTypeFactory baseTypeFactory = BaseTypeFactory();
  final DataTypeReferenceFactory dataTypeReferenceFactory = DataTypeReferenceFactory();

  GlobalVariableArchiveXmlFile.fromArchiveFile({
    required this.sysmacProjectFile,
    required this.nameSpacePath,
    required ArchiveFile archiveFile,
  }) : super.fromArchiveFile(archiveFile);

  GlobalVariableArchiveXmlFile.fromXml({
    required this.sysmacProjectFile,
    required this.nameSpacePath,
    required String xml,
  }) : super.fromXml(xml);

  List<Variable> toVariables() {
    var dataElement = xmlDocument.firstElementChild!;
    var variableRootElement = dataElement.firstElementChild!;
    return variableRootElement.children
        .where((node) => isVariableElement(node))
        .map((node) => _createVariable(node))
        .toList();
  }

  Variable _createVariable(XmlNode variableElement) {
    String name = variableElement.getAttribute(nameAttribute)!;
    String baseTypeExpression =
    variableElement.getAttribute(dataTypeNameAttribute)!;
    BaseType baseType = _findBaseType(baseTypeExpression);
    String comment = variableElement.getAttribute(commentAttribute)!;
    var variable = Variable(
      name: name,
      baseType: baseType,
      comment: comment,
    );

    // recursively creating children
    var children = variableElement.children
        .where((node) => isVariableElement(node))
        .map((node) => _createVariable(node))
        .toList();
    variable.children.addAll(children);

    return variable;
  }

  bool isVariableElement(XmlNode node) =>
      node is XmlElement && node.name.local == 'Variable';

  BaseType _findBaseType(String baseTypeExpression) {
    var baseType = baseTypeFactory.createFromExpression(baseTypeExpression);
    if (baseType is UnknownBaseType) {
      var dataTypeReference=dataTypeReferenceFactory.createFromUnknownDataType(sysmacProjectFile.dataTypeTree, baseType);
      if (dataTypeReference!=null) {
        return dataTypeReference;
      }
    }
    return baseType;
  }
}

class Variable extends NameSpace {
  final String comment;
  BaseType baseType;

  Variable({
    required String name,
    required this.baseType,
    required this.comment,
  }) : super(name);

  @override
  List<NameSpace> get children {
    if (baseType is DataTypeReference) {
      return [(baseType as DataTypeReference).dataType];
    } else {
      return super.children;
    }
  }


  @override
  String toString() {
    String string =
        '$Variable{name: $name, comment: $comment, dataType: $baseType}';
    for (var child in children) {
      var lines = child.toString().split('\n');
      for (var line in lines) {
        string += "\n  $line";
      }
    }
    return string;
  }
}
