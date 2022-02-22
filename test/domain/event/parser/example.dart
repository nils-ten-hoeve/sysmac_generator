import 'dart:io';

import 'package:collection/collection.dart';
import 'package:documentation_builder/documentation_builder.dart';
import 'package:recase/recase.dart';
import 'package:sysmac_generator/domain/base_type.dart';
import 'package:sysmac_generator/domain/data_type.dart';
import 'package:sysmac_generator/domain/event/event.dart';
import 'package:sysmac_generator/domain/namespace.dart';
import 'package:sysmac_generator/domain/variable.dart';
import 'package:sysmac_generator/infrastructure/event.dart';
import 'package:sysmac_generator/infrastructure/variable.dart';
import 'package:test/test.dart';

import 'component_code_test.dart';
import 'structure_test.dart';

/// This [EventExample] serves the following purposes
/// * It test the event [Metadata] syntax as parsed bij the [EventParser]
/// * It generates a [MarkdownTemplateFile] to explain the event [Metadata]
///   syntax as parsed bij the [EventParser]
abstract class EventExample with MarkDownTemplateWriter {
  Definition get definition;

  String get explanation;

  EventTableColumns get eventTableColumns;

  get title =>
      runtimeType.toString().replaceFirst(RegExp('Example\$'), '').titleCase;

  List<EventGroup> createEventGroups(Definition definition) {
    EventService eventService = EventService();
    return eventService.createFromVariable([definition.eventGlobalVariable]);
  }

  @override
  String get asMarkDown => EventExampleMarkDownWriter(this).asMarkDown;

  void test() {
    var _definition = definition;
    var eventGroups = createEventGroups(_definition);
    expect(eventGroups, equals(definition.eventGroups));
  }
}

class EventExampleMarkDownWriter with MarkDownTemplateWriter {
  final EventExample eventExample;

  EventExampleMarkDownWriter(this.eventExample);

  @override
  String get asMarkDown {
    String markDown = '${eventExample.explanation}\n';

    var definition = eventExample.definition;
    var variable = definition.eventGlobalVariable;

    markDown += _createVariableTable(definition, variable).toHtml();
    markDown += '\n';
    markDown += _createDataTypeTable(definition.dataTypeTree).toHtml();
    markDown += '\n';
    markDown += _createEventTable(definition.events).toHtml();
    return markDown;
  }

  _HtmlTable _createVariableTable(Definition definition, Variable variable) =>
      _HtmlTable(
        headerRows: _createVariableHeaderRows(),
        rows: _createVariableRows(definition, variable),
      );

  List<_HtmlRow> _createVariableHeaderRows() => [
        _HtmlRow(values: ['Variable'], colSpans: [3]),
        _HtmlRow(values: ['Name', 'Type', 'Comment']),
      ];

  List<_HtmlRow> _createVariableRows(
          Definition definition, Variable variable) =>
      [
        _HtmlRow(values: [
          variable.name,
          _createReferencePath(definition, variable),
          variable.comment,
        ]),
      ];

  String _createReferencePath(Definition _definition, Variable variable) {
    var referencedDataType = (variable.baseType as DataTypeReference).dataType;
    var referencePath = _definition.dataTypeTree
        .findPath(referencedDataType)
        .map((nameSpace) => nameSpace.name)
        .toList();
    referencePath.removeAt(0);
    return referencePath.join('\\');
  }

  _HtmlTable _createDataTypeTable(DataTypeTree dataTypeTree) => _HtmlTable(
        headerRows: _createDataTypeHeaderRows(),
        rows: _createDataTypeRowsForDataTypeTree(dataTypeTree),
      );

  List<_HtmlRow> _createDataTypeHeaderRows() => [
        _HtmlRow(values: ['Data Types'], colSpans: [3]),
        _HtmlRow(values: ['Name', 'Type', 'Comment']),
      ];

  List<_HtmlRow> _createDataTypeRows(int level, NameSpace nameSpace) {
    List<_HtmlRow> rows = [];
    String indent = level == 0 ? '' : '&nbsp;' * (level * 4);
    String name = nameSpace.name;
    String type = nameSpace is DataType ? nameSpace.baseType.toString() : '';
    String comment = nameSpace is NameSpaceWithComment ? nameSpace.comment : '';
    var row = _HtmlRow(values: [indent + name, type, comment]);
    rows.add(row);
    for (var child in nameSpace.children) {
      //recursive call
      rows.addAll(_createDataTypeRows(level + 1, child));
    }
    return rows;
  }

  List<_HtmlRow> _createDataTypeRowsForDataTypeTree(DataTypeTree dataTypeTree) {
    List<_HtmlRow> rows = [];
    for (var nameSpace in dataTypeTree.children) {
      rows.addAll(_createDataTypeRows(0, nameSpace));
    }
    return rows;
  }

  _HtmlTable _createEventTable(List<Event> events) => _HtmlTable(
        headerRows: _createEventHeaderRows(),
        rows: _createEventRows(events),
      );

  List<_HtmlRow> _createEventHeaderRows() => [
        _HtmlRow(
          values: ['Generated Events'],
          colSpans: [eventExample.eventTableColumns.length],
        ),
        _HtmlRow(
            values: eventExample.eventTableColumns
                .map((column) => column.name)
                .toList()),
      ];

  List<_HtmlRow> _createEventRows(List<Event> events) {
    List<_HtmlRow> rows = [];
    for (var event in events) {
      rows.add(_HtmlRow(
          values: eventExample.eventTableColumns
              .map((column) => column.cellValue(event))
              .toList()));
    }
    return rows;
  }
}

class _HtmlTable {
  final List<_HtmlRow> headerRows;
  final List<_HtmlRow> rows;

  _HtmlTable({this.headerRows = const [], this.rows = const []});

  String toHtml() {
    String html = '<table>\n';
    for (var headerRow in headerRows) {
      for (var htmlLine in headerRow.toHtmlLines(isHeader: true)) {
        html += '  $htmlLine';
      }
    }
    for (var row in rows) {
      for (var htmlLine in row.toHtmlLines()) {
        html += '  $htmlLine';
      }
    }

    html += '</table>\n';
    return html;
  }

  @override
  String toString() => toHtml();
}

class _HtmlRow {
  final List<int?> colSpans;
  final List<String> values;

  _HtmlRow({this.colSpans = const [], required this.values});

  List<String> toHtmlLines({bool isHeader = false}) {
    List<String> htmlLines = [];
    htmlLines.add('<tr>\n');
    for (int i = 0; i < values.length; i++) {
      var collSpan = i < colSpans.length ? colSpans[i] : null;
      htmlLines.add(_createCellHtml(isHeader, values[i], collSpan));
    }
    htmlLines.add('</tr>\n');
    return htmlLines;
  }

  String _createCellHtml(bool isHeader, String value, int? colSpan) {
    String cellHtml = '';
    String collSpanAttribute = colSpan == null ? '' : ' colspan="$colSpan" ';
    cellHtml +=
        isHeader ? '  <th$collSpanAttribute>' : '  <td$collSpanAttribute>';
    cellHtml += value;
    cellHtml += isHeader ? '</th>\n' : '</td>\n';
    return cellHtml;
  }
}

/// convenience class to build a [DataTypeTree] for a [EventExample].
/// It contains all [DataType]s needed, the EventGlobal variable will be
/// the first [DataType]
///
class Definition {
  final DataTypeTree dataTypeTree = DataTypeTree();
  final List<Event> events = [];
  String variableComment = '';

  /// A [pointer] is the last position where:
  /// * [NameSpace]s or
  /// * [DataType]s that represent [Struct]s or
  /// * [DataType]s that represent [Events]s
  /// are added to [pointer]s children.
  ///
  ///Note that the [pointer] should never be a leaf in the tree
  ///, e.g.: never represent an [Event]!
  late NameSpace pointer = dataTypeTree;

  NameSpace addNameSpace(String name) {
    _verifyPointerToAddNameSpace();
    NameSpace nameSpace = NameSpace(name);
    pointer.children.add(nameSpace);
    pointer = nameSpace;
    return pointer;
  }

  void _verifyPointerToAddNameSpace() {
    if (pointer is DataType) {
      throw Exception('You can not add a $NameSpace to a Struct');
    }
  }

  Definition addStruct(String dataTypeName, [String dataTypeComment = '']) {
    DataType dataType = DataType(
      name: dataTypeName,
      comment: dataTypeComment,
      baseType: Struct(),
    );
    pointer.children.add(dataType);
    pointer = dataType;
    return this;

    /// See [FluentInterface]
  }

  Definition addStructReference({
    required String dataTypeName,
    String dataTypeComment = '',

    /// [dataTypeExpression] format e.g. :
    /// * Equipment\Pump\sEvent
    /// * ARRAY[1..2] OF Equipment\Pump\sEvent
    /// * ARRAY[1..2,3..4] OF Equipment\Pump\sEvent
    required String dataTypeExpression,
  }) {
    //TODO
    DataType dataType = DataType(
      name: dataTypeName,
      comment: dataTypeComment,
      baseType: UnknownBaseType(dataTypeExpression)
      //[baseType] will be converted to a [DataTypeReference] later
      ,
    );
    pointer.children.add(dataType);
    pointer = dataType;
    return this;
  }

  Definition addEvent(
      {required String dataTypeName,
      required String dataTypeComment,
      required String groupName1,
      String groupName2 = '',
      String componentCode = '',
      EventPriority priority = EventPriorities.medium,
      required String message,
      String explanation = '',
      bool acknowledge = false}) {
    DataType dataType = DataType(
      name: dataTypeName,
      comment: dataTypeComment,
      baseType: VbBoolean(),
    );
    pointer.children.add(dataType);

    Event event = Event(
        groupName1: groupName1,
        groupName2: groupName2,
        id: '${events.length + 1}',
        componentCode: componentCode,
        expression: _createExpression(dataType),
        priority: priority,
        message: message,
        explanation: explanation,
        acknowledge: acknowledge);

    events.add(event);
    return this;

    /// [FluentInterface]
  }

  String _createExpression(DataType dataType) {
    var path = dataTypeTree.findPath(dataType).toList();
    path.removeAt(0);
    path.removeWhere(
        (nameSpace) => nameSpace is DataType && nameSpace.baseType == Struct());
    return GlobalVariableService.eventGlobalVariableName +
        '.' +
        path.map((nameSpace) => nameSpace.name).join('.');
  }

  /// Sets the [pointer] to the [dataTypeTree] and returns the tree so that other [DataType]s can be added to it using a [FluentInterface]
  DataTypeTree toRoot() {
    pointer = dataTypeTree;
    return dataTypeTree;
  }

  Variable get eventGlobalVariable {
    if (dataTypeTree.children.isEmpty) {
      throw Exception('The $DataTypeTree may not be empty.');
    }
    var struct = dataTypeTree.findFirst(
        (nameSpace) => nameSpace is DataType && nameSpace.baseType == Struct());
    if (struct == null) {
      throw Exception(
          'The  $DataTypeTree does not contain a $DataType with $BaseType == $Struct.');
    }
    return Variable(
        name: GlobalVariableService.eventGlobalVariableName,
        comment: variableComment,
        baseType: DataTypeReference(struct as DataType, []));
  }

  List<EventGroup> get eventGroups {
    String groupName = '';
    EventGroup eventGroup = EventGroup((groupName));
    List<EventGroup> eventGroups = [];
    for (var event in events) {
      if (event.groupName1 != groupName) {
        eventGroup = EventGroup(event.groupName1);
        eventGroups.add(eventGroup);
      }
      eventGroup.children.add(event);
    }
    return eventGroups;
  }
}

// See https://en.wikipedia.org/wiki/Fluent_interface
class FluentInterface {}

class GroupDefinition {}

class EventTableColumn {
  final String name;
  final String Function(Event event) cellValue;

  EventTableColumn(this.name, this.cellValue);
}

class EventTableColumns extends DelegatingList<EventTableColumn> {
  EventTableColumns.forColumns(columns) : super(columns);

  EventTableColumns() : super([]);

  EventTableColumns get withGroupName1 =>
      _add(EventTableColumn('GroupName1', (event) => event.groupName1));

  EventTableColumns get withGroupName2 =>
      _add(EventTableColumn('GroupName2', (event) => event.groupName2));

  EventTableColumns get withExpression =>
      _add(EventTableColumn('Expression', (event) => event.expression));

  EventTableColumns get withComponentCode =>
      _add(EventTableColumn('Component Code', (event) => event.componentCode));

  EventTableColumns get withMessage =>
      _add(EventTableColumn('Message', (event) => event.message));

  _add(EventTableColumn newColumn) =>
      EventTableColumns.forColumns([...this, newColumn]);
}

class EventExamples extends DelegatingList<EventExample>
    with MarkDownTemplateWriter {
  EventExamples()
      : super([
          EventStructureExample(),
          EventComponentCodeExample(),
        ]);

  @override
  String get asMarkDown => map((eventExample) =>
          "{ImportFile path='${eventExample.fileName}' title='# ${eventExample.title}'}")
      .join('\n\n');
}

mixin MarkDownTemplateWriter {
  String get markDownHeader =>
      '[//]: # (This file was generated by $runtimeType.writeMarkDownTemplateFile on: ${DateTime.now()})\n';

  /// Convert this object to MarkDown text
  String get asMarkDown;

  String get fileName => 'doc/template/$runtimeType.mdt';

  writeMarkDownTemplateFile() {
    String markDown = markDownHeader;
    markDown += asMarkDown;
    File(fileName).writeAsStringSync(markDown);
  }
}
