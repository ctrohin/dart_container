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

  String getProfile() {
    return _profile;
  }

  void register<T>(
    T object, {
    bool override = false,
    String name = "",
    List<String> profiles = Container.defaultProfiles,
  }) {
    if (!override && _registered.containsKey(ContainerKey(T, name))) {
      throw Exception(
          "A value is already registered for type $T and name $name");
    }
    _registered[ContainerKey(T, name)] =
        ContainerObject(object as Object, ObjectType.simple, profiles);
  }

  void registerLazy<T>(
    T Function() builder, {
    bool override = false,
    String name = "",
    List<String> profiles = defaultProfiles,
  }) {
    if (!override && _registered.containsKey(ContainerKey(T, name))) {
      throw Exception(
          "A value is already registered for type $T and name $name");
    }
    _registered[ContainerKey(T, name)] =
        ContainerObject(builder, ObjectType.builder, profiles);
  }

  void registerFactory<T>(
    T Function() factory, {
    bool override = false,
    String name = "",
    List<String> profiles = defaultProfiles,
  }) {
    if (!override && _registered.containsKey(ContainerKey(T, name))) {
      throw Exception(
          "A value is already registered for type $T and name $name");
    }
    _registered[ContainerKey(T, name)] =
        ContainerObject(factory, ObjectType.factory, profiles);
  }

  T _findAndBuild<T>({String name = ""}) {
    ContainerObject? existing = _registered[ContainerKey(T, name)];
    if (existing == null || !existing.profiles.contains(_profile)) {
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
