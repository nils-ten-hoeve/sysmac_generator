import 'infrastructure/sysmac_project.dart';
import 'service/event_service.dart';

/// sysmac_cmd is a command line tool to help you as a developer to do tedious
/// tasks with [Omron Sysmac projects](https://automation.omron.com/en/us/products/family/sysstdio).
void main(List<String> arguments) {
  if (arguments.length == 1) {
    generateExcelFile(arguments[1]);
  } else {
    showInfo();
  }
}

void generateExcelFile(String sysmacProjectFilePath) {
  try {
    EventService().generateForSysmacHmi(sysmacProjectFilePath);
  } on Exception catch (e) {
    print(e);
    showInfo();
  }
}

void showInfo() {
  print(
      "Usage: sysmac_cmd <SysmacProjectFile.${SysmacProjectArchive.extension}>");
  print("For more information see: https://TODO"); //TODO
}
