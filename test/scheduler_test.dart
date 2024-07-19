import 'package:dart_container/dart_container.dart';
import 'package:test/test.dart';

import 'scheduler_mock/at_exact_time_scheduled_job_mock.dart';
import 'scheduler_mock/at_time_periodic_scheduled_job_mock.dart';
import 'scheduler_mock/one_time_scheduled_job_mock.dart';
import 'scheduler_mock/periodic_scheduled_job_mock.dart';

void main() {
  group("Scheduler tests", () {
    setUp(() {
      $().clear();
      print("Setup called");
    });

    tearDown(() {
      print("Tear down");
      $().clear();
    });

    test("Test one time scheduler", () async {
      OneTimeScheduledJobMock oneTime = OneTimeScheduledJobMock();
      $().schedule(oneTime).autoStart();
      await Future.delayed(Duration(seconds: 3));
      expect(oneTime.hasRun, true);
    });

    test("Test periodic scheduler", () async {
      PeriodicScheduledJobMock periodic = PeriodicScheduledJobMock();
      $().schedule(periodic).autoStart();
      await Future.delayed(Duration(seconds: 3));
      expect(periodic.runTimes >= 2, true);
    });

    test("Test exact time scheduler", () async {
      AtExactTimeScheduledJobMock atTime = AtExactTimeScheduledJobMock();
      $()
          .schedulerPollingInterval(Duration(seconds: 1))
          .schedule(atTime)
          .autoStart();
      await Future.delayed(Duration(seconds: 5));
      expect(atTime.ran, true);
    });

    test("Test exact time repeating scheduler", () async {
      AtTimePeriodicScheduledJobMock atTime = AtTimePeriodicScheduledJobMock();
      $()
          .schedulerPollingInterval(Duration(seconds: 1))
          .schedule(atTime)
          .autoStart();
      await Future.delayed(Duration(seconds: 10));
      expect(atTime.count >= 3, true);
    });
  });
}
