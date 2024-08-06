import 'dart:async';
import 'dart:io';

import 'package:dart_container/dart_container.dart';
import 'package:dart_container/src/container/container_key.dart';
import 'package:dart_container/src/container/container_object.dart';
import 'package:dart_container/src/container/object_type.dart';
import 'package:dart_container/src/scheduler/scheduler_configuration.dart';
import 'package:dart_container/src/container/value_key.dart';

typedef TopicHandler = FutureOr<void> Function(String, dynamic);

class Container {
  final Map<ContainerKey, ContainerObject> _registered = {};
  final Map<ValueKey, dynamic> _values = {};
  static const String defaultProfile = "default";
  static const List<String> defaultProfiles = <String>[defaultProfile];
  String _profile = defaultProfile;
  ContainerConfiguration? _containerConfiguration;
  WebServerConfig? _webServerConfig;
  SchedulerConfiguration? _schedulerConfig;
  final Set<String> _allowedTopics = {};
  final Map<String, List<TopicHandler>> _topicHandlers = {};

  static final Container _instance = Container._construct();

  factory Container() {
    return _instance;
  }

  Container._construct();

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

  /// Registers [object], [builder] or [factory] in the container for an
  /// optional [name] and optional list of [profiles] with [autoStart] for the
  /// type of the given [object]/[builder]/[factory]. [override] notifies the
  /// container that if an entity is already defined for the generic type, it is
  /// safe to override it
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

  /// Registers [object], [builder] or [factory] in the container for an
  /// optional [name] and optional list of [profiles] with [autoStart] for the
  /// type [t]. [override] notifies the
  /// container that if an entity is already defined for the generic type, it is
  /// safe to override it. This method is meant to be used for objects implementing
  /// interfaces.
  /// Example: typed(ServiceInterface, builder: () => Service())
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
    Function fn;
    dynamic obj;
    switch (objType) {
      case ObjectType.simple:
        fn = _registerTyped;
        obj = object;
        break;
      case ObjectType.factory:
        fn = _registerTypedFactory;
        obj = factory;
        break;
      case ObjectType.builder:
        fn = _registerTypedLazy;
        obj = builder;
        break;
    }
    fn(
      t,
      obj,
      override: override,
      name: name,
      profiles: profiles,
      autoStart: autoStart,
    );
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

  void ifPresentThen<T>(void Function(T) callback, {String name = ""}) {
    T? foundObj = getIfPresent(name: name);
    if (foundObj != null) {
      callback(foundObj);
    }
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

  void ifValuePresentThen<T>(String key, void Function(T) callback) {
    T? value = getValueIfPresent(key);
    if (value != null) {
      callback(value);
    }
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
    _allowedTopics.clear();
    Scheduler? sch = getIfPresent<Scheduler>();
    if (sch != null) {
      sch.stopSchedulers();
    }
    _schedulerConfig = null;
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
    Map<Type, dynamic Function()> builders, {
    List<String> profiles = Container.defaultProfiles,
  }) {
    for (var mapEntry in builders.entries) {
      typed(mapEntry.key, builder: mapEntry.value, profiles: profiles);
    }
    return this;
  }

  Container factories(
    Map<Type, dynamic Function()> factories, {
    List<String> profiles = Container.defaultProfiles,
  }) {
    for (var mapEntry in factories.entries) {
      typed(mapEntry.key, factory: mapEntry.value, profiles: profiles);
    }
    return this;
  }

  Container startable(
    Map<Type, dynamic Function()> builders, {
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

  Container webServerConfig(
    NotFoundHandler notFoundHandler,
    Object address,
    int port, {
    SecurityContext? securityContext,
    int? backlog,
    bool shared = false,
    List<String> profiles = defaultProfiles,
    CorsConfiguration? corsBuilder,
    Map<String, Object>? staticCorsHeaders,
    RouteGuard? routeGuard,
    bool Function(Request)? routeGuardHandler,
  }) {
    _webServerConfig = WebServerConfig(
      notFoundHandler.notFound,
      address,
      port,
      securityContext: securityContext,
      backlog: backlog,
      shared: shared,
      corsBuilder: corsBuilder,
      staticCorsHeaders: staticCorsHeaders,
      routeGuard: routeGuard,
      routeGuardHandler: routeGuardHandler,
    );
    typed(
      WebServer,
      builder: () => WebServer(_webServerConfig!),
      autoStart: true,
      profiles: profiles,
    );
    return this;
  }

  Container controllers(List<Controller> controllers) {
    if (_webServerConfig == null) {
      throw ContainerException(
          "WebServerConfiguration not present. Call .webServerConfig before adding controllers");
    }
    _webServerConfig!.addControllers(controllers);
    return this;
  }

  Container routes(List<AbstractRoute> routes) {
    if (_webServerConfig == null) {
      throw ContainerException(
          "WebServerConfiguration not present. Call .webServerConfig before adding routes");
    }
    _webServerConfig!.addRoutes(routes);
    return this;
  }

  void ifAllPresentThen(
      List<Lookup> lookups, dynamic Function(List<dynamic>) callback) {
    List<dynamic> list = List.empty(growable: true);
    for (Lookup lookup in lookups) {
      dynamic obj = lookup.lookupType == LookupType.object
          ? _getTypedIfPresent(lookup.type, name: lookup.name)
          : getValueIfPresent(lookup.name) as dynamic;
      if (obj == null) {
        return;
      }
      list.add(obj);
    }
    callback(list);
  }

  Container schedule(ScheduledJob job,
      {List<String> profiles = Container.defaultProfiles}) {
    if (_schedulerConfig == null) {
      _schedulerConfig = SchedulerConfiguration();
      typed(Scheduler,
          builder: () => Scheduler(_schedulerConfig!), autoStart: true);
      print("Added scheduler");
    }
    _schedulerConfig!.addJob(job, profiles);
    return this;
  }

  Container schedulerInitialDelay(Duration duration) {
    if (_schedulerConfig == null) {
      _schedulerConfig = SchedulerConfiguration();
      typed(Scheduler,
          builder: () => Scheduler(_schedulerConfig!), autoStart: true);
      print("Added scheduler");
    }
    _schedulerConfig!.initialDelay = duration;
    return this;
  }

  Container schedulerPollingInterval(Duration duration) {
    if (_schedulerConfig == null) {
      _schedulerConfig = SchedulerConfiguration();
      typed(Scheduler,
          builder: () => Scheduler(_schedulerConfig!), autoStart: true);
      print("Added scheduler");
    }
    _schedulerConfig!.pollingInterval = duration;
    return this;
  }

  Container allowedTopics(List<String> topics) {
    _allowedTopics.addAll(topics);
    return this;
  }

  Container subscribe(String topic, TopicHandler handler) {
    if (_allowedTopics.isNotEmpty && !_allowedTopics.contains(topic)) {
      throw ContainerException(
          "Cannot subscribe to topic $topic. The allowed topics are $_allowedTopics");
    }
    List<TopicHandler> handlers = _topicHandlers[topic] ?? [];
    handlers.add(handler);
    _topicHandlers[topic] = handlers;
    return this;
  }

  Future<void> publishEvent<T>(List<String> topics, T event) async {
    for (String topic in topics) {
      List<TopicHandler> handlers = _topicHandlers[topic] ?? [];
      for (TopicHandler handler in handlers) {
        _sendEvent(handler, topic, event);
      }
    }
  }

//================== PRIVATE METHODS =================
  Future<void> _sendEvent<T>(
      TopicHandler handler, String topic, T event) async {
    handler(topic, event);
  }

  T _findAndBuild<T>({String name = ""}) {
    return _findAndBuildImpl(T, name: name) as T;
  }

  dynamic _findAndBuildImpl(Type t, {String name = ""}) {
    ContainerObject? existing = _registered[ContainerKey(t, name)];
    if (existing == null || !existing.profiles.contains(_profile)) {
      print(_registered);
      throw ContainerException(
          "No object present in the container of type $t, name $name and profile $_profile");
    }

    // We have a simple singleton object
    if (existing.objectType == ObjectType.simple) {
      existing.autoStart = false;
      if (existing.autoStart && existing.object is AutoStart) {
        var obj = existing.object as AutoStart;
        // Cancel the autostart so that the object is started only once
        existing.autoStart = false;
        obj.init();
        (() async => obj.run())();
      }
      return existing.object;
    }

    // We have a factory
    if (existing.objectType == ObjectType.factory) {
      dynamic obj = (existing.object as Function)();
      if (existing.autoStart && obj is AutoStart) {
        obj.init();
        (() async => obj.run())();
      }
      return obj;
    }

    // We can only have a builder at this point
    dynamic obj = (existing.object as Function)();
    if (existing.autoStart && obj is AutoStart) {
      obj.init();
      (() async => obj.run())();
    }
    _registered[ContainerKey(t, name)] = ContainerObject(
      obj as Object,
      ObjectType.simple,
      existing.profiles,
      false,
    );
    return obj;
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
    Type t,
    dynamic object, {
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

  dynamic _getTypedIfPresent(Type t, {String name = ""}) {
    if (_registered.containsKey(ContainerKey(t, name))) {
      try {
        return _findAndBuildImpl(t, name: name);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
