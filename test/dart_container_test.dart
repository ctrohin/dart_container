import 'package:dart_container/dart_container.dart';
import 'package:test/test.dart';

void main() {
  group('Simple injection tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    tearDown(() {
      Container().clear();
    });

    test('Test register not named', () {
      injectorRegister<String>(object: "Test");
      expect(injectorGet<String>(), "Test");
    });

    test('Test register not named override', () {
      injectorRegister<String>(object: "Test");
      expect(injectorGet<String>(), "Test");
      injectorRegister<String>(object: "Test2", override: true);
      expect(injectorGet<String>(), "Test2");
    });

    test('Test register named', () {
      injectorRegister<String>(object: "Test second", name: "second");
      expect(injectorGet<String>(name: "second"), "Test second");
    });

    test('Test register named override', () {
      injectorRegister<String>(object: "Test second", name: "second");
      expect(injectorGet<String>(name: "second"), "Test second");
      injectorRegister<String>(
          object: "Test second 2", name: "second", override: true);
      expect(injectorGet<String>(name: "second"), "Test second 2");
    });

    test('Test register if present', () {
      expect(injectorGetIfPresent<String>(), null);
      injectorRegister<String>(object: "Test");
      expect(injectorGet<String>(), "Test");
      expect(injectorGetIfPresent<String>(), "Test");
    });

    test('Throw exception on register get with no object registered', () {
      try {
        injectorGet<String>();
        assert(false, true);
      } catch (e) {
        assert(e is ContainerException, true);
      }
    });
  });

  group('Lazy injection tests', () {
    tearDown(() {
      Container().clear();
    });

    test('Test register lazy', () {
      injectorRegister<String>(builder: () => "Test");
      expect(injectorGet<String>(), "Test");
      expect(injectorGetIfPresent<String>(), "Test");
    });

    test('Test register factory', () {
      injectorRegister<String>(
          factory: () => DateTime.now().microsecondsSinceEpoch.toString());
      String obj1 = injectorGet();
      String obj2 = injectorGet();
      expect(obj1 == obj2, false);
    });
  });

  group("Value injection tests", () {
    tearDown(() {
      Container().clear();
    });

    test('Test provide value', () {
      injectorProvideValue("test", "Test");
      expect(injectorGetValue("test"), "Test");
    });

    test('Test provide value if present', () {
      injectorProvideValue("test", "Test");
      expect(injectorGetValueIfPresent<String>("test"), "Test");
    });

    test('Throw exception on get value with no value set', () {
      try {
        injectorGetValue<String>("test");
        expect(false, true);
      } catch (e) {
        expect(e is ContainerException, true);
      }
    });

    test('Test inject null on value injection with no value set', () {
      expect(injectorGetValueIfPresent<String>("test"), null);
    });
  });

  group("Profile tests", () {
    tearDown(() {
      Container().clear();
    });

    test('Test register with profile inject for profile', () {
      Container().generic(
        object: "Test",
        profiles: ["Test"],
      ).generic(
        object: "Test",
        name: "testName",
        profiles: ["Test1"],
      ).profile("Test");
      expect(injectorGet<String>(), "Test");
      expect(injectorGetIfPresent<String>(name: "testName"), null);
    });

    test(
        'Test register with profile inject for profile throws exception when different profile',
        () {
      Container().generic(
        object: "Test",
        profiles: ["Test"],
      ).profile("Test1");
      try {
        injectorGet<String>();
        expect(true, false);
      } catch (e) {
        expect(e is ContainerException, true);
      }
    });

    test('Set the profile', () {
      injectorSetProfile("test");
      expect(injectorGetProfile(), "test");
    });

    test('Throw exception when trying to set the profile twice', () {
      try {
        injectorSetProfile("test");
        injectorSetProfile("test1");
        expect(false, true);
      } catch (e) {
        expect(e is ContainerException, true);
      }
    });
  });
}
