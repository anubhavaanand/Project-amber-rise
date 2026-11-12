import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sleep_record.dart';
import '../theme/app_theme.dart';
import 'stats_screen.dart';

/// The You tab.
///
/// Answers "how am I doing over time?" - the score, the streak, and the
/// averages, computed from the sleep records that actually exist.
///
/// Note: alarm-side statistics (snoozes, wake delay, mission time) are not
/// shown because nothing in the app writes them yet - see the note at the
/// bottom of this file.
class YouTab extends StatefulWidget {
  const YouTab({super.key, required this.isar});

  final Isar isar;

  @override
  State<YouTab> createState() => _YouTabState();
}

class _YouTabState extends State<YouTab> {
  List<SleepRecord> _records = [];
  double _goalHours = 8.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await widget.isar.sleepRecords
        .where()
        .sortByBedTimeDesc()
        .findAll();
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _records = records;
      _goalHours = prefs.getDouble('sleep_goal_hours') ?? 8.0;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final stats = _Stats.from(_records, _goalHours);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          _ScoreCard(stats: stats),
          const _SectionHeader('Streak'),
          _StreakCard(stats: stats),
          const _SectionHeader('Averages'),
          _AveragesCard(stats: stats),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => StatsScreen(isar: widget.isar)),
            ),
            icon: const Icon(Icons.insights_outlined, size: 18),
            label: const Text('Open full stats'),
          ),
        ],
      ),
    );
  }
}

/// Everything the tab shows, computed once from the record list.
class _Stats {
  _Stats({
    required this.nights,
    required this.avgQuality,
    required this.avgMinutes,
    required this.bestMinutes,
    required this.streak,
    required this.bestStreak,
    required this.avgDeep,
    required this.avgRem,
    required this.lastNight,
  });

  final int nights;
  final double avgQuality;
  final double avgMinutes;
  final int bestMinutes;
  final int streak;
  final int bestStreak;
  final double avgDeep;
  final double avgRem;
  final SleepRecord? lastNight;

  factory _Stats.from(List<SleepRecord> records, double goalHours) {
    if (records.isEmpty) {
      return _Stats(
        nights: 0,
        avgQuality: 0,
        avgMinutes: 0,
        bestMinutes: 0,
        streak: 0,
        bestStreak: 0,
        avgDeep: 0,
        avgRem: 0,
        lastNight: null,
      );
    }

    final goalMinutes = goalHours * 60;

    var qualitySum = 0.0;
    var minutesSum = 0.0;
    var deepSum = 0.0;
    var remSum = 0.0;
    var best = 0;

    for (final r in records) {
      qualitySum += r.sleepQuality;
      final m = r.totalSleepMinutes;
      minutesSum += m;
      deepSum += r.deepSleepMinutes;
      remSum += r.remSleepMinutes;
      if (m > best) best = m;
    }

    // Streak: consecutive nights (walking back from the newest) that met the goal.
    var streak = 0;
    for (final r in records) {
      if (r.totalSleepMinutes >= goalMinutes) {
        streak++;
      } else {
        break;
      }
    }

    // Best streak across the whole history.
    var bestStreak = 0;
    var run = 0;
    for (final r in records) {
      if (r.totalSleepMinutes >= goalMinutes) {
        run++;
        if (run > bestStreak) bestStreak = run;
      } else {
        run = 0;
      }
    }

    final n = records.length;

    return _Stats(
      nights: n,
      avgQuality: qualitySum / n,
      avgMinutes: minutesSum / n,
      bestMinutes: best,
      streak: streak,
      bestStreak: bestStreak,
      avgDeep: deepSum / n,
      avgRem: remSum / n,
      lastNight: records.first,
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

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.stats});

  final _Stats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (stats.nights == 0) {
      return const _EmptyCard(
        icon: Icons.insights_outlined,
        title: 'Nothing to score yet',
        subtitle: 'Track a few nights and your score appears here.',
      );
    }

    final score = stats.avgQuality.round();
    final color = score >= 80
        ? AppColors.primary
        : score >= 50
            ? AppColors.teal
            : AppColors.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            _Ring(score: score, color: color),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sleep score', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    _verdict(score),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${stats.nights} night${stats.nights == 1 ? '' : 's'} tracked',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.onSurfaceFaint,
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

  static String _verdict(int score) {
    if (score >= 85) return 'Excellent. Your body is getting what it needs.';
    if (score >= 70) return 'Good. A little more consistency would help.';
    if (score >= 50) return 'Fair. Your sleep is irregular.';
    return 'Poor. Worth looking at your bedtime.';
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: CustomPaint(
        painter: _RingPainter(score: score, color: color),
        child: Center(
          child: Text(
            '$score',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 7.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    final track = Paint()
      ..color = AppColors.surfaceHigh
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 6.28318, false, track);

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -1.5708, 6.28318 * (score / 100), false, fill);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.score != score || old.color != color;
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.stats});

  final _Stats stats;

  @override
  Widget build(BuildContext context) {
    if (stats.nights == 0) {
      return const _EmptyCard(
        icon: Icons.local_fire_department_outlined,
        title: 'No streak yet',
        subtitle: 'A streak starts the first night you hit your goal.',
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            _Stat(
              value: '${stats.streak}',
              label: 'Current',
              color: stats.streak > 0 ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const _Divider(),
            _Stat(value: '${stats.bestStreak}', label: 'Best'),
            const _Divider(),
            _Stat(
              value: '${stats.avgMinutes ~/ 60}h ${stats.avgMinutes % 60}m',
              label: 'Average',
            ),
          ],
        ),
      ),
    );
  }
}

class _AveragesCard extends StatelessWidget {
  const _AveragesCard({required this.stats});

  final _Stats stats;

  @override
  Widget build(BuildContext context) {
    if (stats.nights == 0) {
      return const _EmptyCard(
        icon: Icons.bar_chart_outlined,
        title: 'No averages yet',
        subtitle: 'These fill in as you track more nights.',
      );
    }

    final deepPct = stats.avgMinutes > 0 ? stats.avgDeep / stats.avgMinutes : 0;
    final remPct = stats.avgMinutes > 0 ? stats.avgRem / stats.avgMinutes : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            _Row(label: 'Best night', value: _fmt(stats.bestMinutes)),
            _Row(label: 'Average deep', value: '${(deepPct * 100).round()}%'),
            _Row(label: 'Average REM', value: '${(remPct * 100).round()}%'),
            _Row(
              label: 'Last night',
              value: stats.lastNight == null
                  ? '–'
                  : _fmt(stats.lastNight!.totalSleepMinutes),
              last: true,
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(int minutes) =>
      minutes < 60 ? '${minutes}m' : '${minutes ~/ 60}h ${minutes % 60}m';
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.color});

  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color ?? AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 34,
        color: AppColors.outline,
      );
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: last
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.outline)),
            ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13.5)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
        ],
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