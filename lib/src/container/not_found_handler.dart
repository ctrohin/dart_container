import 'dart:async';

import 'package:dart_container/dart_container.dart';

abstract class NotFoundHandler {
  FutureOr<Response> notFound(Request req);
}
