import 'package:fluent_regex/fluent_regex.dart';

class Sentence {
  static String normalize(String input) {
    var trimmed = input.trim();

    if (trimmed.isEmpty) {
      return trimmed;
    }

    return _convertFirstLetterToCapitalLetter(
        _addPeriodIfMissing(_replaceDoubleSpaces(trimmed)));
  }

  static String _addPeriodIfMissing(String trimmed) {
    if (trimmed.endsWith('.')) {
      return trimmed;
    } else {
      return '$trimmed.';
    }
  }

  static String _convertFirstLetterToCapitalLetter(String trimmedWithPeriod) =>
      trimmedWithPeriod.substring(0, 1).toUpperCase() +
      trimmedWithPeriod.substring(1);

  static String _replaceDoubleSpaces(String string) => string.replaceAll(
      FluentRegex().whiteSpace(Quantity.oneOrMoreTimes()), ' ');
}
