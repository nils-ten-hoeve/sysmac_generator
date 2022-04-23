import 'package:sysmac_generator/domain/data_type.dart';

import 'base_type.dart';

class Variable extends DataType {
  Variable({
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
        '$Variable{name: $name, comment: $comment, dataType: $baseType}';
    for (var child in children) {
      var lines = child.toString().split('\n');
      for (var line in lines) {
        string += "\n  $line";
      }
    }
    return string;
  }

// List<List<DataType>> findPaths(bool Function(DataType dataType) filter) {
//   List<DataType> nameSpacePath = [this];
//   return _findNameSpacePathsFor(nameSpacePath, filter);
// }
//
// List<List<DataType>> _findNameSpacePathsFor(List<DataType> dataTypePath,
//     bool Function(DataType nameSpace) filter) {
//   DataType nameSpace = dataTypePath.last;
//   List<List<DataType>> dataTypePaths = [];
//   if (filter(nameSpace)) {
//     dataTypePaths.add(dataTypePath);
//   }
//   for (var child in nameSpace.children) {
//     //recursive call
//     dataTypePaths
//         .addAll(_findNameSpacePathsFor([...dataTypePath, child], filter));
//   }
//   return dataTypePaths;
// }
}
