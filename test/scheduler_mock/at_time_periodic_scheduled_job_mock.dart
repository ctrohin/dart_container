import 'package:dart_container/dart_container.dart';

class AtTimePeriodicScheduledJobMock extends ScheduledJob {
  int count = 0;
  @override
  Duration getDuration() => Duration(seconds: 2);

  @override
  DateTime? getStartTime() => DateTime.now().add(Duration(seconds: 3));

  @override
  ScheduledJobType getType() => ScheduledJobType.atTimeRepeating;

  @override
  void run() {
    count++;
  }
}
