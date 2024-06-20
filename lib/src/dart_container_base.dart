import 'package:dart_container/src/container_key.dart';

class Container {
  final Map<ContainerKey, Object> _registered = {};
  final Set _factories = {};

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

  void registerLazy<T>(T Function() builder,
      {bool override = false, String name = ""}) {
    if (!override && _registered.containsKey(ContainerKey(T, name))) {
      throw Exception(
          "A value is already registered for type $T and name $name");
    }
    _registered[ContainerKey(T, name)] = builder;
  }

  void registerFactory<T>(T Function() factory,
      {bool override = false, String name = ""}) {
    if (!override && _registered.containsKey(ContainerKey(T, name))) {
      throw Exception(
          "A value is already registered for type $T and name $name");
    }
    _factories.add(factory);
    _registered[ContainerKey(T, name)] = factory;
  }

  T _findAndBuild<T>({String name = ""}) {
    Object? existing = _registered[ContainerKey(T, name)];
    if (existing is Function) {
      if (_factories.contains(existing)) {
        return existing() as T;
      } else {
        T lazyObject = existing() as T;
        _registered[ContainerKey(T, name)] = lazyObject as Object;
        return lazyObject;
      }
    }
    return existing as T;
  }

  T get<T>({String name = ""}) {
    return _findAndBuild<T>(name: name);
  }

  T? getIfPresent<T>({String name = ""}) {
    if (_registered.containsKey(ContainerKey(T, name))) {
      return _findAndBuild<T>(name: name);
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

void injectorRegisterLazy<T>(T Function() builder,
    {bool override = false, String name = ""}) {
  Container().registerLazy<T>(builder, override: override, name: name);
}

void injectorRegisterFactory<T>(T Function() factory,
    {bool override = false, String name = ""}) {
  Container().registerFactory<T>(factory, override: override, name: name);
}

T injectorGet<T>({String name = ""}) {
  return Container().get<T>(name: name);
}

T? injectorGetIfPresent<T>({String name = ""}) {
  return Container().getIfPresent<T>(name: name);
}
