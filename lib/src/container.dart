import 'package:dart_container/src/container_configuration.dart';
import 'package:dart_container/src/container_key.dart';
import 'package:dart_container/src/container_object.dart';
import 'package:dart_container/src/object_type.dart';
import 'package:dart_container/src/value_key.dart';

class Container {
  final Map<ContainerKey, ContainerObject> _registered = {};
  final Map<ValueKey, dynamic> _values = {};
  static const String defaultProfile = "default";
  static const List<String> defaultProfiles = <String>[defaultProfile];
  String _profile = defaultProfile;
  ContainerConfiguration? _contaienrConfiguration;

  static final Container _singleton = Container._internal();

  factory Container() {
    return _singleton;
  }

  Container._internal();

  void setProfile(String newProfile) {
    if (_profile == defaultProfile) {
      _profile = newProfile;
    } else {
      throw Exception(
          "Profile $_profile is already active! Another profile cannot be selected while running!");
    }
  }

  void setConfiguration(ContainerConfiguration configuration) {
    _contaienrConfiguration = configuration;
  }

  String getProfile() {
    return _profile;
  }

  void _registerTyped(
    Type t, {
    dynamic object,
    bool override = false,
    String name = "",
    List<String> profiles = Container.defaultProfiles,
  }) {
    if (_contaienrConfiguration == null ||
        _contaienrConfiguration!.isPresent(t)) {
      if (!override && _registered.containsKey(ContainerKey(t, name))) {
        throw Exception(
            "A value is already registered for type $t and name $name");
      }
      _registered[ContainerKey(t, name)] =
          ContainerObject(object as Object, ObjectType.simple, profiles);
    }
  }

  void register<T>({
    T? object,
    T Function()? builder,
    T Function()? factory,
    bool override = false,
    String name = "",
    List<String> profiles = Container.defaultProfiles,
  }) {
    registerTyped(T,
        object: object,
        builder: builder,
        factory: factory,
        override: override,
        name: name,
        profiles: profiles);
  }

  void registerTyped(
    Type t, {
    dynamic object,
    dynamic Function()? builder,
    dynamic Function()? factory,
    bool override = false,
    String name = "",
    List<String> profiles = Container.defaultProfiles,
  }) {
    int count = 0;
    ObjectType objType = ObjectType.simple;
    if (object != null) {
      objType = ObjectType.simple;
      count++;
    }
    if (builder != null) {
      count++;
      objType = ObjectType.builder;
    }
    if (factory != null) {
      count++;
      objType = ObjectType.factory;
    }
    if (count == 0) {
      throw Exception(
          "You must specify one of the 'object', 'builder' or 'factory' parameters");
    }
    if (count > 1) {
      throw Exception(
          "You can only specify one of the 'object', 'builder' or 'factory' parameters");
    }
    switch (objType) {
      case ObjectType.simple:
        _registerTyped(t,
            object: object, override: override, name: name, profiles: profiles);
        return;
      case ObjectType.factory:
        _registerTypedFactory(t, factory!,
            override: override, name: name, profiles: profiles);
        return;
      case ObjectType.builder:
        _registerTypedLazy(t, builder!,
            override: override, name: name, profiles: profiles);
        return;
    }
  }

  void _registerTypedLazy(
    Type t,
    dynamic Function() builder, {
    bool override = false,
    String name = "",
    List<String> profiles = defaultProfiles,
  }) {
    if (!override && _registered.containsKey(ContainerKey(t, name))) {
      throw Exception(
          "A value is already registered for type $t and name $name");
    }
    _registered[ContainerKey(t, name)] =
        ContainerObject(builder, ObjectType.builder, profiles);
  }

  void _registerTypedFactory(
    Type t,
    dynamic Function() factory, {
    bool override = false,
    String name = "",
    List<String> profiles = defaultProfiles,
  }) {
    if (!override && _registered.containsKey(ContainerKey(t, name))) {
      throw Exception(
          "A value is already registered for type $t and name $name");
    }
    _registered[ContainerKey(t, name)] =
        ContainerObject(factory, ObjectType.factory, profiles);
  }

  T _findAndBuild<T>({String name = ""}) {
    ContainerObject? existing = _registered[ContainerKey(T, name)];
    if (existing == null || !existing.profiles.contains(_profile)) {
      print(_registered);
      throw Exception(
          "No object present in the container of type $T, name $name and profile $_profile");
    }

    if (existing.objectType == ObjectType.simple) {
      return existing.object as T;
    }

    if (existing.objectType == ObjectType.factory) {
      return (existing.object as Function)() as T;
    }

    T lazyObject = (existing.object as Function)() as T;
    _registered[ContainerKey(T, name)] = ContainerObject(
      lazyObject as Object,
      ObjectType.simple,
      existing.profiles,
    );
    return lazyObject;
  }

  T get<T>({String name = ""}) {
    if (!_registered.containsKey(ContainerKey(T, name))) {
      print(_registered);
      throw Exception(
          "No object of type $T and name $name found in the container");
    }
    return _findAndBuild<T>(name: name);
  }

  T? getIfPresent<T>({String name = ""}) {
    if (_registered.containsKey(ContainerKey(T, name))) {
      try {
        return _findAndBuild<T>(name: name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  void registerValues(Map<String, dynamic> values,
      {List<String> profiles = defaultProfiles}) {
    values.forEach((key, value) {
      for (var profile in profiles) {
        _values[ValueKey(key, profile)] = value;
      }
    });
  }

  void registerValue(String key, dynamic value,
      {List<String> profiles = defaultProfiles}) {
    for (var profile in profiles) {
      _values[ValueKey(key, profile)] = value;
    }
  }

  T? getValueIfPresent<T>(String key) {
    ValueKey vKey = ValueKey(key, _profile);
    if (_values.containsKey(vKey)) {
      return _values[vKey] as T;
    }
    return null;
  }

  T getValue<T>(String key) {
    ValueKey vKey = ValueKey(key, _profile);
    if (!_values.containsKey(vKey)) {
      throw Exception(
          "No value was provided for key $key and profile $_profile");
    }
    return _values[vKey] as T;
  }

  void clear() {
    _registered.clear();
    _values.clear();
    _profile = defaultProfile;
  }
}
