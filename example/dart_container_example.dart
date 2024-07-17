import 'package:dart_container/dart_container.dart';

void main() {
  $().generic<String>(object: "Test");
  $().generic<String>(object: "Test2", name: "other");
  print('Getting by class unchecked: ${$$<String>()}');
  print('Getting by qualifier unchecked: ${$$<String>(name: "other")}');
  print('Getting nullable: ${$$$<int>()}');
}
