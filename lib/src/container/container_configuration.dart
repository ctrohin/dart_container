class ContainerConfiguration {
  late final Set<Type> _injectable;

  ContainerConfiguration(List<Type> injectable) {
    _injectable = Set.from(injectable);
  }

  bool isPresent(Type t) {
    return _injectable.contains(t);
  }
}
