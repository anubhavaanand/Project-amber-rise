import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/persona_preset.dart';
import '../services/notification_service.dart';
import '../services/preset_service.dart';
import '../services/sleep_tracking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/rise_button.dart';
import '../widgets/wheel_time_picker.dart';

/// Settings.
///
/// Grouped by the question the user is asking, not by the app's internals, and
/// searchable - with hundreds of settings in the reference implementation,
/// search is the difference between "feature-heavy" and "unusable".
///
/// Every row here writes to a store that something actually reads. Rows that
/// would only set a local variable are deliberately absent.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.isar});

  final dynamic isar;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _query = '';

  PersonaPreset? _preset;
  Friction _friction = Friction.normal;

  bool _autoTracking = false;
  bool _bedtimeReminder = false;
  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 0);

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final preset = await PresetService.activePreset();
    final friction = await PresetService.friction();
    final service = SleepTrackingService.instance;

    if (!mounted) return;
    setState(() {
      _preset = preset;
      _friction = friction;
      _autoTracking = service?.autoSleepTrackingEnabled ?? false;
      _bedtimeReminder = service?.bedtimeReminderEnabled ?? false;
      _bedtime = service?.bedtime ?? const TimeOfDay(hour: 22, minute: 0);
      _loading = false;
    });
  }

  Future<void> _setAutoTracking(bool value) async {
    await SleepTrackingService.instance?.saveSettings(autoSleepTracking: value);
    if (mounted) setState(() => _autoTracking = value);
  }

  Future<void> _setBedtimeReminder(bool value) async {
    await SleepTrackingService.instance
        ?.saveSettings(bedtimeReminder: value);
    if (value) {
      await NotificationService.scheduleBedtimeReminder(_bedtime);
    } else {
      await NotificationService.cancelBedtimeReminder();
    }
    if (mounted) setState(() => _bedtimeReminder = value);
  }

  Future<void> _pickBedtime() async {
    final picked = await showRiseTimePicker(
      context,
      initial: _bedtime,
      title: 'Bedtime',
    );
    if (picked == null) return;
    await SleepTrackingService.instance?.saveSettings(bedtime: picked);
    if (_bedtimeReminder) {
      await NotificationService.scheduleBedtimeReminder(picked);
    }
    if (mounted) setState(() => _bedtime = picked);
  }

  Future<void> _setFriction(Friction friction) async {
    await PresetService.setFriction(friction);
    if (mounted) setState(() => _friction = friction);
  }

  Future<void> _pickPreset() async {
    final selected = await showModalBottomSheet<PersonaPreset>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Persona',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            for (final p in presets)
              ListTile(
                leading: Text(p.icon, style: const TextStyle(fontSize: 20)),
                title: Text(p.displayName),
                subtitle: Text(p.tagline),
                trailing: _preset?.id == p.id
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, p),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (selected == null) return;
    // Selecting a persona re-applies its defaults, which is a deliberate,
    // confirmed action - the same rule as onboarding.
    await PresetService.applyPreset(selected);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final groups = _visibleGroups();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          _SearchField(
            value: _query,
            onChanged: (v) => setState(() => _query = v),
          ),
          for (final group in groups) ...[
            _GroupHeader(group.title),
            Card(
              child: Column(children: group.rows),
            ),
          ],
          if (groups.isEmpty) const _NoResults(query: ''),
        ],
      ),
    );
  }

  List<_Group> _visibleGroups() {
    final q = _query.trim().toLowerCase();

    bool matches(String label, String keywords) {
      if (q.isEmpty) return true;
      return label.toLowerCase().contains(q) ||
          keywords.toLowerCase().contains(q);
    }

    final groups = <_Group>[];

    final personaRows = <Widget>[
      _NavRow(
        icon: Icons.person_outline,
        label: 'Persona',
        value: _preset?.displayName ?? 'None',
        onTap: _pickPreset,
        keywords: 'persona preset student worker sleeper shift biohacker',
      ),
      _FrictionRow(
        value: _friction,
        onChanged: _setFriction,
        keywords: 'friction adhd difficulty morning effort',
      ),
    ].where((row) => row is _NavRow
        ? matches((row).label, (row).keywords)
        : matches('Morning friction', 'friction adhd difficulty morning effort')).toList();

    if (personaRows.isNotEmpty) {
      groups.add(_Group('Persona', personaRows));
    }

    final sleepRows = <Widget>[
      _SwitchRow(
        icon: Icons.sensors,
        label: 'Automatic sleep tracking',
        subtitle: 'Start tracking when you go to bed',
        value: _autoTracking,
        onChanged: _setAutoTracking,
      ),
      _SwitchRow(
        icon: Icons.notifications_none,
        label: 'Bedtime reminder',
        subtitle: 'A nudge when it is time for bed',
        value: _bedtimeReminder,
        onChanged: _setBedtimeReminder,
      ),
      _NavRow(
        icon: Icons.bedtime_outlined,
        label: 'Bedtime',
        value: _fmtTime(_bedtime),
        onTap: _pickBedtime,
        keywords: 'bedtime sleep time night',
      ),
    ].where((row) {
      if (row is _SwitchRow) {
        return matches(row.label, '${row.label} ${row.subtitle}');
      }
      final nav = row as _NavRow;
      return matches(nav.label, nav.keywords);
    }).toList();

    if (sleepRows.isNotEmpty) {
      groups.add(_Group('Sleep tracking', sleepRows));
    }

    return groups;
  }

  static String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _Group {
  const _Group(this.title, this.rows);
  final String title;
  final List<Widget> rows;
}

class _SearchField extends StatefulWidget {
  const _SearchField({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: const InputDecoration(
          hintText: 'Search settings',
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
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

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.keywords = '',
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final String keywords;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
      title: Text(label, style: const TextStyle(fontSize: 14.5)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceFaint),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
      title: Text(label, style: const TextStyle(fontSize: 14.5)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class _FrictionRow extends StatelessWidget {
  const _FrictionRow({
    required this.value,
    required this.onChanged,
    this.keywords = '',
  });

  final Friction value;
  final ValueChanged<Friction> onChanged;
  final String keywords;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Morning friction',
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'How much effort it takes to dismiss the alarm. Independent of your persona.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<Friction>(
              segments: const [
                ButtonSegment(value: Friction.low, label: Text('Low')),
                ButtonSegment(value: Friction.normal, label: Text('Normal')),
                ButtonSegment(value: Friction.high, label: Text('High')),
              ],
              selected: {value},
              showSelectedIcon: false,
              onSelectionChanged: (s) => onChanged(s.first),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Text(
          'Nothing matches "$query"',
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
        ),
      ),
    );
  }
}