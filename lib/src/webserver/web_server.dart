import 'dart:io';

import 'package:dart_container/dart_container.dart';

class WebServer implements AutoStart {
  final WebServerConfig config;
  late Router router;
  late HttpServer server;

  WebServer(this.config);

  @override
  void run() async {
    var routeBuilder = RouteBuilder(config.notFoundHanlder);
    for (var route in config.routes) {
      routeBuilder.route(route);
    }
    for (var controller in config.controllers) {
      routeBuilder.controller(controller);
    }
    router = routeBuilder.getRouter();

    var handler = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_cors)
        .addMiddleware(_security)
        .addHandler(router.call);

    server = await serve(
      handler,
      config.address,
      config.port,
      shared: config.shared,
      securityContext: config.securityContext,
      backlog: config.backlog,
    );

    // Enable content compression
    server.autoCompress = true;

    print('Serving at http://${server.address.host}:${server.port}');
  }

  Handler _security(Handler innerHandler) {
    print(innerHandler);
    return (request) async {
      var validationFn = config.routeGuard == null
          ? config.routeGuardHandler
          : config.routeGuard!.isSecure;

      if (validationFn!(request)) {
        final response = await innerHandler(request);
        return response;
      } else {
        return Response.unauthorized("");
      }
    };
  }

  Handler _cors(Handler innerHandler) {
    if (config.staticCorsHeaders != null && config.corsBuilder != null) {
      throw ContainerException(
          "Conflict! You can either specify static cors headers, or a cors builder");
    }
    return (request) async {
      final response = await innerHandler(request);
      // Set CORS when responding to OPTIONS request
      if (request.method == 'OPTIONS') {
        var corsHeaders = config.corsBuilder != null
            ? config.corsBuilder!.headers(request)
            : config.staticCorsHeaders;
        return Response.ok('', headers: corsHeaders);
      }

      // Move onto handler
      return response;
    };
  }

  void stop({bool force = false}) {
    server.close(force: force);
  }

  @override
  void init() {}
}
