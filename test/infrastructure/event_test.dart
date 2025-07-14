import 'dart:io';

import 'package:sysmac_generator/infrastructure/sysmac_project.dart';
import 'package:test/test.dart';

import 'test_resource.dart';

void main() {
  File file = SysmacProjectTestResource().file;
  var sysmacProject = SysmacProjectFactory().create(file.path);

  group('class: EventService', () {
    test('variables isNot Empty', () {
      var result = sysmacProject.eventService.eventGroups;
      expect(result.isNotEmpty, true);
    });
  });
}
