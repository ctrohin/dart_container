import 'package:dart_container/dart_container.dart';

void main() {
  injectorRegister<String>(object: "Test");
  injectorRegister<String>(object: "Test2", name: "other");
  print('Getting by class unchecked: ${injectorGet<String>()}');
  print(
      'Getting by qualifier unchecked: ${injectorGet<String>(name: "other")}');
  print('Getting nullable: ${injectorGetIfPresent<int>()}');
}
