import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import '../domain/sysmac_project.dart';
import 'data_type.dart';
import 'event.dart';
import 'project_index.dart';
import 'variable.dart';
import 'package:petitparser/petitparser.dart';

class SysmacProjectFactory {
  SysmacProject create(String sysmacProjectFilePath) {
    var sysmacProjectArchive = SysmacProjectArchive(sysmacProjectFilePath);
    var dataTypeTree = DataTypeTreeFactory().create(sysmacProjectArchive);
    var globalVariableService =
    GlobalVariableService(sysmacProjectArchive, dataTypeTree);

    var parsedFileName = _parseFileName(sysmacProjectFilePath);
    var site = _createSite(parsedFileName);
    var electricPanel = _createElectricPanel(parsedFileName);
    var sysmacProjectVersion = _createSysmacProjectVersion(
        parsedFileName);
    var eventService = EventService(
      site: site,
      electricPanel: electricPanel,
    );
    return SysmacProject(
      site: site,
      electricPanel: electricPanel,
      sysmacProjectVersion: sysmacProjectVersion,
      dataTypeTree: dataTypeTree,
      globalVariableService: globalVariableService,
      eventService: eventService,
    );
  }

  _createSite(List<dynamic> parsedFileName) {
    int siteNumber = parsedFileName[1] as int;
    return Site(siteNumber);
  }

  _createElectricPanel(List<dynamic> parsedFileName) {
    int number = parsedFileName[3] as int;
    String name = parsedFileName[5] as String;
    return ElectricPanel(number: number, name: name);
  }

  List<dynamic> _parseFileName(String sysmacProjectFilePath) {
    var result = _fileNameParser.parse(sysmacProjectFilePath);
    if (result.isFailure) {
      try {
        result.value;
      } on Exception catch (e) {
        throw Exception('Incorrect file name: "$sysmacProjectFilePath". $e');
      }
    }
    return result.value;
  }

  SysmacProjectVersion _createSysmacProjectVersion(List parsedFileName) =>
      SysmacProjectVersion(standardVersion: parsedFileName[7] as int,
        customerVersion: parsedFileName[9] as int,
        notInstalledComment: parsedFileName[10],);

}

var _pathSeparatorParser = char('\\') | char('/');

var _pathParser = (any().starGreedy(
    _pathSeparatorParser) & _pathSeparatorParser).flatten().optional();

var _numberParser = digit().plus().flatten().trim().map(int.parse);

var _deParser = stringIgnoreCase('de');

var _dashParser = char('-');

var _panelNameParser = any().plusLazy(_dashParser).flatten();

var _versionSuffixParser = any().starLazy(_extensionParser).flatten();

var _extensionParser = stringIgnoreCase('.smc2').end();

var _fileNameParser = _pathParser & _numberParser & _deParser & _numberParser & _dashParser & _panelNameParser & _dashParser & _numberParser & _dashParser & _numberParser & _versionSuffixParser & _extensionParser;


/// Represents a physical Sysmac project file,
/// which is actually a zip [Archive] containing [ArchiveFile]s
class SysmacProjectArchive {
  static String extension = 'smc2';

  late ProjectIndexXml projectIndexXml;

  SysmacProjectArchive(String sysmacProjectFilePath) {
    _validateNotEmpty(sysmacProjectFilePath);
    final file = File(sysmacProjectFilePath);
    _validateExtension(file);
    _validateExists(file);
    Archive archive = readArchive(file);
    projectIndexXml = ProjectIndexXml(archive);
  }

  _validateExtension(File file) {
    if (!file.path.toLowerCase().endsWith(".$extension")) {
      throw ArgumentError(
          "does not end with .$extension extension", 'sysmacProjectFilePath');
    }
  }

  _validateExists(File file) {
    if (!file.existsSync()) {
      throw ArgumentError('does not point to a existing Sysmac project file',
          'sysmacProjectFilePath');
    }
  }

  _validateNotEmpty(String sysmacProjectFilePath) {
    if (sysmacProjectFilePath
        .trim()
        .isEmpty) {
      throw ArgumentError('may not be empty', 'sysmacProjectFilePath');
    }
  }

  Archive readArchive(File file) {
    final bytes = file.readAsBytesSync();
    return ZipDecoder().decodeBytes(bytes);
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
