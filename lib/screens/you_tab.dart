import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import 'stats_screen.dart';

/// The You tab.
///
/// Answers "how am I doing over time?" For now it is an entry point to the
/// stats screen; the score card and streaks arrive once there is history to
/// show.
class YouTab extends StatelessWidget {
  const YouTab({super.key, required this.isar});

  final Isar isar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        Card(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your sleep', style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Score, duration, debt and regularity, once there is history.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StatsScreen(isar: isar),
                    ),
                  ),
                  icon: const Icon(Icons.insights_outlined),
                  label: const Text('Open stats'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}