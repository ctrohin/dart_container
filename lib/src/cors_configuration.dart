import 'package:dart_container/dart_container.dart';

class CorsConfiguration {
  static final _allowOriginHeader = "Access-Control-Allow-Origin";
  static final _allowCredentialsHeader = "Access-Control-Allow-Credentials";

  String? _originHeader;
  bool? _credentialsHeader;

  late final Map<String, Object> Function(Request) headers;

  CorsConfiguration() {
    headers = _headers;
  }

  CorsConfiguration withOrigin(String allowOrigin) {
    _originHeader = allowOrigin;
    return this;
  }

  CorsConfiguration withCredentials(bool allowCredentials) {
    _credentialsHeader = allowCredentials;
    return this;
  }

  Map<String, Object> extraHeaders(Request request) {
    return {};
  }

  Map<String, Object> _headers(Request req) {
    Map<String, Object> hdr = extraHeaders(req);
    if (_originHeader != null) {
      hdr[_allowOriginHeader] = _originHeader as Object;
    }
    if (_credentialsHeader != null) {
      hdr[_allowCredentialsHeader] = _credentialsHeader as Object;
    }
    return hdr;
  }
}
