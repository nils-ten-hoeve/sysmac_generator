import 'package:collection/collection.dart';
import 'package:sysmac_generator/domain/namespace.dart';

class EventGroup extends NameSpace {
  EventGroup(String name) : super(name);
}

/// [Event]s are system alarms, warnings or messages that are displayed to the
/// operator.

class Event extends NameSpace {
  final String groupName1;
  final String groupName2;
  final String id;
  final String componentCode;
  final String expression;
  final EventPriority priority;
  final String message;
  final String explanation;
  final bool popup;
  final bool acknowledge;

  Event(
      {required this.groupName1,
      this.groupName2 = '',
      required this.id,
      this.componentCode = '',
      required this.expression,
      this.priority = EventPriorities.medium,
      required this.message,
      this.explanation = '',
      this.popup = false,
      this.acknowledge = false})
      : super(expression);

  @override
  String toString() {
    return 'Event{groupName1: $groupName1, groupName2: $groupName2, id: $id, componentCode: $componentCode, expression: $expression, priority: $priority, message: $message, explanation: $explanation, popup: $popup, acknowledge: $acknowledge}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event &&
          runtimeType == other.runtimeType &&
          groupName1 == other.groupName1 &&
          groupName2 == other.groupName2 &&
          id == other.id &&
          componentCode == other.componentCode &&
          expression == other.expression &&
          priority == other.priority &&
          message == other.message &&
          explanation == other.explanation &&
          popup == other.popup &&
          acknowledge == other.acknowledge;

  @override
  int get hashCode =>
      groupName1.hashCode ^
      groupName2.hashCode ^
      id.hashCode ^
      componentCode.hashCode ^
      expression.hashCode ^
      priority.hashCode ^
      message.hashCode ^
      explanation.hashCode ^
      popup.hashCode ^
      acknowledge.hashCode;
}

class EventPriority {
  final String name;
  final String abbreviation;
  final int level;
  final String description;
  final String example;

  const EventPriority({
    required this.name,
    required this.abbreviation,
    required this.level,
    required this.description,
    required this.example,
  });

  String get omronPriority =>
      (level > 0 && level < 9) ? "UserFaultLevel$level" : "UserInformation";

  @override
  String toString() {
    return 'EventPriority{name: $name}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventPriority &&
          runtimeType == other.runtimeType &&
          level == other.level;

  @override
  int get hashCode => level.hashCode;
}

class EventPriorities extends DelegatingList<EventPriority> {
  static final EventPriorities _singleton = EventPriorities._internal();

  factory EventPriorities() => _singleton;

  static const fatal = EventPriority(
    name: 'Fatal',
    abbreviation: 'F',
    level: 1,
    description:
        'A fatal problem that prevents the system from working (fatal for system).',
    example:
        'An EtherCAT error, an important fuse of the control system, missing IO cards, critical IO card errors, etc.',
  );

  static const critical = EventPriority(
    name: 'Critical',
    abbreviation: 'C',
    level: 2,
    description: 'A critical problem that stops the system.',
    example:
        'An emergency stop, a critical motor tripped, low hydraulic level, etc.',
  );

  static const high = EventPriority(
    name: 'High',
    abbreviation: 'H',
    level: 3,
    description: 'A problem with major consequences, but system keeps running.',
    example: 'Direct action is needed, e.g.: an important motor tripped, etc.',
  );

  static const mediumHigh = EventPriority(
    name: 'Medium High',
    abbreviation: 'MH',
    level: 4,
    description: 'A problem with moderate consequences.',
    example: 'Urgent action is required.',
  );

  static const medium = EventPriority(
    name: 'Medium',
    abbreviation: 'M',
    level: 5,
    description: 'A problem with some consequences.',
    example:
        'Action within 5 minutes is required, e.g. when a low temperature is detected.',
  );

  static const mediumLow = EventPriority(
      name: 'Medium Low',
      abbreviation: 'ML',
      level: 6,
      description: 'A problem with minor consequences.',
      example: 'Action within 15 minutes is required.');

  static const low = EventPriority(
    name: 'Low',
    abbreviation: 'L',
    level: 7,
    description: 'A problem with almost no consequences.',
    example: 'Eventually action is required, e.g. a tripped plucker motor.',
  );

  static const info = EventPriority(
      name: 'Info',
      abbreviation: 'I',
      level: 9,
      description:
          'All events that are not an error, such as information for the operator',
      example: 'When a stop button is pressed, or external stop is activated.');

  EventPriorities._internal()
      : super(
            [fatal, critical, high, mediumHigh, medium, mediumLow, low, info]);

  String get asMarkDown {
    String markdown =
        '| Priority | Abbreviation | Omron Priority | Description | Example |\n';
    markdown += '| --- | --- | --- | --- | --- |\n';
    for (var priority in EventPriorities()) {
      markdown +=
          '| ${priority.name} | ${priority.abbreviation} | ${priority.omronPriority} | ${priority.description} | ${priority.example} |\n';
    }
    return markdown;
  }
}
