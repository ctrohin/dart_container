import 'package:dart_container/src/scheduler/scheduled_job_type.dart';

abstract interface class ScheduledJob {
  void run();
  Duration? getDuration();
  DateTime? getStartTime();
  ScheduledJobType getType();
}
