import 'package:dart_container/dart_container.dart';

class ContainerBuilder {
  const ContainerBuilder();

  ContainerBuilder register<T>({
    T? object,
    T Function()? builder,
    T Function()? factory,
    bool override = false,
    bool autoStart = false,
    String name = "",
    List<String> profiles = Container.defaultProfiles,
  }) {
    Container().register<T>(
      object: object,
      builder: builder,
      factory: factory,
      override: override,
      name: name,
      profiles: profiles,
      autoStart: autoStart,
    );
    return this;
  }

  ContainerBuilder registerTyped(
    Type t, {
    dynamic object,
    dynamic Function()? builder,
    dynamic Function()? factory,
    bool override = false,
    bool autoStart = false,
    String name = "",
    List<String> profiles = Container.defaultProfiles,
  }) {
    Container().registerTyped(
      t,
      object: object,
      builder: builder,
      factory: factory,
      override: override,
      name: name,
      profiles: profiles,
      autoStart: autoStart,
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

  ContainerBuilder setConfiguration(ContainerConfiguration configuration) {
    Container().setConfiguration(configuration);
    return this;
  }

  ContainerBuilder autoStart() {
    Container().autoStart();
    return this;
  }

  ContainerBuilder objects(
    Map<Type, dynamic> objects, {
    List<String> profiles = Container.defaultProfiles,
  }) {
    for (var mapEntry in objects.entries) {
      registerTyped(mapEntry.key, object: mapEntry.value, profiles: profiles);
    }
    return this;
  }

  ContainerBuilder builders(
    Map<Type, Function()> builders, {
    List<String> profiles = Container.defaultProfiles,
  }) {
    for (var mapEntry in builders.entries) {
      registerTyped(mapEntry.key, builder: mapEntry.value, profiles: profiles);
    }
    return this;
  }

  ContainerBuilder factories(
    Map<Type, Function()> factories, {
    List<String> profiles = Container.defaultProfiles,
  }) {
    for (var mapEntry in factories.entries) {
      registerTyped(mapEntry.key, factory: mapEntry.value, profiles: profiles);
    }
    return this;
  }

  ContainerBuilder startable(
    Map<Type, Function()> builders, {
    List<String> profiles = Container.defaultProfiles,
  }) {
    for (var mapEntry in builders.entries) {
      registerTyped(
        mapEntry.key,
        builder: mapEntry.value,
        profiles: profiles,
        autoStart: true,
      );
    }
    return this;
  }
}
