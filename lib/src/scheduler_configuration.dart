import 'package:dart_container/src/scheduled_job.dart';

class SchedulerConfiguration {
  Duration initialDelay = Duration.zero;
  Duration pollingInterval = Duration(seconds: 10);
  final List<ScheduledJobWrapper> jobs = [];

  SchedulerConfiguration();

  void addJob(ScheduledJob job, List<String> profiles) {
    for (String profile in profiles) {
      jobs.add(ScheduledJobWrapper(job, profile));
    }
  }

  List<ScheduledJob> getJobsForProfile(String profile) {
    return jobs
        .where((job) => job.profile == profile)
        .map((elem) => elem.job)
        .toList();
  }
}

class ScheduledJobWrapper {
  final ScheduledJob job;
  final String profile;

  ScheduledJobWrapper(this.job, this.profile);
}
