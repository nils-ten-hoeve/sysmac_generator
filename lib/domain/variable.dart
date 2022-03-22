import 'base_type.dart';
import 'namespace.dart';

class Variable extends NameSpaceWithComment {
  BaseType baseType;

  Variable({
    required String name,
    required this.baseType,
    required String comment,
  }) : super(name, comment);

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

  List<List<NameSpace>> findPaths(bool Function(NameSpace nameSpace) filter) {
    List<NameSpace> nameSpacePath = [this];
    return _findNameSpacePathsFor(nameSpacePath, filter);
  }

  List<List<NameSpace>> _findNameSpacePathsFor(List<NameSpace> nameSpacePath,
      bool Function(NameSpace nameSpace) filter) {
    NameSpace nameSpace = nameSpacePath.last;
    List<List<NameSpace>> nameSpacePaths = [];
    if (filter(nameSpace)) {
      nameSpacePaths.add(nameSpacePath);
    }
    for (var child in nameSpace.children) {
      //recursive call
      nameSpacePaths
          .addAll(_findNameSpacePathsFor([...nameSpacePath, child], filter));
    }
    return nameSpacePaths;
  }
}
