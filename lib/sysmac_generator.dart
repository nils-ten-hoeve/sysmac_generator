import 'infrastructure/sysmac_project.dart';
import 'service/event_service.dart';

main(List<String> arguments) {
  SysmacGenerator().execute(arguments);
}

/// sysmac_generator is a command line tool to help you as a developer to do tedious
/// tasks with [Omron Sysmac projects](https://automation.omron.com/en/us/products/family/sysstdio).
///
/// It generates files by reading [SysmacProjectFile]s and [TemplateFile]s.
/// These files can than be used to import into Sysmac or other programs.
class SysmacGenerator {
  void execute(List<String> arguments) {
    if (arguments.length == 1) {
      generateForSysmacHmi(arguments[1]);
    } else {
      showInfo();
    }
  }

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
        "Usage: sysmac_generator <SysmacProjectFile.${SysmacProjectArchive.extension}>"); // TODO
    print(
        "For more information see: https://https://github.com/nils-ten-hoeve/sysmac_generator/wiki");
  }
}



/// [TemplateFile] files are text files such as:
/// * [csv files](https://en.wikipedia.org/wiki/Comma-separated_values)
/// * [json files](https://en.wikipedia.org/wiki/JSON)
/// * [xml files](https://en.wikipedia.org/wiki/XML)
/// * [text files](https://en.wikipedia.org/wiki/Text_file)
/// * etc...
///
/// [TemplateFile] files can contain [TemplateTag]s.
/// The [SysmacGenerator]:
/// * reads these template file(s)
/// * does something with the [TemplateTag]s
/// * writes the resulting generated file(s) to disk
class TemplateFile {}

/// [TemplateFile]s can contain [TemplateTag] texts.
/// [TemplateTag]s have a special meaning for the [SysmacGenerator].
/// Most [TemplateTag]s are replaced by the [SysmacGenerator] with generated text.
///
/// [TemplateTag]s:
/// * are surrounded by double square brackets: [[ ]]
/// * contain some kind of information, e.g.:
///   * often start with a name or name path:
///     e.g. [[importFile]] or [[project.name]]
///   * may have one or more attributes after the name:
///     e.g. [[importFile path='otherFile.txt']]
class TemplateTag {}