import 'package:sysmac_generator/domain/data_type.dart';


class Variable extends DataType {
  Variable({
    required super.name,
    required super.baseType,
    required super.comment,
  });

  @override
  String toString() {
    String string =
        '$Variable{name: $name, comment: $comment, dataType: $baseType}';
    for (var child in children) {
      var lines = child.toString().split('\n');
      for (var line in lines) {
        string += "\n  $line";
      }
    }
    return string;
  }

}
