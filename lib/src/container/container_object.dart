import 'package:dart_container/src/container/object_type.dart';

class ContainerObject {
  final Object object;
  final ObjectType objectType;
  final List<String> profiles;
  bool autoStart;

  ContainerObject(this.object, this.objectType, this.profiles, this.autoStart);

  @override
  String toString() {
    return "type=$objectType object=$object profiles=$profiles autoStart=$autoStart";
  }
}
