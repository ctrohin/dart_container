class ContainerKey {
  final Type type;
  final String name;

  const ContainerKey(this.type, this.name);

  @override
  bool operator ==(Object other) {
    if (other is! ContainerKey) {
      return false;
    }
    return type == other.type && name == other.name;
  }

  @override
  int get hashCode => computeHash();

  int computeHash() {
    return ("$type||||||||$name").hashCode;
  }

  @override
  String toString() {
    return "type=$type name=$name";
  }
}
