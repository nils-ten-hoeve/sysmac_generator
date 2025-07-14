import 'dart:io';

import 'package:sysmac_generator/domain/data_type.dart';
import 'package:sysmac_generator/infrastructure/data_type.dart';
import 'package:sysmac_generator/infrastructure/project_index.dart';
import 'package:sysmac_generator/infrastructure/sysmac_project.dart';

import 'test_resource.dart';
import 'package:test/test.dart';

void main() {
  File file = SysmacProjectTestResource().file;
  var sysmacProjectArchive = SysmacProjectArchive(file.path);
  ProjectIndexXml projectIndexXml = sysmacProjectArchive.projectIndexXml;
  DataTypeTree dataTypeTree =
      DataTypeTreeFactory().create(sysmacProjectArchive);

  group('class: ProjectIndexXml', () {
    group('method: findDataTypeArchiveFiles', () {
      test('not empty', () {
        var dataTypeArchiveFiles = projectIndexXml.dataTypeArchiveXmlFiles();
        expect(dataTypeArchiveFiles, isNotEmpty);
      });
    });
    group('method: findDataTypeArchiveFiles', () {
      test('not empty', () {
        var globalVariableArchiveFiles =
            projectIndexXml.globalVariableArchiveXmlFiles(dataTypeTree);
        expect(globalVariableArchiveFiles, isNotEmpty);
      });
    });
  });
}
