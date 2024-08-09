# Description
This package provides a dependency injection solution for the Dart language, as well as a application server based on [dart_router_extended].

## Features

- Simple injection: register an object instance. This will basically be treated as a Singleton object. Each injection call will return the same object
- Lazy injection: register a builder function producing an object. This function will be called when the first injection will be executed, then the same object will be returned on any subsequent injections
- Factory injection: register a factory function producing objects on each injection call
- Qualified name injection: the container supports qualified injection so you can provide a name for your dependency
- Injection profiles: you can register a certain object for a number of profiles, then inject or don't inject the value according to the selected profile. This feature is helpful if you want to run your application with different injection profiles
- Value injection: inject simple named values into the container
- Web server configuration
- Web routes and controllers support
- Web routes security using route guard
- CORS configuration support
- Scheduled tasks support
- Eventing support

## Usage

### Simple injection

```dart
var myObject = MyClass();
var myProperty = "Prop value";
// Register an object with the container
$().generic(object: myObject)
   // then register a value
   .value("myProperty", myProperty)
   // then register a named object. This also works with builders and factories
   .generic(object: myObject, name: "alias");

// Retrieve object
MyClass injectedObject = $().get();
// Retrieved the qualified object
MyClass injectedObjectAlias = $().get(name: "alias");

// Retrieve object if present
MyClass? injectedObjectIfPresent = $().getIfPresent();
// Retrieve the qualified object 
MyClass? injectedAliasObjectIfPresent = $().getIfPresent(name: "alias");

// You can also use shortcut methods
MyClass injectedObject = $get();
MyClass injectedObjectAlias = $get(name: "alias");
MyClass? injectedObjectIfPresent = $$get();

// Retreieve values
String property = $().getValue("myProperty");
String? propertyIfPresent = $().getValueIfPresent("myProperty");

//or use the shortcut methods
String property = $val("myProperty");
String? propertyIfPresent = $$val("myProperty");

```

### Builder and factory injection

Both the builder and the factories are practically methods that are used to build the container object, with the difference that with a factory, the method is called every time the object is retrieved from the container, while with the builder it is only built once, then the same instance returned, making it basically a lazy buildable singleton.

```dart
class SimpleObj {
    final String timestamp;
    SimpleObj(this.timestamp);
}
// Register with the container
$()
    //Inject the builder function that will only be called once to create the container object
    .generic(builder: () => MyClass())
    .generic(factory: () => SimpleObj(DateTime.now().microsecondsSinceEpoch.toString()));

// Retrieve object
MyClass injectedObject = $().get();
// Produce object using the injected factory
SimpleObj injectedObjectIfPresent = $().getIfPresent();

// You can also use shortcut methods
MyClass injectedObject = $get();
SimpleObj injectedObjectIfPresent = $$get();
```

### Conditional callbacks

```dart
class SimpleObj {
    final String timestamp;
    SimpleObj(this.timestamp);
}
// Register with the container
$()
    //Inject the builder function that will only be called once to create the container object
    .generic(builder: () => MyClass())
    .generic(factory: () => SimpleObj(DateTime.now().microsecondsSinceEpoch.toString()));

// Retrieve object
MyClass injectedObject = $().get();
// Produce object using the injected factory
SimpleObj? injectedObjectIfPresent = $().getIfPresent();

// You can also use shortcut methods
MyClass injectedObject = $get();
SimpleObj? injectedObjectIfPresent = $$get();

// Conditional callback, call some code only if an object is present in the container
Container().ifPresentThen<MyClass>((MyClass obj) {
    print(obj);
});
// Or by using the shortcut method
$then<MyClass>((MyClass obj) {
    print(obj);
});

// Conditional callback. Call some code only if a value is present in the container
$().ifValuePresentThen("valueKey", (value) {
    print(value);
});
// Or by using the shortcut method
$valThen("valueKey", (value) {
    print(value);
});

// Conditional callback with multiple dependencies. The container will invoke the callback
// only if all dependencies are found.
$().ifAllPresentThen([
    Lookup.object(MyClass), 
    Lookup.object(SimpleObject), 
    Lookup.value("valueKey")
    ], (list) {
        MyClass? myClass;
        SimpleObject? simpleObject;
        String? value;
        [myClass, simpleObject, value] = list;
});
// Or by calling the shortcut method
$allThen([
    $look(MyClass), 
    $look(SimpleObject), 
    $lookVal("valueKey")
    ], (list) {
        MyClass? myClass;
        SimpleObject? simpleObject;
        String? value;
        [myClass, simpleObject, value] = list;
});
```

### Using profiles
```dart
var myObject = MyClass();
var myProperty = "Prop value";

// Register with the container
$()
    .generic(object: myObject, profiles: ["test", "run"])
    .value("myProperty", myProperty, profiles: ["test", "run"])
    // Setting the active profile
    .profile("run");

// Retrieve object. The injection always uses the active profile when injecting any registered objects or provided values
// If the object is not present in the container for the active profile, this method will throw an exception
MyClass injectedObject = $().get();
// Retrieve object if present. 
// If the object is not present in the container for the active profile, this method will return null
MyClass? injectedObjectIfPresent = $().getIfPresent();

// Retreieve values. If the value does not exist on the active profile, this method will throw an exception
String property = $().getValue("myProperty");
// If the value does not exist on the active profile, this method will return null
String? propertyIfPresent = $().getValueIfPresent("myProperty");
```

### Injecting objects for interfaces
```dart

class MyInterface {
    void doSomething() {}
}

class MyClass implements MyInterface {
    @override
    void doSomething() {
        print("Something");
    }
}

var myObject = MyClass();

// Register with the container for the interface instead of the type
$().typed(MyInterface, object: myObject);

// If the object is not present in the container for the active profile, this method will throw an exception
MyInterface injectedObject = $().get();
// Retrieve object if present. 
// If the object is not present in the container for the active profile, this method will return null
MyInterface? injectedObjectIfPresent = $().getIfPresent();
```

### Autostartable objects
Sometimes you might need to run some code, or start a webserver (the build in web server is also an AutoStart implementation). This iw why *dart_container* implements autostartable functionality.

```dart
class AutoStartMock implements AutoStart {
  @override
  void init() {
    print("Init called");
  }

  @override
  void run() {
    print("Run called");
  }
}

$().generic(builder: () => AutoStartMock(), autoStart: true)
  // Once autostart is called, the init method is called first for the AutoStart objects,
  // then the run method is called asynchronously, to avoid blocking the container and any other functionality
  .autoStart();
```

### Scheduled jobs

#### Configuring the scheduler
```dart
// Sets the timer polling interval to the specified duration
// The polling interval is useful if you have scheduled tasks running at long periods
// of time. Longer periods will lessen the CPU load but will also reduce trigger time accuracy
// The default value, if not specified, is 10 seconds
$().schedulerPollingInterval(Duration(seconds: 1));

// Will delay all tasks from starting by the specified duration
$().schedulerInitialDelay(Duration(seconds: 10));

```

#### One time scheduled job
```dart
class OneTimeScheduledJob implements ScheduledJob {
  bool hasRun = false;
  @override
  Duration? getDuration() => Duration(seconds: 1);

  @override
  ScheduledJobType getType() => ScheduledJobType.oneTime;

  @override
  void run() {
    hasRun = true;
  }

  @override
  DateTime? getStartTime() => null;
}

// Will run scheduled task after 1 second, as provided by the getDuration implementation
$().schedule(oneTime).autoStart();

```

#### Periodic scheduled job
```dart
class PeriodicScheduledJob implements ScheduledJob {
  int runTimes = 0;
  @override
  Duration? getDuration() => Duration(seconds: 1);

  @override
  ScheduledJobType getType() => ScheduledJobType.periodic;

  @override
  DateTime? getStartTime() => null;

  @override
  void run() {
    runTimes++;
  }
}

// Will run immediately, then at every 1 second as specified by the getDuration implementation
PeriodicScheduledJob periodic = PeriodicScheduledJob();
$().schedule(periodic).autoStart();

```

#### At exact time scheduled job
```dart
class AtExactTimeScheduledJob implements ScheduledJob {
  bool ran = false;
  @override
  Duration? getDuration() => null;

  @override
  DateTime? getStartTime() => DateTime.now().add(Duration(seconds: 3));

  @override
  ScheduledJobType getType() => ScheduledJobType.atExactTime;

  @override
  void run() {
    ran = true;
  }
}

AtExactTimeScheduledJob atTime = AtExactTimeScheduledJob();

// Will run after 3 seconds
$().schedulerPollingInterval(Duration(seconds: 1))
  .schedule(atTime)
  .autoStart();

```

#### At exact time repeating scheduled job
```dart
class AtExactTimeRepeatingScheduledJob extends ScheduledJob {
  bool ran = false;
  @override
  Duration? getDuration() => Duration(seconds: 2);

  @override
  DateTime? getStartTime() => DateTime.now().add(Duration(seconds: 3));

  @override
  ScheduledJobType getType() => ScheduledJobType.atExactTime;

  @override
  void run() {
    ran = true;
  }
}

AtExactTimeScheduledJob atTime = AtExactTimeScheduledJob();

// Will run after 3 seconds, then run every other 2 seconds
$().schedulerPollingInterval(Duration(seconds: 1))
  .schedule(atTime)
  .autoStart();

```

### Web server
*dart_container* includes a built in webserver that can be easily configured using Controllers and Routes.

```dart
class StausController extends Controller {
  StatusController()
      : super(
        // All the routes under a controller are mounted under the controller prefix
          pathPrefix: "/status",
          routes: [
            GetStatusRoute(),
            PostStatusRoute(),
          ],
          // The guard allows secured access to routes. If you don't want anyone accessing a route or
          // controller, you can implement a guard
          guard: StatusGuard(),
        );
}

class StatusGuard extends RouteGuard {
  @override
  bool isSecure(Request request) {
    return true;
  }
}

class GetStatusRoute extends AbstractRoute {
  GetStatusRoute()
      : super(
        // All the route parsing is fully compatible with shelf_router since that is the actual library used
          ["/<key>"],
          Method.get,
        );
  
  @override
  Function buildHandler() {
    return _respond;
  }

  Response _respond(Request req, String key) {
    return JsonResponse.okJson({key: "requested"});
  }
}

class PostStatusRoute extends AbstractRoute {
  PostStatusRoute()
      : super(
          ["/<key>"],
          Method.post,
        );

  @override
  Function buildHandler() {
    return _respond;
  }

  Response _respond(Request req, String key) async {
    return JsonResponse.ok({key: "posted"});
  }

}

$().webServerConfig(
  // First of all, we need a not found handler
    (req) => Response.notFound(
        "Route not found for ${req.method}:${req.requestedUri}"),
    // the host
    'localhost',
    // and the port
    env.httpPort,
    shared: true,
    profiles: ["test", "run"],
  )
  // Provide the list of controllers
  .controllers([
    StatusController();
  ])
  // and/or provide a list of routes
  .routes([
    GetStatusRoute(),
    PostStatusRoute(),
  ])
  // set the active profile
  .profile("run")
  // the call autostart to boot up the web server
  .autoStart();

  // If you do not want to use the autostartables and still want to boot up the web server, you can
  Future.delayed(Duration.zero, () async => $get<WebServer>().run());
  .
```

### Eventing
With dart-container you get a simple publish/subscribe framework for passing along messages, and building reactive applications. For the time being, the support is limited to exact matching topics.


```dart

// First subscribe to the topic
$().subscribe("topic", (topic, event) {
  print("Got message on topic $topic with event value $event");
});

// Then publish to the topic
$().publishEvent(["topic"], "newValue");

// You can also subscribe and publish to multiple topics

// Publishing to multiple subscribers
$().subscribe("topic1", (topic, event) {
  print("Subscriber 1 : Got message on topic $topic with event value $event");
});

$().subscribe("topic2", (topic, event) {
  print("Subscriber 2 : Got message on topic $topic with event value $event");
});

// or use the shortcut
// $sub("topic2", (topic, event) {
//  print("Subscriber 2 : Got message on topic $topic with event value $event");
//});


// Publish a message to multiple topics.
// In this case, both subscribers will get the new message.
$().publishEvent(["topic1", "topic2"], "newValue");
// or use the shortcut
// $pub(["topic1", "topic2"], "newValue");

```