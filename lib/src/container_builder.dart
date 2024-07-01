import 'package:dart_container/dart_container.dart';
import 'package:dart_container/src/container.dart';

class ContainerBuilder {
  const ContainerBuilder();

  ContainerBuilder register<T>({
    T? object,
    T Function()? builder,
    T Function()? factory,
    bool override = false,
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
    );
    return this;
  }

  ContainerBuilder registerTyped(
    Type t, {
    dynamic object,
    dynamic Function()? builder,
    dynamic Function()? factory,
    bool override = false,
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
}
