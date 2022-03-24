import 'base_type.dart';
import 'namespace.dart';

class DataType extends NameSpaceWithTypeAndComment {
  DataType? parent;

  DataType({
    required String name,
    required BaseType baseType,
    required String comment,
  }) : super(
          name: name,
          baseType: baseType,
          comment: comment,
        );

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
