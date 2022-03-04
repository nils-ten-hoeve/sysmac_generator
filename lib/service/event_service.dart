import 'package:sysmac_generator/domain/event/event.dart';
import 'package:sysmac_generator/sysmac_generator.dart';

import '../infrastructure/sysmac_project.dart';

/// Generates event documents from a [SysmacProjectFile]
class EventService {
  /// # Why events must be generated
  /// The goal is to always generate all the events from a [SysmacProjectFile],
  /// while not making any manual changes afterwards so that:
  /// * The event texts accurately match the PLC program (data types)
  /// * All event texts are accurate and consistent
  /// * Creating or updating the events is less labor intensive and less error prone
  ///
  /// # How events are generated
  /// The [SysmacGenerator] will read a folder containing [SysmacProjectFile]s
  /// (of just a single [SysmacProjectFile]) and parse the [Event]s.
  ///
  /// It will then generate generate output files using [TemplateFile]s and [TemplateTag]s.
  /// These generated files can than be used to be imported into
  /// [SysmacProjectFile]s or other applications.
  ///
  /// TODO: reference to TemplateFileTag and the containing event variable structure (generated from [EventGroup])


  // TODO scan existing UserAlarm texts in the SysmacProject.
  // It will generate the English alarm texts using
  //   the DataType's in the SysmacProject. We assume that an UserAlarm text of
  //   other languages needs to be re-translated if the English text has changed.
  //   TODO check if the following is still valid:
  //   In this case it will mark the texts in other languages with a ! to indicate
  //   that the text might need to be verified by the translator agency.
  //   Note that the component code is automatically is updated automatically if
  //   this is the only thing that has changed. New alarm texts are marked with a
  //   # to indicate that these texts need to be translated by the translator agency.
  //   The translator agencies need to remove the ! and # characters once these
  //   texts have been processed.
//
  // TODO instructions:
  // The result will be stored in an M$ Excel file, in the same folder and
  // starting with the same file name as the SysmacProject file.
  // Open this file and scan all alarms to verify the all UserAlarm text's and
  // component codes are as expected. If not, fix the texts in the DataType's of
  // the SysmacProject and repeat the process again.
  //
  // Open the SysmacProject file and delete all alarms in the HMI, when all
  // UserAlarm texts in the M$ Excel file are correct. Now the new UserAlarms
  // can be inserted by importing the M$ Excel file.
  void generateForSysmacHmi(String sysmacProjectFilePath) {
    var sysmacProject = SysmacProjectFactory().create(sysmacProjectFilePath);
    var eventGlobalVariables=sysmacProject.globalVariableService.findVariablesWithEventGlobalName();
    sysmacProject.eventService.createFromVariable(eventGlobalVariables);
  }

  void generateForCynergy(String sysmacProjectFilePath) {
    //TODO
  }
}
