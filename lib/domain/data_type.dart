import 'base_type.dart';
import 'namespace.dart';

class DataType extends NameSpace {
  final String comment;
  BaseType baseType;
  DataType? parent;

  DataType({
    required String name,
    required this.baseType,
    required this.comment,
  }) : super(name);

  @override
  List<NameSpace> get children {
    if (baseType is DataTypeReference) {
      return (baseType as DataTypeReference).dataType.children;
    } else {
      return super.children;
    }
  }

  @override
  String toString() {
    String string =
        '$DataType{name: $name, comment: $comment, baseType: $baseType}';
    for (var child in children) {
      var lines = child.toString().split('\n');
      for (var line in lines) {
        string += "\n  $line";
      }
    }
    return string;
  }
}

class DataTypeTree extends NameSpace {
  DataTypeTree() : super('$DataTypeTree');
}
