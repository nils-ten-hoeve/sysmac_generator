import 'package:sysmac_cmd/infrastructure/sysmac/sysmac.dart';
import 'package:sysmac_cmd/service/alarm_list.dart';

void main(List<String> arguments) {
  if (arguments.length==1 ) {
    generateExcelFile(arguments[1]);
  } else  {
    showInfo();
  }
}

void generateExcelFile(String sysmacProjectFilePath) {
  try {
    UserAlarmListService().generateExcelFile(sysmacProjectFilePath);
  } on Exception catch (e) {
    print(e);
    showInfo();
  }
}

void showInfo() {
  print("Usage: sysmac_events_generator <SysmacProjectFile.${SysmacProjectFile.extension}>");
  print("For more information see: https://TODO");//TODO
}
