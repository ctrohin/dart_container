import 'package:dart_container/dart_container.dart';
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
  ContainerConfiguration? _containerConfiguration;

  static final Container _singleton = Container._internal();

  factory Container() {
    return _singleton;
  }

  Container._internal();

// ============ PUBLIC METHODS ======================

  /// Sets the container profile to be used to [newProfile]. Throws [ContainerException] if profile is already set
  Container profile(String newProfile) {
    if (_profile == defaultProfile) {
      _profile = newProfile;
    } else {
      throw ContainerException(
          "Profile $_profile is already active! Another profile cannot be selected while running!");
    }
    return this;
  }

  /// Sets the container configuration to [configuration].
  /// Throws [Exception] if the container is already populated, since the configuration
  /// can no longer be enforced.
  Container configuration(ContainerConfiguration configuration) {
    if (_registered.isNotEmpty) {
      throw ContainerException(
          "Cannot set the configuration after object have already been injected");
    }
    _containerConfiguration = configuration;
    return this;
  }

  String getProfile() {
    return _profile;
  }

  Container generic<T>({
    T? object,
    T Function()? builder,
    T Function()? factory,
    bool override = false,
    bool autoStart = false,
    String name = "",
    List<String> profiles = Container.defaultProfiles,
  }) {
    typed(T,
        object: object,
        builder: builder,
        factory: factory,
        override: override,
        autoStart: autoStart,
        name: name,
        profiles: profiles);
    return this;
  }

  Container typed(
    Type t, {
    dynamic object,
    dynamic Function()? builder,
    dynamic Function()? factory,
    bool override = false,
    bool autoStart = false,
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
      throw ContainerException(
          "You must specify one of the 'object', 'builder' or 'factory' parameters");
    }
    if (count > 1) {
      throw ContainerException(
          "You can only specify one of the 'object', 'builder' or 'factory' parameters");
    }
    switch (objType) {
      case ObjectType.simple:
        _registerTyped(
          t,
          object: object,
          override: override,
          name: name,
          profiles: profiles,
          autoStart: autoStart,
        );
        break;
      case ObjectType.factory:
        _registerTypedFactory(
          t,
          factory!,
          override: override,
          name: name,
          profiles: profiles,
          autoStart: autoStart,
        );
        break;
      case ObjectType.builder:
        _registerTypedLazy(
          t,
          builder!,
          override: override,
          name: name,
          profiles: profiles,
          autoStart: autoStart,
        );
        break;
    }
    return this;
  }

  T get<T>({String name = ""}) {
    if (!_registered.containsKey(ContainerKey(T, name))) {
      print(_registered);
      throw ContainerException(
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

  Container values(Map<String, dynamic> values,
      {List<String> profiles = defaultProfiles}) {
    values.forEach((key, value) {
      for (var profile in profiles) {
        _values[ValueKey(key, profile)] = value;
      }
    });
    return this;
  }

  Container value(String key, dynamic value,
      {List<String> profiles = defaultProfiles}) {
    for (var profile in profiles) {
      _values[ValueKey(key, profile)] = value;
    }
    return this;
  }

  T? getValueIfPresent<T>(String key, {T? defaultValue}) {
    ValueKey vKey = ValueKey(key, _profile);
    if (_values.containsKey(vKey)) {
      return _values[vKey] as T;
    }
    return defaultValue;
  }

  T getValue<T>(String key) {
    ValueKey vKey = ValueKey(key, _profile);
    if (!_values.containsKey(vKey)) {
      throw ContainerException(
          "No value was provided for key $key and profile $_profile");
    }
    return _values[vKey] as T;
  }

  Container clear() {
    _registered.clear();
    _values.clear();
    _profile = defaultProfile;
    return this;
  }

  Container autoStart() {
    for (var key in _registered.keys) {
      var obj = _registered[key];
      if (obj!.autoStart && obj.profiles.contains(_profile)) {
        _findAndBuildImpl(key.type, name: key.name);
      }
    }
    return this;
  }

  Container objects(
    Map<Type, dynamic> objects, {
    List<String> profiles = Container.defaultProfiles,
  }) {
    for (var mapEntry in objects.entries) {
      typed(mapEntry.key, object: mapEntry.value, profiles: profiles);
    }
    return this;
  }

  Container builders(
    Map<Type, Function()> builders, {
    List<String> profiles = Container.defaultProfiles,
  }) {
    for (var mapEntry in builders.entries) {
      typed(mapEntry.key, builder: mapEntry.value, profiles: profiles);
    }
    return this;
  }

  Container factories(
    Map<Type, Function()> factories, {
    List<String> profiles = Container.defaultProfiles,
  }) {
    for (var mapEntry in factories.entries) {
      typed(mapEntry.key, factory: mapEntry.value, profiles: profiles);
    }
    return this;
  }

  Container startable(
    Map<Type, Function()> builders, {
    List<String> profiles = Container.defaultProfiles,
  }) {
    for (var mapEntry in builders.entries) {
      typed(
        mapEntry.key,
        builder: mapEntry.value,
        profiles: profiles,
        autoStart: true,
      );
    }
    return this;
  }

//================== PRIVATE METHODS =================

  T _findAndBuild<T>({String name = ""}) {
    return _findAndBuildImpl(T, name: name);
  }

  dynamic _findAndBuildImpl(Type t, {String name = ""}) {
    ContainerObject? existing = _registered[ContainerKey(t, name)];
    if (existing == null || !existing.profiles.contains(_profile)) {
      print(_registered);
      throw ContainerException(
          "No object present in the container of type $t, name $name and profile $_profile");
    }

    if (existing.objectType == ObjectType.simple) {
      return existing.object;
    }

    if (existing.objectType == ObjectType.factory) {
      return (existing.object as Function)();
    }

    dynamic lazyObject = (existing.object as Function)();
    if (existing.autoStart && lazyObject is AutoStart) {
      lazyObject.init();
      (() async => lazyObject.run())();
    }
    _registered[ContainerKey(t, name)] = ContainerObject(
      lazyObject as Object,
      ObjectType.simple,
      existing.profiles,
      existing.autoStart,
    );
    return lazyObject;
  }

  void _registerTypedLazy(
    Type t,
    dynamic Function() builder, {
    bool override = false,
    bool autoStart = false,
    String name = "",
    List<String> profiles = defaultProfiles,
  }) {
    if (!override && _registered.containsKey(ContainerKey(t, name))) {
      throw ContainerException(
          "A value is already registered for type $t and name $name");
    }
    _registered[ContainerKey(t, name)] =
        ContainerObject(builder, ObjectType.builder, profiles, autoStart);
  }

  void _registerTypedFactory(
    Type t,
    dynamic Function() factory, {
    bool override = false,
    bool autoStart = false,
    String name = "",
    List<String> profiles = defaultProfiles,
  }) {
    if (!override && _registered.containsKey(ContainerKey(t, name))) {
      throw ContainerException(
          "A value is already registered for type $t and name $name");
    }
    _registered[ContainerKey(t, name)] =
        ContainerObject(factory, ObjectType.factory, profiles, autoStart);
  }

  void _registerTyped(
    Type t, {
    dynamic object,
    bool override = false,
    bool autoStart = false,
    String name = "",
    List<String> profiles = Container.defaultProfiles,
  }) {
    if (_containerConfiguration == null ||
        _containerConfiguration!.isPresent(t)) {
      if (!override && _registered.containsKey(ContainerKey(t, name))) {
        throw ContainerException(
            "A value is already registered for type $t and name $name");
      }
      _registered[ContainerKey(t, name)] = ContainerObject(
          object as Object, ObjectType.simple, profiles, autoStart);
    }
  }
}
