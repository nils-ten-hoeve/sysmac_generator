import 'base_type.dart';
import 'namespace.dart';

class Variable extends NameSpace {
  final String comment;
  BaseType baseType;

  Variable({
    required String name,
    required this.baseType,
    required this.comment,
  }) : super(name);

  @override
  List<NameSpace> get children {
    if (baseType is DataTypeReference) {
      return [(baseType as DataTypeReference).dataType];
    } else {
      return super.children;
    }
  }

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
