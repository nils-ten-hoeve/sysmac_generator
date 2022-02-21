import 'package:petitparser/parser.dart';
import 'package:sysmac_cmd/domain/data_type.dart';
import 'package:sysmac_cmd/domain/event/event.dart';
import 'package:sysmac_cmd/domain/event/parser/component_code.dart';
import 'package:sysmac_cmd/domain/sysmac_project.dart';

final _remainingCharactersParser = any();

/// The [eventParser] combines all event parsers.
/// It will parse a string and will try to find all [EventMetaData] and convert
/// them to [EventMetaData] objects that contains this information.
///
/// The result is thus an array of [EventMetaData] objects or remaining characters.
final eventParser = (componentCodeParser | _remainingCharactersParser).star();


/// [Event]s are system alarms, warnings or messages that are displayed to the
/// operator.
///
/// [Event]s in a [SysmacProject] are stored in a global variable named EventGlobal.
/// This global variable has a custom [DataType] that can contain:
/// * booleans: Each boolean represents the status of an [Event]
/// * other [DataType] structures: to organize/group these events in a structure
///   comparable to how the system is structured (e.g. the ISA88 structure).
///
/// This application uses information of all the [DataType]s that are used in
/// the EventGlobal variable.
///
/// Each [Event] has an [Event.message]. This application uses the comments
/// of all the [DataType]s that are used inside the EventGlobal variable to
/// generate the [Event.message]. Note that it uses all [DataType] comments of
/// all [DataType] members, starting at the root (the [DataType] of
/// the EventGlobal variable, ending at the boolean member that represents an
/// event)
///
/// In order to generate [Event]s we need more data. We call this information
/// [EventMetaData].
///
/// [EventMetaData]  can be used inside the comments of all the [DataType]s
/// that are used inside the EventGlobal variable. The format of an
/// [EventMetaData] is normally some text between brackets, e.g.: [30M2]
///
/// [EventMetaData] are not be directly visible in the [Event.message]!
class EventMetaData {

}