import 'dart:io';

import 'package:sysmac_cmd/infrastructure/sysmac/sysmac.dart';
import 'test_resource.dart';
import 'package:test/test.dart';

main() {
  group('class: SysmacProjectFile', () {
    group('constructor', () {
      test('empty path should throw error', () {
        expect(
            () => SysmacProjectFile(''),
            throwsA(predicate(
                (e) => e is ArgumentError && e.message == 'may not be empty')));
      });
      test('path without extension should throw error', () {
        expect(
            () => SysmacProjectFile('sysmacProjectFile'),
            throwsA(predicate((e) =>
                e is ArgumentError &&
                e.message == 'does not end with .smc2 extension')));
      });
      test('path that does not exist should throw error', () {
        expect(
            () => SysmacProjectFile(
                'sysmacProjectFile.${SysmacProjectFile.extension}'),
            throwsA(predicate((e) =>
                e is ArgumentError &&
                e.message ==
                    'does not point to a existing Sysmac project file')));
      });
      test('Successful creation using a correct path', () {
        File file = SysmacProjectTestResource().file;
        expect(SysmacProjectFile(file.path).toString(), 'Instance of \'SysmacProjectFile\'');
      });
    });

    File file = SysmacProjectTestResource().file;
    var sysmacProjectFile = SysmacProjectFile(file.path);

    group('property: projectIndexXml', () {
      test('oemXml is not null', () {
        var projectIndexXml =sysmacProjectFile.projectIndexXml;
        expect(projectIndexXml, isNotNull) ;
      });
    });

    group('property: dataTypes', () {
      test('finds dataTypes', () {
        var dataTypeTree =sysmacProjectFile.dataTypeTree;
        expect(dataTypeTree.children.length, 330) ;
      });
    });
  });
}
