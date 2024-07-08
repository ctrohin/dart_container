import 'package:dart_container/dart_container.dart';

class WebServer extends AutoStart {
  final WebServerConfig config;
  late Router router;

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

    var handler =
        const Pipeline().addMiddleware(logRequests()).addHandler(router.call);

    var server = await serve(
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

  Response _getStatus(Request request) {
    return Response.ok(
        "Status response. Time is ${DateTime.now().toIso8601String()}");
  }

  Response _notFound(Request request) {
    return Response.notFound(
        "Route not found for ${request.method}:${request.requestedUri}");
  }
}
