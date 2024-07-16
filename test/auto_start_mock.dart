import 'package:dart_container/dart_container.dart';

class AutoStartMock implements AutoStart {
  bool initCalled = false;
  bool runCalled = false;
  @override
  void init() {
    initCalled = true;
  }

  @override
  void run() {
    runCalled = true;
  }
}
