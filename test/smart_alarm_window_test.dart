import 'package:flutter_test/flutter_test.dart';
import 'package:rise/models/alarm.dart';
import 'package:rise/services/alarm_service.dart';

Alarm _alarm({
  required DateTime time,
  bool smart = true,
  int windowMinutes = 30,
  List<int> repeatDays = const [],
}) {
  return Alarm.create(time: time)
    ..smartAlarmEnabled = smart
    ..smartAlarmWindowMinutes = windowMinutes
    ..repeatDays = repeatDays;
}

void main() {
  group('earliestSmartFireTime', () {
    test('is the alarm time when the smart alarm is off', () {
      final time = DateTime(2026, 3, 10, 7);
      final alarm = _alarm(time: time, smart: false, windowMinutes: 30);
      expect(AlarmService.earliestSmartFireTime(alarm), time);
    });

    test('is the alarm time when the window is zero', () {
      final time = DateTime(2026, 3, 10, 7);
      final alarm = _alarm(time: time, windowMinutes: 0);
      expect(AlarmService.earliestSmartFireTime(alarm), time);
    });

    test('opens the window before the alarm', () {
      final time = DateTime(2026, 3, 10, 7);
      final alarm = _alarm(time: time, windowMinutes: 30);
      expect(
        AlarmService.earliestSmartFireTime(alarm),
        DateTime(2026, 3, 10, 6, 30),
      );
    });

    test('never fires before sleepStart + ideal sleep', () {
      final time = DateTime(2026, 3, 10, 7);
      final sleepStart = DateTime(2026, 3, 9, 23, 30);
      final alarm = _alarm(time: time, windowMinutes: 60);

      // window start 06:00, but sleepStart + 60 min is 00:30, which is earlier,
      // so the window start wins.
      expect(
        AlarmService.earliestSmartFireTime(alarm, sleepStart: sleepStart),
        DateTime(2026, 3, 10, 6),
      );
    });

    test('is clamped to the alarm time, never after it', () {
      final time = DateTime(2026, 3, 10, 7);
      // Sleep start late enough that sleepStart + ideal > alarm time.
      final sleepStart = DateTime(2026, 3, 10, 6, 50);
      final alarm = _alarm(time: time, windowMinutes: 30);

      expect(
        AlarmService.earliestSmartFireTime(alarm, sleepStart: sleepStart),
        time,
      );
    });

    test('honours a custom ideal sleep length', () {
      final time = DateTime(2026, 3, 10, 12);
      final sleepStart = DateTime(2026, 3, 10, 2);
      final alarm = _alarm(time: time, windowMinutes: 30);

      // window start 11:30; sleepStart + 8 h = 10:00, so 11:30 wins.
      expect(
        AlarmService.earliestSmartFireTime(
          alarm,
          sleepStart: sleepStart,
          idealSleepMinutes: 480,
        ),
        DateTime(2026, 3, 10, 11, 30),
      );
    });

    test('uses the next occurrence for a repeating alarm', () {
      final now = DateTime.now();
      // A time later today if possible, otherwise tomorrow.
      final target = DateTime(now.year, now.month, now.day, 23, 59);
      final alarm = _alarm(
        time: target,
        windowMinutes: 30,
        repeatDays: [0, 1, 2, 3, 4, 5, 6],
      );

      final fire = AlarmService.earliestSmartFireTime(alarm);
      final trigger = AlarmService.calculateNextAlarmTime(alarm);

      expect(fire, trigger.subtract(const Duration(minutes: 30)));
      expect(fire.isBefore(trigger), isTrue);
    });
  });
}