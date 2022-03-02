import 'package:petitparser/petitparser.dart';
import 'package:sysmac_generator/domain/event/parser/event.dart';

import '../../sysmac_project.dart';

class PartialComponentCode implements EventMetaData {
  final int pageNumber;
  final String letters;
  final int columnNumber;

  PartialComponentCode({
    required this.pageNumber,
    required String letters,
    required this.columnNumber,
  }): letters=letters.toUpperCase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartialComponentCode &&
          runtimeType == other.runtimeType &&
          pageNumber == other.pageNumber &&
          letters == other.letters &&
          columnNumber == other.columnNumber;

  @override
  int get hashCode =>
      pageNumber.hashCode ^ letters.hashCode ^ columnNumber.hashCode;

  @override
  String toString() {
    return '$PartialComponentCode{pageNumber: $pageNumber, letters: $letters, columnNumber: $columnNumber}';
  }

  String toText() {
    return '$pageNumber$letters$columnNumber';
  }
}

/// There are many control system components.
/// A control system component typically:
/// * Uses power
/// * Can do something (outputs / actuators), e.g.:
///   * Motor
///   * Cylinders
///   * Indication lights
///   * Buzzers
///   * Etc..
/// * And/ or can sense something (inputs / sensors), e.g.::
///   * proximity switch
///   * Pressure sensor
///   * Hardware status (e.g. of a remote IO, inverters, etc)
///
/// Each component has a [ComponentCode]:
/// * Each [ComponentCode] is unique within a Site (=processing plant)
/// * Each component has a label with the [ComponentCode] so that is can be identified.
/// * Each [ComponentCode] has a reference to the electrical diagram
/// * Each [ComponentCode] has  the following format: [Site nr].[Electric panel nr].[Page nr][Component letters][Column nr]
///   e.g.: 4321.DE06.31M3 (= Line Drive 6)
///   * Site nr:
///     Each known processing plant has a unique number (also called a Meyn layout number)
///     e.g. 4321 = Maple Leaf - London - Canada
///   * Electric panel nr:
///     Each electric panel within a site has a unique number starting with DE.
///     In this case it is the electric panel that contains the PLC.
///     e.g. DE06 = Evisceration line (at site 4321 = Maple Leaf - London - Canada)
///   * Page nr:
///     Refers to the page number of the electrical diagram
///     e.g. 31 = page 31 (of 4321.DE06)
///   * Component letters:
///     Several letter to indicate the type of component, e.g.:
///     * B = Optical coupler
///     * E = 230V Light
///     * F = Fuse
///     * H = Acoustic/ light signal
///     * JB = Junction box
///     * K = Relay
///     * M = Motor
///     * Q = Overload protection
///     * R = Resistance
///     * S = Switch
///     * T = Transformer
///     * U = Controller
///     * V = Diode
///     * W = Cable
///     * X = Terminal
///     * Y = Valve
///   * Column nr:
///     Refers to the column number of the electrical diagram
///     e.g. 3 = column 3

class ComponentCode extends PartialComponentCode {
  final Site site;
  final ElectricPanel electricPanel;

  ComponentCode({
    required this.site,
    required this.electricPanel,
    required int pageNumber,
    required String letters,
    required int columnNumber,
  }) :  super(
          pageNumber: pageNumber,
          letters: letters,
          columnNumber: columnNumber,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComponentCode &&
          runtimeType == other.runtimeType &&
          site == other.site &&
          electricPanel == other.electricPanel &&
          pageNumber == other.pageNumber &&
          letters == other.letters &&
          columnNumber == other.columnNumber;

  @override
  int get hashCode =>
      site.hashCode ^
      electricPanel.hashCode ^
      pageNumber.hashCode ^
      letters.hashCode ^
      columnNumber.hashCode;

  @override
  String toString() {
    return 'ComponentCode{site: $site, electricalPanel: $electricPanel, pageNumber: $pageNumber, letters: $letters, columnNumber: $columnNumber}';
  }

  @override
  String toText() {
    return '${site.code}.${electricPanel.code}.$pageNumber$letters$columnNumber';
  }


}

final _pageNumberParser = digit().plus().flatten().map(int.parse);

final _letterParser =
    letter().repeat(1, 4).flatten().map((String value) => value.toUpperCase());

final _columnNumberParser = pattern('1-8').times(1).flatten().map(int.parse);

/// A [componentCodeParser] finds and converts the following string format to a
/// [ComponentCode] object:
///
/// Format: <pageNumber><letters><pageNumber>
/// Example: 30M2
final componentCodeParser =
    (_pageNumberParser & _letterParser & _columnNumberParser).map((values) =>
        PartialComponentCode(
            pageNumber: values[0],
            letters: values[1],
            columnNumber: values[2]));
