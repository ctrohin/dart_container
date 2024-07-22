import 'package:dart_container/src/scheduled_job_type.dart';

abstract interface class ScheduledJob {
  void run();
  Duration? getDuration();
  DateTime? getStartTime();
  ScheduledJobType getType();
}
