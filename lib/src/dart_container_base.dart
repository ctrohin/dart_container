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
}

class Container {
  final Map<ContainerKey, Object> _registered = {};
  static final Container _singleton = Container._internal();

  factory Container() {
    return _singleton;
  }

  Container._internal();

  void register<T>(T object, {bool override = false, String name = ""}) {
    if (!override && _registered.containsKey(ContainerKey(T, name))) {
      throw Exception(
          "A value is already registered for type $T and name $name");
    }
    _registered[ContainerKey(T, name)] = object as Object;
  }

  T get<T>({String name = ""}) {
    return _registered[ContainerKey(T, name)] as T;
  }

  T? getIfPresent<T>({String name = ""}) {
    if (_registered.containsKey(ContainerKey(T, name))) {
      return _registered[ContainerKey(T, name)] as T;
    }
    return null;
  }

  void clear() {
    _registered.clear();
  }
}

void injectorRegister<T>(T object, {bool override = false, String name = ""}) {
  Container().register<T>(object, override: override, name: name);
}

T injectorGet<T>({String name = ""}) {
  return Container().get<T>(name: name);
}

T? injectorGetIfPresent<T>({String name = ""}) {
  return Container().getIfPresent<T>(name: name);
}
