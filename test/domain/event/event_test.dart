import 'package:sysmac_generator/domain/event/event.dart';
import 'package:test/test.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  group('EventPriority enum', () {
    test("EventPriority.valueOf('[prio=i]')", () {
      EventPriority.valueOf('[prio=i]').should.be(EventPriority.info);
    });

    test("EventPriority.valueOf('[prio=l]')", () {
      EventPriority.valueOf('[prio=l]').should.be(EventPriority.low);
    });

    test("EventPriority.valueOf('[prio=mL]')", () {
      EventPriority.valueOf('[prio=mL]').should.be(EventPriority.mediumLow);
    });

    test("EventPriority.valueOf('[PRIo=M]')", () {
      EventPriority.valueOf('[Prio=M]').should.be(EventPriority.medium);
    });

    test("EventPriority.valueOf('bla [PRIo=Mh]')", () {
      EventPriority.valueOf('bla [Prio=Mh]')
          .should
          .be(EventPriority.mediumHigh);
    });

    test("EventPriority.valueOf(' bla   [PRIo=C] bla ')", () {
      EventPriority.valueOf(' bla   [PRIo=C] bla ')
          .should
          .be(EventPriority.critical);
    });

    test("EventPriority.valueOf(' bla [PRIO=F]  [PRIo=C] bla ')", () {
      EventPriority.valueOf(' bla [PRIO=F]  [PRIo=C] bla ')
          .should
          .be(EventPriority.fatal);
    });
  });
}
