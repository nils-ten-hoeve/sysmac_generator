import 'package:collection/collection.dart';

class NameSpace {
  final String name;
  final List<NameSpace> children = [];

  NameSpace(this.name);

  List<NameSpace> get descendants {
    List<NameSpace> all = [];
    for (var child in children) {
      all.add(child);
      all.addAll(child.descendants);
    }
    return all;
  }

  @override
  String toString() {
    String string = '$runtimeType {name: $name}';
    for (var child in children) {
      var lines = child.toString().split('\n');
      for (var line in lines) {
        string += "\n  $line";
      }
    }
    return string;
  }

  /// Tries to find a child using a list of [namesToFind]
  /// Returns this when [namesToFind] is empty.
  /// Returns null when a name can't be found.
  NameSpace? findNamePath(List<String> namesToFind) {
    if (namesToFind.isEmpty) {
      return this;
    }
    var childNameToFind = namesToFind.first;
    NameSpace? foundChild =
        children.firstWhereOrNull((child) => child.name == childNameToFind);
    if (foundChild == null) {
      return null;
    }
    if (namesToFind.length == 1) {
      return foundChild;
    } else {
      //try to find rest of the names
      namesToFind.removeAt(0);
      return foundChild.findNamePath(namesToFind);
    }
  }

  NameSpace? findNamePathString(String pathToFind) =>
      findNamePath(pathToFind.split('\\'));

  NameSpace? findFirst(bool Function(NameSpace nameSpace) predicate) {
    if (predicate(this)) {
      return this;
    }
    for (var child in children) {
      //recursive call
      var found = child.findFirst(predicate);
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  List<NameSpace> findPath(
    NameSpace nameSpaceToFind, [
    List<NameSpace> currentPath = const [],
  ]) {
    currentPath = [...currentPath, this];
    if (nameSpaceToFind.toString() == toString()) {
      return currentPath;
    }
    for (var child in children) {
      //recursive call
      var result = child.findPath(nameSpaceToFind, currentPath);
      if (result.isNotEmpty) {
        return result;
      }
    }
    return [];
  }
}

class NameSpaceWithComment extends NameSpace {
  final String comment;

  NameSpaceWithComment(String name, this.comment) : super(name);
}
