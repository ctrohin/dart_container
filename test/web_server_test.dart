import 'package:dart_container/dart_container.dart';
import 'package:test/test.dart';

import 'test_not_found_handler.dart';

void main() {
  group("Web server test", () {
    tearDown($().clear);
    setUp($().clear);

    test("Webserver boot", () {
      $()
          .webServerConfig(
            TestNotFoundHandler(),
            "localhost",
            6767,
          )
          .autoStart();
    });
  });
}
