import 'dart:async';
import 'dart:io';

import 'package:dart_container/src/container/container_exception.dart';
import 'package:dart_container/src/webserver/cors_configuration.dart';
import 'package:dart_router_extended/dart_router_extended.dart';

class WebServerConfig {
  final Object address;
  final int port;
  final SecurityContext? securityContext;
  final int? backlog;
  final bool shared;
  final FutureOr<Response> Function(Request) notFoundHanlder;
  final List<Controller> controllers = [];
  final List<AbstractRoute> routes = [];
  final Map<String, Object>? staticCorsHeaders;
  final CorsConfiguration? corsBuilder;
  late RouteGuard? routeGuard;
  final bool Function(Request)? routeGuardHandler;
  WebServerConfig(
    this.notFoundHanlder,
    this.address,
    this.port, {
    this.securityContext,
    this.backlog,
    this.shared = false,
    this.staticCorsHeaders,
    this.corsBuilder,
    this.routeGuard,
    this.routeGuardHandler,
  }) {
    if (corsBuilder != null && staticCorsHeaders != null) {
      throw ContainerException(
          "Please specify one of corsBuilder or staticCorsHeaders. Cannot use both");
    }
    if (routeGuard == null && routeGuardHandler == null) {
      routeGuard = DefaultRouteGuard();
    }
  }

  void addControllers(List<Controller> controllers) {
    this.controllers.addAll(controllers);
  }

  void addRoutes(List<AbstractRoute> routes) {
    this.routes.addAll(routes);
  }
}
