import 'dart:io';

import 'package:sysmac_generator/service/xor_hmi_service.dart';
import 'package:sysmac_generator/infrastructure/sysmac_project.dart';
import 'package:sysmac_generator/service/event_service.dart';

void main(List<String> arguments) {
  SysmacGenerator().execute(arguments);
}

const exitCodeSuccess = 0;
const exitCodeError = 1;

/// sysmac_generator is a command line tool to help you as a developer to do tedious
/// tasks with [Omron Sysmac Projects](https://automation.omron.com/en/us/products/family/sysstdio).

class SysmacGenerator {
  void execute(List<String> arguments) {
    try {
      
      var sysmacProjectFilePath = arguments.join(' ');
      var sysmacProject = SysmacProjectFactory().create(sysmacProjectFilePath);
      XorHmiService().generateTagsFile(sysmacProject);
    } catch (e) {
      showInfo();
      exit(exitCodeError);
    }
  }

/// TODO this was a previous endeavour that needs completing
  //TODO change to generateFile(String templatePath, String sourcePath, {String destinationPath});
  void generateForSysmacHmi(String sysmacProjectFilePath) {
    try {
      EventService().generateForSysmacHmi(sysmacProjectFilePath);
    } on Exception catch (e) {
      print(e);
      showInfo();
    }
  }

  void showInfo() {
    print(
        "Usage: sysmac_generator YourSysmacProjectFile.${SysmacProjectArchive.extension}"); // TODO
    //TODO  print(
    //     "For more information see: https://https://github.com/nils-ten-hoeve/sysmac_generator/wiki");
  }
}
