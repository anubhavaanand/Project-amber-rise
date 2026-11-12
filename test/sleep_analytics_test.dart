import 'package:flutter_test/flutter_test.dart';
import 'package:rise/models/sleep_record.dart';
import 'package:rise/services/sleep_analytics.dart';

/// Builds a record from wall-clock times, so the test reads like the scenario.
SleepRecord _record({
  required int bedHour,
  required int bedMinute,
  required int wakeHour,
  required int wakeMinute,
  int quality = 80,
}) {
  final now = DateTime(2026, 3, 10);
  final bed = DateTime(2026, 3, 10, bedHour, bedMinute);
  var wake = DateTime(2026, 3, 10, wakeHour, wakeMinute);
  // A wake time earlier than the bed time means the sleep crossed midnight.
  if (wake.isBefore(bed)) wake = wake.add(const Duration(days: 1));

  return SleepRecord.create(
    bedTime: bed,
    wakeTime: wake,
    sleepQuality: quality,
  )..notes = 'test';
}

void main() {
  group('sleep debt', () {
    test('counts only nights below the goal', () {
      final records = [
        _record(bedHour: 23, bedMinute: 0, wakeHour: 7, wakeMinute: 0), // 8h
        _record(bedHour: 23, bedMinute: 0, wakeHour: 5, wakeMinute: 0), // 6h
      ];
      // Goal 8h: the first night is at goal, the second is 2 h short.
      expect(SleepAnalytics.sleepDebtMinutes(records), 120);
    });

    test('a surplus night does not cancel debt', () {
      final records = [
        _record(bedHour: 23, bedMinute: 0, wakeHour: 5, wakeMinute: 0), // 6h
        _record(bedHour: 21, bedMinute: 0, wakeHour: 8, wakeMinute: 0), // 11h
      ];
      // Debt stays 2 h; the 3 h surplus is not banked against it.
      expect(SleepAnalytics.sleepDebtMinutes(records), 120);
    });

    test('is zero when every night meets the goal', () {
      final records = [
        _record(bedHour: 23, bedMinute: 0, wakeHour: 7, wakeMinute: 0),
        _record(bedHour: 23, bedMinute: 30, wakeHour: 7, wakeMinute: 30),
      ];
      expect(SleepAnalytics.sleepDebtMinutes(records), 0);
    });

    test('empty history has no debt', () {
      expect(SleepAnalytics.sleepDebtMinutes([]), 0);
      expect(SleepAnalytics.sleepDebtHours([]), 0);
    });

    test('reports hours rounded to one decimal', () {
      final records = [
        _record(bedHour: 23, bedMinute: 0, wakeHour: 5, wakeMinute: 30), // 6.5h
      ];
      expect(SleepAnalytics.sleepDebtHours(records), 1.5);
    });

    test('average nightly deficit is negative on surplus', () {
      final records = [
        _record(bedHour: 22, bedMinute: 0, wakeHour: 7, wakeMinute: 0), // 9h
      ];
      expect(SleepAnalytics.averageNightlyDeficitMinutes(records), -60);
    });
  });

  group('chronotype', () {
    test('midpoint of a 23:00-07:00 sleep is 03:00', () {
      final r = _record(bedHour: 23, bedMinute: 0, wakeHour: 7, wakeMinute: 0);
      expect(SleepAnalytics.sleepMidpointMinutes(r), 3 * 60);
    });

    test('midpoint rolls over midnight correctly', () {
      final r = _record(bedHour: 23, bedMinute: 50, wakeHour: 0, wakeMinute: 10);
      expect(SleepAnalytics.sleepMidpointMinutes(r), 0);
    });

    test('early midpoints are a morning type', () {
      final records = [
        for (var i = 0; i < 5; i++)
          _record(bedHour: 21, bedMinute: 30, wakeHour: 5, wakeMinute: 30),
      ];
      // Midpoint 01:30.
      expect(SleepAnalytics.chronotype(records), Chronotype.morning);
      expect(SleepAnalytics.averageMidpointLabel(records), '01:30');
    });

    test('late midpoints are an evening type', () {
      final records = [
        for (var i = 0; i < 5; i++)
          _record(bedHour: 2, bedMinute: 0, wakeHour: 10, wakeMinute: 0),
      ];
      // Midpoint 06:00.
      expect(SleepAnalytics.chronotype(records), Chronotype.evening);
    });

    test('mid-range midpoints are intermediate', () {
      final records = [
        for (var i = 0; i < 5; i++)
          _record(bedHour: 23, bedMinute: 0, wakeHour: 7, wakeMinute: 0),
      ];
      expect(SleepAnalytics.chronotype(records), Chronotype.intermediate);
    });

    test('averaging across midnight does not average to noon', () {
      // 23:50 and 00:10 average to midnight, not to 11:00.
      final records = [
        _record(bedHour: 23, bedMinute: 10, wakeHour: 7, wakeMinute: 10),
        _record(bedHour: 23, bedMinute: 50, wakeHour: 7, wakeMinute: 50),
        _record(bedHour: 0, bedMinute: 10, wakeHour: 8, wakeMinute: 10),
      ];
      final mean = SleepAnalytics.averageMidpointMinutes(records);
      // Midpoints are ~03:10, ~03:50, ~04:10 - all in the early hours.
      expect(mean, greaterThan(0));
      expect(mean, lessThan(6 * 60));
    });

    test('unknown with no records', () {
      expect(SleepAnalytics.chronotype([]), Chronotype.unknown);
      expect(SleepAnalytics.averageMidpointMinutes([]), -1);
      expect(SleepAnalytics.averageMidpointLabel([]), '--:--');
    });

    test('advice is always non-empty', () {
      for (final c in Chronotype.values) {
        expect(c.advice, isNotEmpty);
        expect(c.label, isNotEmpty);
      }
    });
  });

  group('social jetlag', () {
    // 2026-03-09 is a Monday ... 2026-03-15 a Sunday.
    SleepRecord _on(DateTime bed) {
      final wake = bed.add(const Duration(hours: 8));
      return SleepRecord.create(bedTime: bed, wakeTime: wake);
    }

    test('is zero when weekday and weekend midpoints match', () {
      final records = [
        _on(DateTime(2026, 3, 9, 23)), // Mon
        _on(DateTime(2026, 3, 10, 23)), // Tue
        _on(DateTime(2026, 3, 14, 23)), // Sat
        _on(DateTime(2026, 3, 15, 23)), // Sun
      ];
      expect(SleepAnalytics.socialJetlagMinutes(records), 0);
    });

    test('measures the weekend lie-in', () {
      final records = [
        _on(DateTime(2026, 3, 9, 23)), // Mon 23:00 -> mid 03:00
        _on(DateTime(2026, 3, 10, 23)), // Tue 23:00 -> mid 03:00
        _on(DateTime(2026, 3, 14, 1)), // Sat 01:00 -> mid 05:00
        _on(DateTime(2026, 3, 15, 1)), // Sun 01:00 -> mid 05:00
      ];
      expect(SleepAnalytics.socialJetlagMinutes(records), 120);
      expect(SleepAnalytics.socialJetlagLabel(records), '2h 0m');
    });

    test('unknown when one group is empty', () {
      final records = [_on(DateTime(2026, 3, 9, 23))]; // Monday only
      expect(SleepAnalytics.socialJetlagMinutes(records), -1);
      expect(SleepAnalytics.socialJetlagLabel(records), '--');
    });

    test('honours a custom rest-day set', () {
      final records = [
        _on(DateTime(2026, 3, 9, 23)), // Mon
        _on(DateTime(2026, 3, 10, 23)), // Tue
      ];
      // Treat Monday as a rest day: one rest, one work, so jetlag is defined.
      final monday = SleepAnalytics.socialJetlagMinutes(
        records,
        restDays: const {1},
      );
      expect(monday, greaterThanOrEqualTo(0));
    });

    test('empty history is unknown', () {
      expect(SleepAnalytics.socialJetlagMinutes([]), -1);
    });
  });
}