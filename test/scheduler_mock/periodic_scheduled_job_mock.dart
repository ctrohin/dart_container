import 'package:dart_container/dart_container.dart';

class PeriodicScheduledJobMock extends ScheduledJob {
  int runTimes = 0;
  @override
  Duration getDuration() => Duration(seconds: 1);

  @override
  ScheduledJobType getType() => ScheduledJobType.periodic;

  @override
  DateTime? getStartTime() => null;

  @override
  void run() {
    runTimes++;
  }
}
