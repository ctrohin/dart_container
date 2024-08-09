import 'package:dart_container/src/container/container.dart';

abstract class AbstractTopicHandler {
  TopicHandler buildTopicHandler();
  TopicHandler? _handler;

  TopicHandler getTopicHandler() {
    return _handler ??= buildTopicHandler();
  }
}
