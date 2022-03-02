import 'package:documentation_builder/documentation_builder.dart';
import '../test/domain/event/parser/example.dart';

main() {
  EventExamples().writeMarkDownTemplateFile();
  for (var eventExample in EventExamples()) {
    eventExample.writeMarkDownTemplateFile();
  }

  DocumentationBuilder().run(publishWikiPagesOnGitHub: true);
}