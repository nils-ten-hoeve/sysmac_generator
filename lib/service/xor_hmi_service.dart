import 'package:sysmac_generator/domain/sysmac_project.dart';
import 'package:sysmac_generator/infrastructure/sysmac_project.dart';

/// Generates documents from a [SysmacProjectFile]
/// TODO replace with templates
class XorHmiService {
void generateTagsFile(SysmacProject sysmacProject) {
    var variables=sysmacProject.globalVariableService.variables;
    print(variables);
  }

}
