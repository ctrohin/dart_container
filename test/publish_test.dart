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
  });
}
