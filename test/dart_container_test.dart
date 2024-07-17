import 'package:dart_container/dart_container.dart';
import 'package:test/test.dart';

import 'auto_start_mock.dart';

void main() {
  group('Simple injection tests', () {
    setUp(() {
      $().clear();
      print("Setup called");
    });

    tearDown(() {
      print("Tear down");
      $().clear();
    });
    test('Test register not named', () {
      $().generic<String>(object: "Test");
      expect($$<String>(), "Test");
    });

    test('Test register not named override', () {
      $().generic<String>(object: "Test");
      expect($$<String>(), "Test");
      $().generic<String>(object: "Test2", override: true);
      expect($$<String>(), "Test2");
    });

    test('Test register named', () {
      $().generic<String>(object: "Test second", name: "second");
      expect($$<String>(name: "second"), "Test second");
    });

    test('Test register named override', () {
      $().generic<String>(object: "Test second", name: "second");
      expect($$<String>(name: "second"), "Test second");
      $().generic<String>(
          object: "Test second 2", name: "second", override: true);
      expect($$<String>(name: "second"), "Test second 2");
    });

    test('Test register if present', () {
      expect($$$<String>(), null);
      $().generic<String>(object: "Test");
      expect($$<String>(), "Test");
      expect($$$<String>(), "Test");
    });

    test('Throw exception on register get with no object registered', () {
      try {
        $$<String>();
        assert(false, true);
      } catch (e) {
        assert(e is ContainerException, true);
      }
    });
  });

  group('Lazy injection tests', () {
    setUp(() {
      $().clear();
      print("Setup called");
    });

    tearDown(() {
      print("Tear down");
      $().clear();
    });

    test('Test register lazy', () {
      $().generic<String>(builder: () => "Test");
      expect($$<String>(), "Test");
      expect($$$<String>(), "Test");
    });

    test('Test register factory', () {
      $().generic<String>(
          factory: () => DateTime.now().microsecondsSinceEpoch.toString());
      String obj1 = $$();
      String obj2 = $$();
      expect(obj1 == obj2, false);
    });
  });

  group("Value injection tests", () {
    setUp(() {
      $().clear();
      print("Setup called");
    });

    tearDown(() {
      print("Tear down");
      $().clear();
    });

    test('Test provide value', () {
      $().value("test", "Test");
      expect($$v("test"), "Test");
    });

    test('Test provide value if present', () {
      $().value("test", "Test");
      expect($$$v<String>("test"), "Test");
    });

    test('Throw exception on get value with no value set', () {
      try {
        $$v<String>("test");
        expect(false, true);
      } catch (e) {
        expect(e is ContainerException, true);
      }
    });

    test('Test inject null on value injection with no value set', () {
      expect($$$v<String>("test"), null);
    });

    tearDown($().clear);
  });

  group("Profile tests", () {
    setUp(() {
      $().clear();
      print("Setup called");
    });

    tearDown(() {
      print("Tear down");
      $().clear();
    });

    test('Test register with profile inject for profile', () {
      $().generic(
        object: "Test",
        profiles: ["Test"],
      ).generic(
        object: "Test",
        name: "testName",
        profiles: ["Test1"],
      ).profile("Test");
      expect($$<String>(), "Test");
      expect($$$<String>(name: "testName"), null);
    });

    test(
        'Test register with profile inject for profile throws exception when different profile',
        () {
      $().generic(
        object: "Test",
        profiles: ["Test"],
      ).profile("Test1");
      try {
        $$<String>();
        expect(true, false);
      } catch (e) {
        expect(e is ContainerException, true);
      }
    });

    test('Set the profile', () {
      $().profile("test");
      expect($().getProfile(), "test");
    });

    test('Throw exception when trying to set the profile twice', () {
      try {
        $().profile("test");
        $().profile("test1");
        expect(false, true);
      } catch (e) {
        expect(e is ContainerException, true);
      }
    });
  });

  group("Autostart tests", () {
    setUp(() {
      $().clear();
      print("Setup called");
    });

    tearDown(() {
      print("Tear down");
      $().clear();
    });

    test("Test init", () {
      $()
          .generic(
            builder: () => AutoStartMock(),
            autoStart: true,
            profiles: ["test"],
          )
          .profile("test")
          .autoStart();
      AutoStartMock mock = $$();
      expect(mock.initCalled, true);
    });
    test("Test run", () {
      $()
          .generic(
            builder: () => AutoStartMock(),
            autoStart: true,
            profiles: ["test"],
          )
          .profile("test")
          .autoStart();
      AutoStartMock mock = $$();
      expect(mock.runCalled, true);
    });
  });
}
