import 'dart:async';
import 'dart:io';

import 'package:dart_router_extended/dart_router_extended.dart';
import 'package:shelf/shelf.dart';

class WebServerConfig {
  final Object address;
  final int port;
  final SecurityContext? securityContext;
  final int? backlog;
  final bool shared;
  final FutureOr<Response> Function(Request) notFoundHanlder;
  final List<Controller> controllers = [];
  final List<AbstractRoute> routes = [];
  WebServerConfig(
    this.notFoundHanlder,
    this.address,
    this.port, {
    this.securityContext,
    this.backlog,
    this.shared = false,
  });

  void addControllers(List<Controller> controllers) {
    this.controllers.addAll(controllers);
  }

  void addRoutes(List<AbstractRoute> routes) {
    this.routes.addAll(routes);
  }
}