import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../models/sleep_record.dart';
import '../services/sleep_tracking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hypnogram.dart';
import 'sleep_tracking_screen.dart';

/// The Sleep tab.
///
/// Answers "how did I sleep?" - last night's hypnogram first, then the numbers
/// that explain it.
class SleepTab extends StatefulWidget {
  const SleepTab({super.key, required this.isar});

  final Isar isar;

  @override
  State<SleepTab> createState() => _SleepTabState();
}

class _SleepTabState extends State<SleepTab> {
  SleepRecord? _lastNight;
  bool _tracking = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final record = await widget.isar.sleepRecords
        .where()
        .sortByBedTimeDesc()
        .findFirst();
    if (!mounted) return;
    setState(() {
      _lastNight = record;
      _tracking = SleepTrackingService.instance?.isTracking ?? false;
      _loading = false;
    });
  }

  Future<void> _openTracking() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SleepTrackingScreen(isar: widget.isar, autoStart: false),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final record = _lastNight;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          _TonightCard(tracking: _tracking, onOpen: _openTracking),
          const _SectionHeader('Last night'),
          if (record == null)
            const _EmptyCard(
              icon: Icons.bedtime_outlined,
              title: 'No sleep recorded yet',
              subtitle: 'Start tracking tonight to see your night here.',
            )
          else ...[
            _HypnogramCard(record: record),
            const SizedBox(height: 10),
            _PhaseBreakdown(record: record),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
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

class _TonightCard extends StatelessWidget {
  const _TonightCard({required this.tracking, required this.onOpen});

  final bool tracking;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Icon(
          tracking ? Icons.sensors : Icons.sensors_off,
          color: tracking ? AppColors.teal : AppColors.onSurfaceVariant,
        ),
        title: Text(tracking ? 'Tracking tonight' : 'Not tracking'),
        subtitle: Text(
          tracking
              ? 'Rise is sampling movement to time the smart alarm.'
              : 'Start tracking so the smart alarm has something to work with.',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.5),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        onTap: onOpen,
      ),
    );
  }
}

class _HypnogramCard extends StatelessWidget {
  const _HypnogramCard({required this.record});

  final SleepRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = record.totalSleepMinutes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${total ~/ 60}h ${total % 60}m',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 10),
                Text(
                  _timeRange(),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Hypnogram(movement: record.movementData),
            const SizedBox(height: 10),
            Row(
              children: [
                _Legend(color: AppColors.phaseAwake, label: 'Awake'),
                const SizedBox(width: 14),
                _Legend(color: AppColors.phaseRem, label: 'REM'),
                const SizedBox(width: 14),
                _Legend(color: AppColors.phaseLight, label: 'Light'),
                const SizedBox(width: 14),
                _Legend(color: AppColors.phaseDeep, label: 'Deep'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeRange() {
    String f(DateTime d) =>
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '${f(record.bedTime)} – ${f(record.wakeTime)}';
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
        ],
      );
}

class _PhaseBreakdown extends StatelessWidget {
  const _PhaseBreakdown({required this.record});

  final SleepRecord record;

  @override
  Widget build(BuildContext context) {
    final rows = <List<dynamic>>[
      ['Deep', record.deepSleepMinutes, AppColors.phaseDeep],
      ['Light', record.lightSleepMinutes, AppColors.phaseLight],
      ['REM', record.remSleepMinutes, AppColors.phaseRem],
      ['Awake', record.awakeMinutes, AppColors.phaseAwake],
    ];

    final total = record.deepSleepMinutes +
        record.lightSleepMinutes +
        record.remSleepMinutes +
        record.awakeMinutes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: row[2] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(row[0] as String, style: const TextStyle(fontSize: 13.5)),
                    ),
                    Text(
                      _fmt(row[1] as int),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 42,
                      child: Text(
                        total > 0
                            ? '${((row[1] as int) * 100 / total).round()}%'
                            : '–',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.speed, size: 15, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text('Efficiency',
                      style: TextStyle(
                          fontSize: 12.5, color: AppColors.onSurfaceVariant)),
                  const Spacer(),
                  Text(
                    '${(record.sleepEfficiency * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(int minutes) {
    if (minutes < 60) return '${minutes}m';
    return '${minutes ~/ 60}h ${minutes % 60}m';
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
  Widget build(BuildContext context) => Card(
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
                          fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}