import 'package:sysmac_generator/infrastructure/event.dart';

import '../infrastructure/variable.dart';
import 'data_type.dart';

/// Represents a physical Sysmac project file,
/// which is actually a zip [Archive] containing [ArchiveFile]s
class SysmacProject {
  final DataTypeTree dataTypeTree;
  final GlobalVariableService globalVariableService;
  final EventService eventService;

  SysmacProject(
      {required this.dataTypeTree,
      required this.globalVariableService,
      required this.eventService});
}
