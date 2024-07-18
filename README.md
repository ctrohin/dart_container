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
MyClass injectedObject = $$();
MyClass? injectedObjectIfPresent = $$$();

// Retreieve values
String property = $().getValue("myProperty");
String? propertyIfPresent = $().getValueIfPresent("myProperty");

//or use the shortcut methods
String property = $$v("myProperty");
String? propertyIfPresent = $$$v("myProperty");

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
SimpleObj injectedObjectIfPresent = $().get();

// You can also use shortcut methods
MyClass injectedObject = $$();
SimpleObj injectedObjectIfPresent = $$();

// Conditional callback, call some code only if an object is present in the container
Container().ifPresentThen<MyClass>((MyClass obj) {
    print(obj);
});
// Or by using the shortcut method
$$$then<MyClass>((MyClass obj) {
    print(obj);
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
var myProperty = "Prop value";

// Register with the container for the interface instead of the type
$()
    .typed(MyInterface, object: myObject);

// If the object is not present in the container for the active profile, this method will throw an exception
MyClass injectedObject = $().get();
// Retrieve object if present. 
// If the object is not present in the container for the active profile, this method will return null
MyClass? injectedObjectIfPresent = $().getIfPresent();
```
