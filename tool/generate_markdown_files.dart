import 'package:documentation_builder/documentation_builder.dart';
import 'package:sysmac_cmd/domain/event.dart';

main() {
  EventPriorities.writeMarkDownTemplateFile();
  DocumentationBuilder().run();
}
