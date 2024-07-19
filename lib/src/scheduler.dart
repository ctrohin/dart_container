import 'dart:async';

import 'package:dart_container/dart_container.dart';
import 'package:dart_container/src/scheduler_configuration.dart';

class Scheduler implements AutoStart {
  late final SchedulerConfiguration _config;
  final List<Timer> _timers = [];
  Scheduler(SchedulerConfiguration config) {
    _config = config;
  }
  @override
  void init() {}

  @override
  void run() async {
    Future.delayed(_config.initialDelay, () => _runImpl());
  }

  void _runImpl() {
    print("Starting scheduler");
    String profile = $().getProfile();
    List<ScheduledJob> jobs = _config.getJobsForProfile(profile);
    List<ScheduledJob> exactTimeJobs = [];
    for (ScheduledJob job in jobs) {
      if (job.getType() == ScheduledJobType.oneTime) {
        Future.delayed(job.getDuration(), () => job.run());
      } else if (job.getType() == ScheduledJobType.periodic) {
        _timers.add(Timer.periodic(job.getDuration(), (t) => job.run()));
      } else {
        if (job.getStartTime() == null) {
          throw ContainerException(
              "Exact time scheduled jobs must provide a start time");
        }
        exactTimeJobs.add(job);
      }
    }
    if (exactTimeJobs.isNotEmpty) {
      _startExactTimeSchedulers(exactTimeJobs);
    }
  }

  void _startExactTimeSchedulers(List<ScheduledJob> jobs) {
    var t = Timer.periodic(_config.pollingInterval, (t) {
      var now = DateTime.now();
      List<ScheduledJob> removedJobs = [];
      for (ScheduledJob job in jobs) {
        // We have an exact time job.
        if (job.getType() == ScheduledJobType.atExactTime &&
            job.getStartTime()!.isAfter(now)) {
          // If we've reached the trigger time, or just after it, run the job
          removedJobs.add(job);
          print("Starting exact time job");
          Future.delayed(Duration.zero, () => job.run());
        } else if (job.getType() == ScheduledJobType.atTimeRepeating &&
            job.getStartTime()!.isAfter(now)) {
          // If we've reached the trigger time, or just after it, run the job
          removedJobs.add(job);
          print("Starting exact time periodic job");
          _timers.add(Timer.periodic(job.getDuration(), (t) => job.run()));
        }
      }
      for (ScheduledJob removedJob in removedJobs) {
        jobs.remove(removedJob);
      }
    });
    _timers.add(t);
  }

  void stopSchedulers() {
    for (Timer t in _timers) {
      t.cancel();
    }
  }
}
