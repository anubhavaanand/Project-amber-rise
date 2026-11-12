import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../services/sleep_tracking_service.dart';
import 'sleep_tracking_screen.dart';

/// The Sleep tab.
///
/// Answers "how did I sleep?" For now it is a summary that opens the full
/// tracking screen; the last-night card and hypnogram arrive with the detector
/// wiring.
class SleepTab extends StatefulWidget {
  const SleepTab({super.key, required this.isar});

  final Isar isar;

  @override
  State<SleepTab> createState() => _SleepTabState();
}

class _SleepTabState extends State<SleepTab> {
  bool _tracking = false;

  @override
  void initState() {
    super.initState();
    _tracking = SleepTrackingService.instance?.isTracking ?? false;
  }

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
                Text(_tracking ? 'Tracking tonight' : 'Not tracking',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  _tracking
                      ? 'Rise is recording movement to find your light-sleep window.'
                      : 'Start tracking so the smart alarm has something to work with.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _open(),
                  icon: const Icon(Icons.bedtime_outlined),
                  label: const Text('Open sleep tracking'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _open() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SleepTrackingScreen(isar: widget.isar, autoStart: false),
      ),
    );
    if (!mounted) return;
    setState(() {
      _tracking = SleepTrackingService.instance?.isTracking ?? false;
    });
  }
}