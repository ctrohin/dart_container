import 'package:dart_container/dart_container.dart';

abstract class RouteGuard {
  const RouteGuard();
  bool isSecure(Request request);
}

final class DefaultRouteGuard extends RouteGuard {
  const DefaultRouteGuard();
  @override
  bool isSecure(Request request) {
    return true;
  }
}

const DefaultRouteGuard defaultGuard = DefaultRouteGuard();
