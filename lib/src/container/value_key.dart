class ValueKey {
  final String key;
  final String profile;

  ValueKey(this.key, this.profile);
  @override
  bool operator ==(Object other) {
    if (other is! ValueKey) {
      return false;
    }
    return key == other.key && profile == other.profile;
  }

  @override
  int get hashCode => computeHash();

  int computeHash() {
    return ("$key||||||||$profile").hashCode;
  }
}
