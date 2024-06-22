import 'package:dart_container/src/container_key.dart';
import 'package:dart_container/src/container_object.dart';
import 'package:dart_container/src/object_type.dart';

class Container {
  final Map<ContainerKey, ContainerObject> _registered = {};

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
    _registered[ContainerKey(T, name)] =
        ContainerObject(object as Object, ObjectType.simple);
  }

  void registerLazy<T>(T Function() builder,
      {bool override = false, String name = ""}) {
    if (!override && _registered.containsKey(ContainerKey(T, name))) {
      throw Exception(
          "A value is already registered for type $T and name $name");
    }
    _registered[ContainerKey(T, name)] =
        ContainerObject(builder, ObjectType.builder);
  }

  void registerFactory<T>(T Function() factory,
      {bool override = false, String name = ""}) {
    if (!override && _registered.containsKey(ContainerKey(T, name))) {
      throw Exception(
          "A value is already registered for type $T and name $name");
    }
    _registered[ContainerKey(T, name)] =
        ContainerObject(factory, ObjectType.factory);
  }

  T _findAndBuild<T>({String name = ""}) {
    ContainerObject? existing = _registered[ContainerKey(T, name)];
    if (existing?.objectType != ObjectType.simple) {
      if (existing?.objectType == ObjectType.factory) {
        return (existing?.object as Function)() as T;
      } else {
        T lazyObject = (existing?.object as Function)() as T;
        _registered[ContainerKey(T, name)] =
            ContainerObject(lazyObject as Object, ObjectType.simple);
        return lazyObject;
      }
    }
    return existing?.object as T;
  }

  T get<T>({String name = ""}) {
    if (!_registered.containsKey(ContainerKey(T, name))) {
      throw Exception(
          "No object of type $T and name $name found in the container");
    }
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
