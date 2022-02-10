import '../infrastructure/variable.dart';
import 'data_type.dart';

/// Represents a physical Sysmac project file,
/// which is actually a zip [Archive] containing [ArchiveFile]s
class SysmacProject {
  final DataTypeTree dataTypeTree;
  final GlobalVariableService globalVariableService;

  SysmacProject(
      {required this.dataTypeTree, required this.globalVariableService});
}
