import 'dart:io';

import 'package:sysmac_cmd/infrastructure/sysmac/project_index.dart';
import 'package:sysmac_cmd/infrastructure/sysmac/sysmac.dart';
import 'test_resource.dart';
import 'package:test/test.dart';

main() {

  File file = SysmacProjectTestResource().file;
  var sysmacProjectFile = SysmacProjectFile(file.path);
  ProjectIndexXml projectIndexXml = sysmacProjectFile.projectIndexXml;

  group('class: ProjectIndexXml', () {
    group('method: findDataTypeArchiveFiles', () {
      test('not empty', () {
        var dataTypeArchiveFiles =projectIndexXml.dataTypeArchiveXmlFiles();
        expect(dataTypeArchiveFiles, isNotEmpty) ;
      });
    });
    group('method: findDataTypeArchiveFiles', () {
      test('not empty', () {
        var globalVariableArchiveFiles =projectIndexXml.globalVariableArchiveXmlFiles();
        expect(globalVariableArchiveFiles, isNotEmpty) ;
      });
    });
  });
}
