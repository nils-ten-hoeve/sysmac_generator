import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:sysmac_cmd/infrastructure/sysmac/project_index.dart';
import 'package:sysmac_cmd/infrastructure/sysmac/variable.dart';
import 'package:xml/xml.dart';

import 'data_type.dart';

/// Represents a physical Sysmac project file,
/// which is actually a zip [Archive] containing [ArchiveFile]s
class SysmacProjectFile {
  static String extension = 'smc2';
  final Archive archive;
  ProjectIndexXml? _cachedProjectIndexXml;
  DataTypeTree? _cachedDataTypeTree;
  GlobalVariableService? _cachedVariableTree;

  SysmacProjectFile(String sysmacProjectFilePath)
      : archive = _createArchive(sysmacProjectFilePath);

  static _validateExtension(File file) {
    if (!file.path.toLowerCase().endsWith(".$extension")) {
      throw ArgumentError(
          "does not end with .$extension extension", 'sysmacProjectFilePath');
    }
  }

  static _validateExists(File file) {
    if (!file.existsSync()) {
      throw ArgumentError('does not point to a existing Sysmac project file',
          'sysmacProjectFilePath');
    }
  }

  static void _validateNotEmpty(File file) {
    if (file.path.trim().isEmpty) {
      throw ArgumentError('may not be empty', 'sysmacProjectFilePath');
    }
  }

  static Archive _createArchive(String sysmacProjectFilePath) {
    final file = File(sysmacProjectFilePath);
    _validateNotEmpty(file);
    _validateExtension(file);
    _validateExists(file);
    final bytes = file.readAsBytesSync();
    return ZipDecoder().decodeBytes(bytes);
  }

  ProjectIndexXml get projectIndexXml {
    _cachedProjectIndexXml ??= ProjectIndexXml(this);
    return _cachedProjectIndexXml!;
  }

  DataTypeTree get dataTypeTree {
    _cachedDataTypeTree ??= DataTypeTree(this);
    return _cachedDataTypeTree!;
  }

  GlobalVariableService get variableTree {
    _cachedVariableTree ??= GlobalVariableService(this);
    return _cachedVariableTree!;
  }
}

/// Parses the XML of an [ArchiveFile] inside a [SysmacProjectFile]
/// to an [XmlDocument] and can convert it to more meaningful domain objects
abstract class ArchiveXml {
  final XmlDocument xmlDocument;

  ArchiveXml.fromArchiveFile(ArchiveFile archiveFile)
      : this.fromXml(_convertContentToUtf8(archiveFile));

  ArchiveXml.fromXml(String xml) : xmlDocument = XmlDocument.parse(xml);

  static String _convertContentToUtf8(ArchiveFile archiveFile) {
    var content = archiveFile.content;
    return utf8.decode(content);
  }
}
