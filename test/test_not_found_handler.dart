import 'dart:async';

import 'package:dart_container/dart_container.dart';

class TestNotFoundHandler extends NotFoundHandler {
  @override
  FutureOr<Response> notFound(Request req) =>
      JsonResponse.badRequest({"error": "unknown"});
}
