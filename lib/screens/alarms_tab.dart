import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../models/alarm.dart';
import '../services/alarm_service.dart';
import '../widgets/next_alarm_card.dart';
import 'alarm_edit_screen.dart';

/// The Alarms tab.
///
/// Answers one question: "what will wake me, and when?" The next alarm is the
/// hero; the full list is secondary and collapsed to one line per alarm.
class AlarmsTab extends StatefulWidget {
  const AlarmsTab({super.key, required this.isar});

  final Isar isar;

  @override
  State<AlarmsTab> createState() => _AlarmsTabState();
}

class _AlarmsTabState extends State<AlarmsTab> {
  List<Alarm> _alarms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final alarms = await widget.isar.alarms.where().sortByTime().findAll();
    if (!mounted) return;
    setState(() {
      _alarms = alarms;
      _loading = false;
    });
  }

  Alarm? get _nextAlarm {
    Alarm? best;
    for (final alarm in _alarms) {
      if (!alarm.isEnabled) continue;
      final trigger = alarm.repeatDays.isEmpty
          ? alarm.time
          : AlarmService.calculateNextAlarmTime(alarm);
      if (trigger.isBefore(DateTime.now())) continue;
      if (best == null) {
        best = alarm;
        continue;
      }
      final bestTrigger = best.repeatDays.isEmpty
          ? best.time
          : AlarmService.calculateNextAlarmTime(best);
      if (trigger.isBefore(bestTrigger)) best = alarm;
    }
    return best;
  }

  Future<void> _toggle(Alarm alarm) async {
    await AlarmService.toggleAlarm(alarm);
    await _load();
  }

  Future<void> _edit(Alarm? alarm) async {
    final target = alarm ?? Alarm.create(time: _defaultNewAlarmTime());
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AlarmEditScreen(isar: widget.isar, alarm: target),
      ),
    );
    await _load();
  }

  /// A sensible default for a new alarm: the next occurrence of 07:00.
  DateTime _defaultNewAlarmTime() {
    final now = DateTime.now();
    final candidate = DateTime(now.year, now.month, now.day, 7);
    return candidate.isAfter(now)
        ? candidate
        : candidate.add(const Duration(days: 1));
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
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          if (next != null)
            NextAlarmCard(
              alarm: next,
              onToggle: () => _toggle(next),
              onEdit: () => _edit(next),
            )
          else
            const _EmptyNextAlarm(),

          if (_alarms.length > 1 || (next == null && _alarms.isNotEmpty)) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text('All alarms'),
            ),
            ..._alarms.map(
              (alarm) => ListTile(
                leading: Text(alarm.missionType.icon),
                title: Text('${alarm.timeString}  ${alarm.label}'),
                subtitle: Text(alarm.repeatDaysString),
                trailing: Switch(
                  value: alarm.isEnabled,
                  onChanged: (_) => _toggle(alarm),
                ),
                onTap: () => _edit(alarm),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyNextAlarm extends StatelessWidget {
  const _EmptyNextAlarm();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No alarm set', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Set one and Rise will make sure you are awake for it.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}