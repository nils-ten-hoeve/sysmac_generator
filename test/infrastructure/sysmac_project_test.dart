import 'dart:io';

import 'package:sysmac_generator/domain/sysmac_project.dart';
import 'package:sysmac_generator/infrastructure/sysmac_project.dart';
import 'package:test/test.dart';

import 'test_resource.dart';

main() {
  group('class: $SysmacProjectFactory', () {
    group('constructor', () {
      test('empty path should throw error', () {
        expect(
            () => SysmacProjectFactory().create(''),
            throwsA(predicate(
                (e) => e is ArgumentError && e.message == 'may not be empty')));
      });
      test('path without extension should throw error', () {
        expect(
            () => SysmacProjectFactory().create('sysmacProjectFile'),
            throwsA(predicate((e) =>
                e is ArgumentError &&
                e.message == 'does not end with .smc2 extension')));
      });
      test('path that does not exist should throw error', () {
        expect(
            () => SysmacProjectFactory()
                .create('sysmacProjectFile.${SysmacProjectArchive.extension}'),
            throwsA(predicate((e) =>
                e is ArgumentError &&
                e.message ==
                    'does not point to a existing Sysmac project file')));
      });
      test('Successful creation using a correct path', () {
        File file = SysmacProjectTestResource().file;
        expect(SysmacProjectFactory().create(file.path).toString(),
            'Instance of \'$SysmacProject\'');
      });
    });

    File file = SysmacProjectTestResource().file;
    var sysmacProjectFile = SysmacProjectFactory().create(file.path);

    group('property: dataTypeTree', () {
      test('finds populated dataTypeTree', () {
        var dataTypeTree = sysmacProjectFile.dataTypeTree;
        expect(dataTypeTree.children.length, 330);
      });
    });

    group('property: globalVariableService', () {
      test('finds globalVariableService with variable', () {
        var globalVariableService = sysmacProjectFile.globalVariableService;
        expect(globalVariableService.variables.length, 48);
      });
    });
  });
}
