import 'package:dart_container/dart_container.dart';

typedef $ = Container;
final $then = $().ifPresentThen;
final $valThen = $().ifValuePresentThen;
final $allThen = $().ifAllPresentThen;
final $profile = $().getProfile;
final $val = $().getValue;
final $$val = $().getValueIfPresent;
final $get = $().get;
final $$get = $().getIfPresent;
final $pub = $().publishEvent;
final $sub = $().subscribe;
final $subTo = $().subscribeTo;
final $find = Lookup.object;
final $findVal = Lookup.value;
