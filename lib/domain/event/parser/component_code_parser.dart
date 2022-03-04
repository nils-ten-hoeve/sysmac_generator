import 'package:petitparser/petitparser.dart';
import 'package:sysmac_generator/domain/event/parser/event_parser.dart';

import '../../sysmac_project.dart';
import 'generic_parsers.dart';

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
/// * Each [ComponentCode] has  the following format: &lt;Site nr&gt;.&lt;Electric panel nr&gt;.&lt;Page nr&gt;&lt;Component letters&gt;&lt;Column nr&gt;
///   e.g.: 4321.DE06.31M3 (= Line Drive 6)
///   * &lt;Site nr&gt;:
///     Each known processing plant has a unique number (also called a Meyn layout number)
///     e.g. 4321 = Maple Leaf - London - Canada
///   * &lt;Electric panel nr&gt;:
///     Each electric panel within a site has a unique number starting with DE.
///     In this case it is the electric panel that contains the PLC.
///     e.g. DE06 = Evisceration line (at site 4321 = Maple Leaf - London - Canada)
///   * &lt;Page nr&gt;:
///     Refers to the page number of the electrical diagram
///     e.g. 31 = page 31 (of 4321.DE06)
///   * &lt;Component letters&gt;:
///     Several letter to indicate the type of component, e.g.:
///     * B = Optical coupler
///     * E = 230V Light
///     * F = Fuse
///     * H = Acoustic/ light signal
///     * JB = Junction box
///     * K = Relay
///     * M = Motor
///     * Q = Overload protection
///     * R = Resistor
///     * S = Switch
///     * T = Transformer
///     * U = Controller
///     * V = Diode
///     * W = Wire/cable
///     * X = Connection terminal
///     * Y = Valve
///   * &lt;Column nr&gt;:
///     Refers to the column number of the electrical diagram
///     e.g. 3 = column 3

class ComponentCode {
  final Site site;
  final ElectricPanel electricPanel;
  final int pageNumber;
  final String letters;
  final int columnNumber;

  ComponentCode({
    required this.site,
    required this.electricPanel,
    required this.pageNumber,
    required String letters,
    required this.columnNumber,
  }) : letters = letters.toUpperCase();

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

  String toCode() {
    return '${site.code}.${electricPanel.code}.$pageNumber$letters$columnNumber';
  }
}

/// Each [Event] should have a reference to a [ComponentCode] where possible.
/// This is done by dding a [ComponentCodeTag] anywhere in a comment.
/// The full [ComponentCode] will than become visible in the [ComponentCode] field in the [Event].
///
/// [ComponentCodeTag]:
/// * Format: [&lt;pageNumber&gt;&lt;letters&gt;&lt;pageNumber&gt;]
/// * Examples: [30M2] or [ 110S8 ] but not [ 110S9 ]
class ComponentCodeTag extends EventTag {
  final int pageNumber;
  final String letters;
  final int columnNumber;

  ComponentCodeTag({
    required this.pageNumber,
    required String letters,
    required this.columnNumber,
  }) : letters = letters.toUpperCase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComponentCodeTag &&
          runtimeType == other.runtimeType &&
          pageNumber == other.pageNumber &&
          letters == other.letters &&
          columnNumber == other.columnNumber;

  @override
  int get hashCode =>
      pageNumber.hashCode ^ letters.hashCode ^ columnNumber.hashCode;

  @override
  String toString() {
    return '$ComponentCodeTag{pageNumber: $pageNumber, letters: $letters, columnNumber: $columnNumber}';
  }

  String toText() {
    return '$pageNumber$letters$columnNumber';
  }
}

class ComponentCodeTagParser extends EventTagParser {
  static final _pageNumberParser = intParser;

  static final _letterParser = letter()
      .repeat(1, 4)
      .flatten()
      .map((String value) => value.toUpperCase());

  static final _columnNumberParser =
      pattern('1-8').times(1).flatten().map(int.parse);

  ComponentCodeTagParser()
      : super((char('[') &
                whiteSpaceParser.optional() &
                _pageNumberParser &
                _letterParser &
                _columnNumberParser &
                whiteSpaceParser.optional() &
                char(']'))
            .map((values) => ComponentCodeTag(
                pageNumber: values[2],
                letters: values[3],
                columnNumber: values[4])));
}
