import 'package:petitparser/src/matcher/matches_skipping.dart';
import 'package:sysmac_generator/domain/event/parser/component_code_parser.dart';
import 'package:sysmac_generator/domain/event/parser/site_nr_parser.dart';
import 'package:sysmac_generator/domain/sysmac_project.dart';
import 'package:test/test.dart';

import 'example.dart';


class ComponentCodeSiteEventExample extends EventExample {

  @override
  bool get showSysmacFileNameTable => true;

  @override
  EventTableColumns get eventTableColumns =>
      EventTableColumns().withExpression.withComponentCode.withMessage;

  @override
  String get explanation =>
      "The [ComponentCode] in an [Event] begins with a site number. "
      "Each known processing plant has a unique number (also called a Meyn layout number)\n"
      "e.g. 4321 = Maple Leaf - London - Canada\n\n"
      "The default site number  comes from the the [SysmacProjectFile] name.\n\n"
      "You can override the site number by adding a site tag in one of the comments.\n\n"
      "A site tag has the following format: [site=&lt;number&gt;]\n"
          "E.g.: [site=1234]";


  @override
  Definition get definition => Definition()
    ..variableComment='[SiteNr=0]'
    ..addStruct('sEvent')
    ..addEvent(
        dataTypeName: 'event1',
        dataTypeComment: '110s3 system air pressure too low',
        groupName1: 'Event1',
        message: 'System air pressure too low',
        componentCode: ComponentCode(site: Site(0), electricPanel: electricPanel, pageNumber: 110, letters: 's', columnNumber: 3).toText());
}


main() {
  ComponentCodeSiteEventExample().executeTest();

  var parser=SiteNumberTagParser();
  group('$SiteNumberTagParser', () {
    test("'[SiteNr=123]' has correct result", () {
      var result = parser.parse('[SiteNr=123]');
      expect(result.value, SiteNumberTag(123));
    });
    test("'456 [sitenr=123]789' has correct result", () {
      var result = parser.matchesSkipping('456 [sitenr=123]789');
      expect(result[0], SiteNumberTag(123));
    });
    test("'456[ siteNr = 123 ]789' has correct result", () {
      var result = parser.matchesSkipping('456[ siteNr = 123 ]789');
      expect(result[0], SiteNumberTag(123));
    });
    test("'456[ siteNr =  ]789' has no result", () {
      var result = parser.matchesSkipping('456[ siteNr =  ]789');
      expect(result.isEmpty, true);
    });
    test("'456[ siteNr :12  ]789' has no result", () {
      var result = parser.matchesSkipping('456[ siteNr :12  ]789');
      expect(result.isEmpty, true);
    });
    test("'456[ siteNr =-12  ]789' has no result", () {
      var result = parser.matchesSkipping('456[ siteNr =-12  ]789');
      expect(result.isEmpty, true);
    });
  });
}