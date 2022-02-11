import 'dart:io';

import 'package:sysmac_cmd/infrastructure/sysmac_project.dart';
import 'package:test/test.dart';

import 'test_resource.dart';

main() {
  File file = SysmacProjectTestResource().file;
  var sysmacProject = SysmacProjectFactory().create(file.path);
  var eventGlobalVariables =
      sysmacProject.globalVariableService.findVariablesWithEventGlobalName();

  group('class: EventService', () {
    test('variables isNot Empty', () {
      expect( sysmacProject.eventService
                    .createFromVariable(eventGlobalVariables).isNotEmpty
              , true
          );
    });
  });
}
