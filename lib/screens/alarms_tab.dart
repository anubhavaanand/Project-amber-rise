import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../models/alarm.dart';
import '../models/sleep_record.dart';
import '../services/alarm_service.dart';
import '../services/sleep_tracking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/next_alarm_card.dart';
import 'alarm_edit_screen.dart';

/// The Alarms tab.
///
/// Answers "what will wake me, and when?" - and, because the sleep data lives
/// here too, "how did last night go?" The layout is a card feed rather than a
/// plain list: each card is a self-contained summary that either expands or
/// navigates, which is the pattern the reference implementation uses for its
/// dashboard.
class AlarmsTab extends StatefulWidget {
  const AlarmsTab({super.key, required this.isar});

  final Isar isar;

  @override
  State<AlarmsTab> createState() => _AlarmsTabState();
}

class _AlarmsTabState extends State<AlarmsTab> {
  List<Alarm> _alarms = [];
  SleepRecord? _lastNight;
  bool _loading = true;
  bool _tracking = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final alarms = await widget.isar.alarms.where().sortByTime().findAll();
    final lastNight = await widget.isar.sleepRecords
        .where()
        .sortByBedTimeDesc()
        .findFirst();

    if (!mounted) return;
    setState(() {
      _alarms = alarms;
      _lastNight = lastNight;
      _tracking = SleepTrackingService.instance?.isTracking ?? false;
      _loading = false;
    });
  }

  Alarm? get _nextAlarm {
    Alarm? best;
    var bestTrigger = DateTime.now();
    var found = false;

    for (final alarm in _alarms) {
      if (!alarm.isEnabled) continue;
      final trigger = alarm.repeatDays.isEmpty
          ? alarm.time
          : AlarmService.calculateNextAlarmTime(alarm);
      if (trigger.isBefore(DateTime.now())) continue;
      if (!found || trigger.isBefore(bestTrigger)) {
        best = alarm;
        bestTrigger = trigger;
        found = true;
      }
    }
    return best;
  }

  Future<void> _toggle(Alarm alarm) async {
    await AlarmService.toggleAlarm(alarm);
    await _load();
  }

  Future<void> _edit(Alarm? alarm) async {
    final target = alarm ??
        Alarm.create(time: DateTime.now().add(const Duration(hours: 8)));
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AlarmEditScreen(isar: widget.isar, alarm: target),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final next = _nextAlarm;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          if (next != null)
            NextAlarmCard(
              alarm: next,
              onToggle: () => _toggle(next),
              onEdit: () => _edit(next),
            )
          else
            _EmptyNextAlarm(onTap: () => _edit(null)),

          const _SectionHeader('Last night'),
          _LastNightCard(record: _lastNight),

          const _SectionHeader('Tonight'),
          _TonightCard(
            tracking: _tracking,
            bedtimeHour: _bedtimeHour,
            bedtimeMinute: _bedtimeMinute,
          ),

          const _SectionHeader('Alarms'),
          if (_alarms.isEmpty)
            _NoAlarms(onTap: () => _edit(null))
          else
            ..._alarms.map(
              (alarm) => _AlarmRow(
                alarm: alarm,
                onToggle: () => _toggle(alarm),
                onEdit: () => _edit(alarm),
              ),
            ),
        ],
      ),
    );
  }

  int get _bedtimeHour {
    final hour = _lastNight?.bedTime.hour;
    return hour ?? 23;
  }

  int get _bedtimeMinute => _lastNight?.bedTime.minute ?? 0;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _LastNightCard extends StatelessWidget {
  const _LastNightCard({required this.record});

  final SleepRecord? record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (record == null) {
      return const _EmptyCard(
        icon: Icons.bedtime_outlined,
        title: 'No sleep recorded yet',
        subtitle: 'Start tracking tonight to see it here.',
      );
    }

    final total = record!.totalSleepMinutes;
    final h = total ~/ 60;
    final m = total % 60;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$h',
                  style: theme.textTheme.displaySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('h', style: theme.textTheme.titleMedium),
                ),
                const SizedBox(width: 2),
                Text(
                  '$m',
                  style: theme.textTheme.displaySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('m', style: theme.textTheme.titleMedium),
                ),
                const Spacer(),
                _QualityBadge(score: record!.sleepQuality),
              ],
            ),
            const SizedBox(height: 16),
            _PhaseBar(record: record!),
            const SizedBox(height: 12),
            Row(
              children: [
                _Legend(color: AppColors.phaseDeep, label: 'Deep'),
                const SizedBox(width: 14),
                _Legend(color: AppColors.phaseLight, label: 'Light'),
                const SizedBox(width: 14),
                _Legend(color: AppColors.phaseRem, label: 'REM'),
                const SizedBox(width: 14),
                _Legend(color: AppColors.phaseAwake, label: 'Awake'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QualityBadge extends StatelessWidget {
  const _QualityBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 80
        ? AppColors.primary
        : score >= 50
            ? AppColors.teal
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$score',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _PhaseBar extends StatelessWidget {
  const _PhaseBar({required this.record});

  final SleepRecord record;

  @override
  Widget build(BuildContext context) {
    final deep = record.deepSleepMinutes;
    final light = record.lightSleepMinutes;
    final rem = record.remSleepMinutes;
    final awake = record.awakeMinutes;
    final total = (deep + light + rem + awake).toDouble();

    if (total <= 0) {
      return Container(
        height: 12,
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            _seg(deep / total, AppColors.phaseDeep),
            _seg(light / total, AppColors.phaseLight),
            _seg(rem / total, AppColors.phaseRem),
            _seg(awake / total, AppColors.phaseAwake),
          ],
        ),
      ),
    );
  }

  Widget _seg(double fraction, Color color) => Expanded(
        flex: (fraction * 1000).round().clamp(1, 1000),
        child: Container(color: color),
      );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _TonightCard extends StatelessWidget {
  const _TonightCard({
    required this.tracking,
    required this.bedtimeHour,
    required this.bedtimeMinute,
  });

  final bool tracking;
  final int bedtimeHour;
  final int bedtimeMinute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hh = bedtimeHour.toString().padLeft(2, '0');
    final mm = bedtimeMinute.toString().padLeft(2, '0');

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(
          tracking ? Icons.sensors : Icons.sensors_off,
          color: tracking ? AppColors.teal : AppColors.onSurfaceVariant,
        ),
        title: Text(tracking ? 'Tracking tonight' : 'Not tracking'),
        subtitle: Text(
          'Suggested bedtime $hh:$mm',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.5),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        onTap: () => Navigator.of(context).pushNamed('/'),
      ),
    );
  }
}

class _AlarmRow extends StatelessWidget {
  const _AlarmRow({
    required this.alarm,
    required this.onToggle,
    required this.onEdit,
  });

  final Alarm alarm;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Text(alarm.missionType.icon, style: const TextStyle(fontSize: 20)),
        title: Row(
          children: [
            Text(
              alarm.timeString,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: alarm.isEnabled
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                alarm.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          alarm.repeatDaysString,
          style: TextStyle(fontSize: 11.5, color: AppColors.onSurfaceFaint),
        ),
        trailing: Switch(
          value: alarm.isEnabled,
          onChanged: (_) => onToggle(),
        ),
        onTap: onEdit,
      ),
    );
  }
}

class _EmptyNextAlarm extends StatelessWidget {
  const _EmptyNextAlarm({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.alarm_add, color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Text('No alarm set', style: theme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Set one and Rise will make sure you are awake for it.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoAlarms extends StatelessWidget {
  const _NoAlarms({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          'No alarms yet',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, color: AppColors.onSurfaceVariant, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14.5)),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}