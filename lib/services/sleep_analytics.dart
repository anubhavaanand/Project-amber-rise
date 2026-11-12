import 'dart:math' as math;

import '../models/sleep_record.dart';

/// Sleep debt, chronotype and social jetlag.
///
/// All three are pure functions over a list of [SleepRecord]s - no database, no
/// clock, no side effects - so they can be unit tested against fixed data.
///
/// Definitions follow the standard sleep-science usage:
///
/// * **Sleep debt** - the running total of sleep missed against a goal. Only
///   nights *below* goal count; surplus does not cancel debt (that is the
///   "debt" part - you cannot bank sleep).
/// * **Chronotype** - where a person's sleep sits in the day, measured by the
///   *midpoint* of each sleep (halfway between falling asleep and waking).
///   Early midpoint = morning type, late = evening type.
/// * **Social jetlag** - the gap between the sleep midpoint on free days and
///   on work days. It measures how much a schedule fights the body clock.
class SleepAnalytics {
  const SleepAnalytics._();

  // ── Sleep debt ────────────────────────────────────────────────────────────

  /// Total minutes of sleep missed against [goalMinutes] across [records].
  ///
  /// Only nights shorter than the goal contribute. Nights at or above the goal
  /// add nothing and do not offset earlier debt.
  static int sleepDebtMinutes(
    List<SleepRecord> records, {
    int goalMinutes = 480,
  }) {
    var debt = 0;
    for (final r in records) {
      final deficit = goalMinutes - r.totalSleepMinutes;
      if (deficit > 0) debt += deficit;
    }
    return debt;
  }

  /// The same figure in hours, rounded to one decimal.
  static double sleepDebtHours(
    List<SleepRecord> records, {
    int goalMinutes = 480,
  }) {
    return (sleepDebtMinutes(records, goalMinutes: goalMinutes) / 60.0 * 10)
            .round() /
        10;
  }

  /// The average nightly debt across [records] - how far off target a typical
  /// night is. Negative means an average surplus.
  static double averageNightlyDeficitMinutes(
    List<SleepRecord> records, {
    int goalMinutes = 480,
  }) {
    if (records.isEmpty) return 0;
    var total = 0;
    for (final r in records) {
      total += goalMinutes - r.totalSleepMinutes;
    }
    return total / records.length;
  }

  // ── Chronotype ────────────────────────────────────────────────────────────

  /// The sleep midpoint of one record, in minutes since midnight of the day
  /// the sleep *started*.
  ///
  /// A sleep from 23:00 to 07:00 has a midpoint of 03:00, returned as 180.
  /// Times past midnight roll over, so the value is always in 0..1439.
  static int sleepMidpointMinutes(SleepRecord record) {
    final start = record.bedTime;
    final mid = start.add(
      Duration(milliseconds: record.wakeTime.difference(start).inMilliseconds ~/ 2),
    );
    return mid.hour * 60 + mid.minute;
  }

  /// The mean sleep midpoint across [records], in minutes since midnight.
  ///
  /// Uses circular statistics: 23:50 and 00:10 average to midnight, not noon.
  /// Returns -1 when there is nothing to average.
  static double averageMidpointMinutes(List<SleepRecord> records) {
    if (records.isEmpty) return -1;

    var sinSum = 0.0;
    var cosSum = 0.0;
    for (final r in records) {
      final angle = sleepMidpointMinutes(r) / 1440.0 * 2 * math.pi;
      sinSum += math.sin(angle);
      cosSum += math.cos(angle);
    }

    final mean = math.atan2(sinSum / records.length, cosSum / records.length);
    if (mean < 0) return -1;

    final degrees = mean * 180 / math.pi;
    return ((degrees / 360.0) * 1440 + 1440) % 1440;
  }

  /// Classifies [records] into a chronotype from the mean sleep midpoint.
  ///
  /// Thresholds are the conventional cut-offs used in the literature:
  /// before 03:00 = morning type, 03:00-04:30 = intermediate,
  /// after 04:30 = evening type.
  static Chronotype chronotype(List<SleepRecord> records) {
    final mean = averageMidpointMinutes(records);
    if (mean < 0) return Chronotype.unknown;
    if (mean < 3 * 60) return Chronotype.morning;
    if (mean < 4 * 60 + 30) return Chronotype.intermediate;
    return Chronotype.evening;
  }

  /// The mean sleep midpoint formatted as HH:MM, or '--:--' when unknown.
  static String averageMidpointLabel(List<SleepRecord> records) {
    final mean = averageMidpointMinutes(records);
    if (mean < 0) return '--:--';
    final m = mean.round() % 1440;
    final h = (m ~/ 60).toString().padLeft(2, '0');
    final mm = (m % 60).toString().padLeft(2, '0');
    return '$h:$mm';
  }

  // ── Social jetlag ─────────────────────────────────────────────────────────

  /// Social jetlag in minutes: the gap between the sleep midpoint on rest
  /// days and on work days.
  ///
  /// [restDays] are ISO weekdays (6 = Saturday, 7 = Sunday by default).
  /// Returns -1 when either group is empty.
  static int socialJetlagMinutes(
    List<SleepRecord> records, {
    Set<int> restDays = const {6, 7},
  }) {
    final rest = <SleepRecord>[];
    final work = <SleepRecord>[];

    for (final r in records) {
      // ISO weekday: Monday = 1 ... Sunday = 7.
      final iso = r.bedTime.weekday;
      if (restDays.contains(iso)) {
        rest.add(r);
      } else {
        work.add(r);
      }
    }

    if (rest.isEmpty || work.isEmpty) return -1;

    final restMean = averageMidpointMinutes(rest);
    final workMean = averageMidpointMinutes(work);
    if (restMean < 0 || workMean < 0) return -1;

    var diff = (restMean - workMean).abs();
    // Midpoints are circular: 23:50 vs 00:10 is 20 minutes, not 23h40m.
    if (diff > 720) diff = 1440 - diff;
    return diff.round();
  }

  /// Social jetlag in minutes and hours, for display.
  static String socialJetlagLabel(
    List<SleepRecord> records, {
    Set<int> restDays = const {6, 7},
  }) {
    final mins = socialJetlagMinutes(records, restDays: restDays);
    if (mins < 0) return '--';
    if (mins < 60) return '${mins}m';
    return '${mins ~/ 60}h ${mins % 60}m';
  }
}

/// A person's preferred sleep timing.
enum Chronotype {
  unknown,
  morning,
  intermediate,
  evening;

  String get label {
    switch (this) {
      case Chronotype.unknown:
        return 'Unknown';
      case Chronotype.morning:
        return 'Morning type';
      case Chronotype.intermediate:
        return 'Intermediate';
      case Chronotype.evening:
        return 'Evening type';
    }
  }

  String get advice {
    switch (this) {
      case Chronotype.unknown:
        return 'Track a few more nights to work this out.';
      case Chronotype.morning:
        return 'You peak early. Guard your evenings - late nights cost you more than most.';
      case Chronotype.intermediate:
        return 'Your body clock is flexible. Consistency matters more than timing.';
      case Chronotype.evening:
        return 'You peak late. Shift work and early alarms are fighting your clock.';
    }
  }
}