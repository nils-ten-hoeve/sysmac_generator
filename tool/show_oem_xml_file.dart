import 'package:sysmac_generator/infrastructure/sysmac_project.dart';
import '../test/infrastructure/test_resource.dart';

main() {
  var sysmacProjectArchive =
      SysmacProjectArchive(SysmacProjectTestResource().file.path);
  print(sysmacProjectArchive.projectIndexXml.xmlDocument);
}
