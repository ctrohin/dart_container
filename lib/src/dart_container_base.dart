import 'package:dart_container/dart_container.dart';

typedef $ = Container;
final $then = Container().ifPresentThen;
final $valThen = Container().ifValuePresentThen;
final $allThen = Container().ifAllPresentThen;
final $profile = Container().getProfile;
final $val = Container().getValue;
final $$val = Container().getValueIfPresent;
final $get = Container().get;
final $$get = Container().getIfPresent;
