import '../infrastructure/sysmac_project.dart';

/// Generates event documents from a [SysmacProjectFile]
class EventService {
  /// * event texts to be imported into the [SysmacProject] for the HMI
  /// * PLC code to transfer PLC event status to Meyn Connnect using MQTT
  /// * event texts to be imported by Meyn Connect
  ///
  /// ## Why
  /// The goal is to always generate all the event texts, while not making any
  /// manual changes afterwards so that:
  /// * The event texts accurately match the PLC program (data types)
  /// * All event texts are accurate and consistent
  /// * Creating or updating the events is less labor intensive and less error prone
  ///
  /// ##How
  /// The event documents are generated from an exported [SysmacProjectFile] (*.scm).
  /// So first step in creating or updating UserAlarms is exporting the latest SysmacProject.
  /// Then start the sysmac_cmd application with the following parameters
  /// * TODO
  /// * [SysmacProjectFile] (*.scm).
  ///
  /// It will will scan the project file for:
  /// * a DataType named "sEvent" in the root of the data structure (without namespace).
  ///   It will scan this data structure looking for members of OmronBaseType.BOOL.
  ///   Each found data type will be converted to an UserAlarm.
  ///   Each member that refers to an other BaseType.STRUCT will automatically become
  ///   a UserAlarmGroup. Note that memberNames that start the same
  ///   (e.g. Transport and TransportVfd) will be put in the same UserAlarmGroup.
  /// * a HMI variable name that ends with the \sEvent base type.
  ///   This variablename combined with the DataTypes will be used to generate
  ///   the UserAlarm expression.
  /// * existing UserAlarm texts. It will generate the English alarm texts using
  ///   the DataType's in the SysmacProject. We assume that an UserAlarm text of
  ///   other languages needs to be re-translated if the English text has changed.
  ///   TODO check if the following is still valid:
  ///   In this case it will mark the texts in other languages with a ! to indicate
  ///   that the text might need to be verified by the translator agency.
  ///   Note that the component code is automatically is updated automatically if
  ///   this is the only thing that has changed. New alarm texts are marked with a
  ///   # to indicate that these texts need to be translated by the translator agency.
  ///   The translator agencies need to remove the ! and # characters once these
  ///   texts have been processed.
  ///
  /// TODO check if the following is still valid:
  /// The result will be stored in an M$ Excel file, in the same folder and
  /// starting with the same file name as the SysmacProject file.
  /// Open this file and scan all alarms to verify the all UserAlarm text's and
  /// component codes are as expected. If not, fix the texts in the DataType's of
  /// the SysmacProject and repeat the process again.
  ///
  /// Open the SysmacProject file and delete all alarms in the HMI, when all
  /// UserAlarm texts in the M$ Excel file are correct. Now the new UserAlarms
  /// can be inserted by importing the M$ Excel file.
  ///
  /// {@insert DetailsRuleExampleTest}
  ///
  /// {@insert UserAlarmGroupExampleTest}
  void generateForSysmacHmi(String sysmacProjectFilePath) {
    var sysmacProject = SysmacProjectFactory().create(sysmacProjectFilePath);
    var eventGlobalVariables=sysmacProject.globalVariableService.findVariablesWithEventGlobalName();
    sysmacProject.eventService.createFromVariable(eventGlobalVariables);
  }

  void generateForCynergy(String sysmacProjectFilePath) {
    //TODO
  }
}
