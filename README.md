<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

This package provides a dependency injection solution for the Dart language.

## Features

- Simple injection: register an object instance. This will basically be treated as a Singleton object. Each injection call will return the same object
- Lazy injection: register a builder function producing an object. This function will be called when the first injection will be executed, then the same object will be returned on any subsequent injections
- Factory injection: register a factory function producing objects on each injection call
- Qualified name injection: the container supports qualified injection so you can provide a name for your dependency
- Injection profiles: you can register a certain object for a number of profiles, then inject or don't inject the value according to the selected profile. This feature is helpful if you want to run your application with different injection profiles
- Value injection: inject simple named values into the container

## Usage

### Simple injection

```dart
var myObject = MyClass();
var myProperty = "Prop value";
// Register with the container
ContainerBuilder()
    .register(object: myObject)
    .provideValue("myProperty", myProperty);

// Retrieve object
MyClass injectedObject = Container().get();
// Retrieve object if present
MyClass? injectedObjectIfPresent = Container().getIfPresent();

// You can also use helper methods
MyClass injectedObject = injectorGet();
MyClass? injectedObjectIfPresent = injectorGetIfPresent();

// Retreieve values
String property = Container().getValue("myProperty");
String? propertyIfPresent = Container().getValueIfPresent("myProperty");

//or use the helper methods
String property = injectorGetValue("myProperty");
String? propertyIfPresent = injectorGetValueIfPresent("myProperty");

```

### Lazy and factory injection

```dart
class SimpleObj {
    final String timestamp;
    SimpleObj(this.timestamp);
}
// Register with the container
ContainerBuilder()
    //Inject the builder function that will only be called once to create the container object
    .register(builder: () => MyClass())
    .register(factory: () => SimpleObj(DateTime.now().microsecondsSinceEpoch.toString()));

// Retrieve object
MyClass injectedObject = Container().get();
// Produce object using the injected factory
SimpleObj injectedObjectIfPresent = Container().get();

// You can also use helper methods
MyClass injectedObject = injectorGet();
SimpleObj injectedObjectIfPresent = injectorGet();
```

### Using profiles
```dart
var myObject = MyClass();
var myProperty = "Prop value";

// Register with the container
ContainerBuilder()
    .register(object: myObject, profiles: ["test", "run"])
    .provideValue("myProperty", myProperty, profiles: ["test", "run"])
    // Setting the active profile
    .setProfile("run");

// Retrieve object. The injection always uses the active profile when injecting any registered objects or provided values
// If the object is not present in the container for the active profile, this method will throw an exception
MyClass injectedObject = Container().get();
// Retrieve object if present. 
// If the object is not present in the container for the active profile, this method will return null
MyClass? injectedObjectIfPresent = Container().getIfPresent();

// Retreieve values. If the value does not exist on the active profile, this method will throw an exception
String property = Container().getValue("myProperty");
// If the value does not exist on the active profile, this method will return null
String? propertyIfPresent = Container().getValueIfPresent("myProperty");
```
