import 'base_type.dart';
import 'node.dart';

///Root [Node] of the DataType tree containing [DataTypeBase]s
class DataTypeTree extends DataTypeBase {
  DataTypeTree() : super('$DataTypeTree');
}

/// Abstract base type of [DataType]s and [NameSpace]s
abstract class DataTypeBase extends Node<DataTypeBase> {
  final String comment;

  DataTypeBase(String name, [this.comment = '']) : super(name);
}

class NameSpace extends DataTypeBase {
  NameSpace(String name, [String comment = '']) : super(name, comment);
}

class DataType extends DataTypeBase {
  // DataType? parent;
  BaseType baseType;

  DataType({required String name, required this.baseType, String comment = ''})
      : super(name, comment);

  @override
  List<DataTypeBase> get children {
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
