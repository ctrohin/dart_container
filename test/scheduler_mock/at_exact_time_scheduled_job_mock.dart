import 'package:dart_container/dart_container.dart';

class AtExactTimeScheduledJobMock extends ScheduledJob {
  bool ran = false;
  @override
  Duration? getDuration() => null;

  @override
  DateTime? getStartTime() => DateTime.now().add(Duration(seconds: 3));

  @override
  ScheduledJobType getType() => ScheduledJobType.atExactTime;

  @override
  void run() {
    ran = true;
  }
}
