import 'package:dart_container/src/container.dart';

class ContainerBuilder {
  const ContainerBuilder();

  ContainerBuilder register<T>(
    T object, {
    bool override = false,
    String name = "",
    List<String> profiles = Container.defaultProfiles,
  }) {
    Container().register<T>(
      object,
      override: override,
      name: name,
      profiles: profiles,
    );
    return this;
  }

  ContainerBuilder registerLazy<T>(
    T Function() builder, {
    bool override = false,
    String name = "",
    List<String> profiles = Container.defaultProfiles,
  }) {
    Container().registerLazy<T>(
      builder,
      override: override,
      name: name,
      profiles: profiles,
    );
    return this;
  }

  ContainerBuilder registerFactory<T>(
    T Function() factory, {
    bool override = false,
    String name = "",
    List<String> profiles = Container.defaultProfiles,
  }) {
    Container().registerFactory<T>(
      factory,
      override: override,
      name: name,
      profiles: profiles,
    );
    return this;
  }

  ContainerBuilder provideValue(
    String key,
    dynamic value, {
    List<String> profiles = Container.defaultProfiles,
  }) {
    Container().registerValue(key, value, profiles: profiles);
    return this;
  }

  ContainerBuilder provideValues(
    Map<String, dynamic> values, {
    List<String> profiles = Container.defaultProfiles,
  }) {
    Container().registerValues(values, profiles: profiles);
    return this;
  }

  ContainerBuilder setProfile(String profile) {
    Container().setProfile(profile);
    return this;
  }
}
