import 'package:dart_container/dart_container.dart';

// Helper functions
void injectorRegister<T>({
  T? object,
  T Function()? builder,
  T Function()? factory,
  bool override = false,
  bool autoStart = false,
  String name = "",
  List<String> profiles = Container.defaultProfiles,
}) {
  Container().generic<T>(
    object: object,
    builder: builder,
    factory: factory,
    override: override,
    name: name,
    profiles: profiles,
    autoStart: autoStart,
  );
}

void injectorRegisterTyped(
  Type t, {
  dynamic object,
  dynamic Function()? builder,
  dynamic Function()? factory,
  bool override = false,
  bool autoStart = false,
  String name = "",
  List<String> profiles = Container.defaultProfiles,
}) {
  Container().typed(
    t,
    object: object,
    builder: builder,
    factory: factory,
    override: override,
    name: name,
    profiles: profiles,
    autoStart: autoStart,
  );
}

T injectorGet<T>({String name = ""}) {
  return Container().get<T>(name: name);
}

T? injectorGetIfPresent<T>({String name = ""}) {
  return Container().getIfPresent<T>(name: name);
}

void injectorProvideValue(
  String key,
  dynamic value, {
  List<String> profiles = Container.defaultProfiles,
}) {
  Container().value(key, value, profiles: profiles);
}

void injectorProvideValues(
  Map<String, dynamic> values, {
  List<String> profiles = Container.defaultProfiles,
}) {
  Container().values(values, profiles: profiles);
}

T injectorGetValue<T>(String key) {
  return Container().getValue<T>(key);
}

T? injectorGetValueIfPresent<T>(String key) {
  return Container().getValueIfPresent<T>(key);
}

void injectorSetProfile(String profile) {
  Container().profile(profile);
}

String injectorGetProfile() {
  return Container().getProfile();
}

void injectorSetConfiguration(ContainerConfiguration config) {
  Container().configuration(config);
}

void injectorAutoStart() {
  Container().autoStart();
}
