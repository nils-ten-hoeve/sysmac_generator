import 'package:sysmac_generator/domain/data_type.dart';

@Deprecated('Use Variable')
class VariableOld extends DataType {
  VariableOld({
    required super.name,
    required super.baseType,
    required super.comment,
  });

  @override
  String toString() {
    String string =
        '$VariableOld{name: $name, comment: $comment, dataType: $baseType}';
    for (var child in children) {
      var lines = child.toString().split('\n');
      for (var line in lines) {
        string += "\n  $line";
      }
    }
    return string;
  }
}
