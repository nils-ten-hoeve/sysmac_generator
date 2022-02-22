import 'package:archive/archive.dart';
import 'package:sysmac_generator/domain/data_type.dart';
import 'package:xml/xml.dart';

import '../domain/base_type.dart';
import '../domain/variable.dart';
import 'base_type.dart';
import 'sysmac_project.dart';

const String nameSpacePathSeparator = '\\';
const String nameAttribute = 'Name';
const String dataTypeNameAttribute = 'DataTypeName';
const String commentAttribute = 'Comment';

class GlobalVariableService {
  final SysmacProjectArchive sysmacProjectArchive;
  final DataTypeTree dataTypeTree;
  static final eventGlobalVariableName = 'EventGlobal';

  GlobalVariableService(this.sysmacProjectArchive, this.dataTypeTree);

  List<Variable> get variables {
    var projectIndexXml = sysmacProjectArchive.projectIndexXml;

    var archiveXmlFiles =
        projectIndexXml.globalVariableArchiveXmlFiles(dataTypeTree);

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
  final DataTypeTree dataTypeTree;
  final String nameSpacePath;
  final BaseTypeFactory baseTypeFactory = BaseTypeFactory();
  final DataTypeReferenceFactory dataTypeReferenceFactory =
      DataTypeReferenceFactory();

  GlobalVariableArchiveXmlFile.fromArchiveFile({
    required this.dataTypeTree,
    required this.nameSpacePath,
    required ArchiveFile archiveFile,
  }) : super.fromArchiveFile(archiveFile);

  GlobalVariableArchiveXmlFile.fromXml({
    required this.dataTypeTree,
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
      var dataTypeReference = dataTypeReferenceFactory
          .createFromUnknownDataType(dataTypeTree, baseType);
      if (dataTypeReference != null) {
        return dataTypeReference;
      }
    }
    return baseType;
  }
}
