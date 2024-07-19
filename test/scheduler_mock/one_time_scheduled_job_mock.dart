import 'package:dart_container/dart_container.dart';

class OneTimeScheduledJobMock extends ScheduledJob {
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
