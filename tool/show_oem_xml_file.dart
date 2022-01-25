import 'package:sysmac_cmd/infrastructure/sysmac/sysmac.dart';
import '../test/infrastructure/test_resource.dart';

main() {
  var sysmacProjectFile=SysmacProjectFile(SysmacProjectTestResource().file.path);
  print(sysmacProjectFile.projectIndexXml.xmlDocument);
}