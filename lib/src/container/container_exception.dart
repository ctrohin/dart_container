class ContainerException implements Exception {
  final String message;
  ContainerException(this.message);
  @override
  String toString() => "ContainerException: $message";
}
