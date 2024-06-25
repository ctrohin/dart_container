import 'package:dart_container/src/dart_container_base.dart';
import 'package:test/test.dart';

void main() {
  group('Injector tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    tearDown(() {
      Container().clear();
    });

    test('Test not named', () {
      injectorRegister<String>("Test");
      expect(injectorGet<String>(), "Test");
    });

    test('Test not named override', () {
      injectorRegister<String>("Test");
      expect(injectorGet<String>(), "Test");
      injectorRegister<String>("Test2", override: true);
      expect(injectorGet<String>(), "Test2");
    });

    test('Test named', () {
      injectorRegister<String>("Test second", name: "second");
      expect(injectorGet<String>(name: "second"), "Test second");
    });

    test('Test named override', () {
      injectorRegister<String>("Test second", name: "second");
      expect(injectorGet<String>(name: "second"), "Test second");
      injectorRegister<String>("Test second 2", name: "second", override: true);
      expect(injectorGet<String>(name: "second"), "Test second 2");
    });

    test('Test if present', () {
      expect(injectorGetIfPresent<String>(), null);
      injectorRegister<String>("Test");
      expect(injectorGet<String>(), "Test");
      expect(injectorGetIfPresent<String>(), "Test");
    });

    test('Test lazy', () {
      injectorRegisterLazy<String>(() => "Test");
      expect(injectorGet<String>(), "Test");
      expect(injectorGetIfPresent<String>(), "Test");
    });

    test('Test factory', () {
      injectorRegisterFactory<String>(
          () => DateTime.now().microsecondsSinceEpoch.toString());
      String obj1 = injectorGet();
      String obj2 = injectorGet();
      expect(obj1 == obj2, false);
    });

    test('Throw exception on get with no object', () {
      try {
        String str = injectorGet();
        assert(false, true);
      } catch (e) {
        assert(e is Exception, true);
      }
    });

    test('Inject value', () {
      injectorProvideValue("test", "Test");
      expect(injectorGetValue("test"), "Test");
    });

    test('Inject value', () {
      injectorProvideValue("test", "Test");
      print(injectorGetValueIfPresent("test"));
      expect(injectorGetValueIfPresent<String>("test"), "Test");
    });

    test('Throw exception on get value with no value set', () {
      try {
        injectorGetValue<String>("test");
        assert(false, true);
      } catch (e) {
        print(e);
        assert(e is Exception, true);
      }
    });
  });
}
