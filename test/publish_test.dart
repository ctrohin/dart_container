import 'dart:io';

import 'package:dart_container/dart_container.dart';
import 'package:test/test.dart';

void main() {
  group('Event publishing tests', () {
    setUp($().clear);
    tearDown($().clear);

    test("Test publish one topic, one subscriber", () {
      dynamic val;
      handler(String topic, dynamic value) {
        val = value;
      }

      $().subscribe("test", handler);
      $().publishEvent(["test"], "test");
      sleep(Duration(seconds: 2));
      expect(val, "test");
    });

    test("Test publish one topic, two subscribers", () {
      dynamic val1, val2;
      handler1(String topic, dynamic value) {
        val1 = value;
      }

      handler2(String topic, dynamic value) {
        val2 = value;
      }

      $().subscribe("test", handler1);
      $().subscribe("test", handler2);
      $().publishEvent(["test"], "test");
      sleep(Duration(seconds: 2));
      expect(val1, "test");
      expect(val2, "test");
    });

    test("Test publish two topics, one subscriber", () {
      int callCount = 0;
      handler(String topic, dynamic value) {
        callCount++;
      }

      $().subscribe("test1", handler);
      $().subscribe("test2", handler);

      $().publishEvent(["test1"], "test");
      $().publishEvent(["test2"], "test");
      sleep(Duration(seconds: 2));
      expect(callCount, 2);
    });

    test("Test publish two topics, two subscribers", () {
      dynamic val1, val2;
      handler1(String topic, dynamic value) {
        val1 = value;
      }

      handler2(String topic, dynamic value) {
        val2 = value;
      }

      $().subscribe("test1", handler1);
      $().subscribe("test2", handler2);

      $().publishEvent(["test1"], "test1");
      $().publishEvent(["test2"], "test2");
      sleep(Duration(seconds: 2));

      expect(val1, "test1");
      expect(val2, "test2");
    });

    test("Test wellformed topic", () {
      handler(String topic, dynamic value) {}
      bool success = false;
      try {
        $().subscribe("topic", handler);
        $().subscribe("topic/subtopic", handler);
        $().subscribe("topic/subtopic/*", handler);
        success = true;
      } catch (e) {
        success = false;
      }
      expect(success, true);
    });

    test("Test malformed topic", () {
      handler(String topic, dynamic value) {}
      bool success = true;
      try {
        $().subscribe("*topic", handler);
        success = true;
      } catch (e) {
        success = false;
      }
      expect(success, false);

      success = false;
      try {
        $().subscribe("topic*", handler);
        success = true;
      } catch (e) {
        success = false;
      }
      expect(success, false);

      success = true;
      try {
        $().subscribe("topic/subtopic*", handler);
        success = true;
      } catch (e) {
        success = false;
      }
      expect(success, false);

      success = true;
      try {
        $().subscribe("topic/subtopic/**", handler);
        success = true;
      } catch (e) {
        success = false;
      }
      expect(success, false);
    });

    test("Test malformed topic publish with wellformed subscribe topic",
        () async {
      bool success = true;
      try {
        await $().publishEvent(["topic/*"], null);
        success = true;
      } catch (e) {
        success = false;
      }
      expect(success, false);
    });

    test("Test malformed topic publish", () async {
      bool success = true;
      try {
        await $().publishEvent(["topic*"], null);
        success = true;
      } catch (e) {
        success = false;
      }
      expect(success, false);
    });

    test("Test publish wildcard", () async {
      List<String> val = [];

      $().subscribe("test/*", (topic, recv) {
        val.add(recv as String);
      });
      $().publishEvent(["test/val1"], "test1");
      $().publishEvent(["test/val2"], "test2");
      sleep(Duration(seconds: 2));

      expect(val, ["test1", "test2"]);
    });

    test("Test multiple topics, one handler", () async {
      List<String> val = [];

      handler(topic, recv) {
        val.add(recv as String);
      }

      $().subscribe("test/val1", handler);
      $().subscribe("test/val2", handler);

      $().publishEvent(["test/val1", "test/val2"], "test1");
      sleep(Duration(seconds: 2));

      expect(val, ["test1"]);
    });
  });
}
