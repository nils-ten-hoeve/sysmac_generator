import 'package:sysmac_cmd/infrastructure/sysmac/sysmac.dart';
import 'package:sysmac_cmd/infrastructure/sysmac/variable.dart';
import '../test/infrastructure/test_resource.dart';

main() {
  var sysmacProjectFile=SysmacProjectFile(SysmacProjectTestResource().file.path);
  for (var file in sysmacProjectFile.projectIndexXml.globalVariableArchiveXmlFiles()) {
    print (file.nameSpacePath);
    print(file.xmlDocument.toXmlString(pretty: true));
    print("");
  }
}