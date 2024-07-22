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

## Usage

### Simple injection

```dart
var myObject = MyClass();
var myProperty = "Prop value";
// Register with the container
$().generic(object: myObject)
   .value("myProperty", myProperty);

// Retrieve object
MyClass injectedObject = $().get();

// Retrieve object if present
MyClass? injectedObjectIfPresent = $().getIfPresent();

// You can also use shortcut methods
MyClass injectedObject = $get();
MyClass? injectedObjectIfPresent = $$get();

// Retreieve values
String property = $().getValue("myProperty");
String? propertyIfPresent = $().getValueIfPresent("myProperty");

//or use the shortcut methods
String property = $val("myProperty");
String? propertyIfPresent = $$val("myProperty");

```

### Lazy and factory injection

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
SimpleObj injectedObjectIfPresent = $().get();

// You can also use shortcut methods
MyClass injectedObject = $get();
SimpleObj injectedObjectIfPresent = $$get();

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
    Lookup.object(MyClass), 
    Lookup.object(SimpleObject), 
    Lookup.value("valueKey")
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
class OneTimeScheduledJob extends ScheduledJob {
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
class PeriodicScheduledJob extends ScheduledJob {
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
class AtExactTimeScheduledJob extends ScheduledJob {
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