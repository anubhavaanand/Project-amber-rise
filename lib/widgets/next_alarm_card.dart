import 'package:flutter/material.dart';

import '../models/alarm.dart';

/// The single most important surface in the app: what will wake you, and when.
///
/// One primary action (the toggle). Tapping the body opens the alarm editor.
class NextAlarmCard extends StatelessWidget {
  const NextAlarmCard({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onEdit,
  });

  final Alarm alarm;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm.isEnabled ? 'Next alarm' : 'Alarm off',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alarm.timeString,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: alarm.isEnabled
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(alarm.missionType.icon, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _subtitle(alarm),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: alarm.isEnabled,
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(Alarm alarm) {
    final parts = <String>[];
    if (alarm.label.trim().isNotEmpty && alarm.label != 'Alarm') {
      parts.add(alarm.label);
    }
    parts.add(alarm.repeatDaysString);
    if (alarm.smartAlarmEnabled && alarm.smartAlarmWindowMinutes > 0) {
      parts.add('smart ±${alarm.smartAlarmWindowMinutes}m');
    }
    return parts.join(' · ');
  }
}