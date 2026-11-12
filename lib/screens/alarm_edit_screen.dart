import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../models/alarm.dart';
import '../services/alarm_service.dart';
import '../theme/app_theme.dart';
import '../widgets/rise_button.dart';
import '../widgets/wheel_time_picker.dart';

/// Create or edit one alarm.
///
/// Information architecture follows docs/product-design.md: the six settings
/// people actually change are visible, everything else is behind "Advanced".
/// The label is editable inside the collapsing toolbar, so naming an alarm
/// never needs a dialog.
class AlarmEditScreen extends StatefulWidget {
  const AlarmEditScreen({
    super.key,
    required this.alarm,
    required this.isar,
  });

  final Alarm alarm;
  final Isar isar;

  @override
  State<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends State<AlarmEditScreen> {
  static const List<Map<String, String>> _alarmSounds = [
    {'id': 'default', 'name': 'Default'},
    {'id': 'gentle_wake', 'name': 'Gentle wake'},
    {'id': 'energetic_morning', 'name': 'Energetic morning'},
    {'id': 'nature_birds', 'name': 'Nature birds'},
    {'id': 'classic_beep', 'name': 'Classic beep'},
  ];

  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  late TextEditingController _labelController;
  late TimeOfDay _selectedTime;
  late MissionType _selectedMission;
  late int _difficulty;
  late bool _wakeUpCheck;
  late Set<int> _repeatDays;
  late String _selectedSound;
  late bool _vibrate;

  // Advanced.
  late bool _smartAlarm;
  late int _smartWindow;
  late bool _gentleWake;
  late int _gentleSeconds;
  late int _snoozeMinutes;
  late int _maxSnooze;

  bool _showAdvanced = false;
  bool _saving = false;

  bool get _isNew => widget.alarm.id == Isar.autoIncrement;

  @override
  void initState() {
    super.initState();
    final alarm = widget.alarm;
    _labelController = TextEditingController(text: alarm.label);
    _selectedTime = TimeOfDay.fromDateTime(alarm.time);
    _selectedMission = alarm.missionType;
    _difficulty = alarm.missionDifficulty;
    _wakeUpCheck = alarm.wakeUpCheckEnabled;
    _repeatDays = alarm.repeatDays.toSet();
    _selectedSound = alarm.soundPath;
    _vibrate = alarm.vibrate;

    _smartAlarm = alarm.smartAlarmEnabled;
    _smartWindow = alarm.smartAlarmWindowMinutes;
    _gentleWake = alarm.gentleWakeEnabled;
    _gentleSeconds = alarm.gentleWakeDurationSeconds;
    _snoozeMinutes = alarm.snoozeDurationMinutes;
    _maxSnooze = alarm.maxSnoozeCount;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  String get _timeLabel {
    final h = _selectedTime.hour.toString().padLeft(2, '0');
    final m = _selectedTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime() async {
    final picked = await showRiseTimePicker(
      context,
      initial: _selectedTime,
      title: 'Alarm time',
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final now = DateTime.now();
    final time = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final label = _labelController.text.trim();
    widget.alarm
      ..time = time
      ..label = label.isEmpty ? 'Alarm' : label
      ..missionType = _selectedMission
      ..missionDifficulty = _difficulty
      ..wakeUpCheckEnabled = _wakeUpCheck
      ..repeatDays = (_repeatDays.toList()..sort())
      ..soundPath = _selectedSound
      ..vibrate = _vibrate
      ..isEnabled = true
      ..smartAlarmEnabled = _smartAlarm
      ..smartAlarmWindowMinutes = _smartWindow
      ..gentleWakeEnabled = _gentleWake
      ..gentleWakeDurationSeconds = _gentleSeconds
      ..snoozeDurationMinutes = _snoozeMinutes
      ..maxSnoozeCount = _maxSnooze;

    await AlarmService.scheduleAlarm(widget.alarm);

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this alarm?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await AlarmService.deleteAlarm(widget.alarm);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 208,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            title: ValueListenableBuilder(
              valueListenable: _labelController,
              // Scoped rebuild: only this text updates per keystroke, not the
              // whole scroll view. This was the source of the typing lag.
              builder: (context, value, _) => Text(
                value.text.isEmpty ? 'Alarm' : value.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            actions: [
              if (!_isNew)
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _delete,
                ),
              IconButton(
                tooltip: 'Save',
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                onPressed: _save,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Hero time: one tap to change.
                    InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          _timeLabel,
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Editable label, inside the toolbar.
                    TextField(
                      controller: _labelController,
                      style: theme.textTheme.titleMedium,
                      decoration: const InputDecoration(
                        hintText: 'Alarm name',
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Repeat', theme),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < 7; i++)
                        _DayChip(
                          label: _weekdays[i],
                          selected: _repeatDays.contains(i),
                          onTap: () => setState(() {
                            if (_repeatDays.contains(i)) {
                              _repeatDays.remove(i);
                            } else {
                              _repeatDays.add(i);
                            }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _repeatSummary(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 28),
                  _sectionLabel('Wake-up mission', theme),
                  const SizedBox(height: 10),
                  _MissionPicker(
                    selected: _selectedMission,
                    onSelected: (m) => setState(() => _selectedMission = m),
                  ),

                  const SizedBox(height: 28),
                  _sectionLabel('Primary', theme),
                  const SizedBox(height: 8),
                  _SettingRow(
                    icon: Icons.route_outlined,
                    title: 'Difficulty',
                    subtitle: _difficultyLabel(_difficulty),
                    onTap: () => setState(
                      () => _difficulty = _difficulty >= 5 ? 1 : _difficulty + 1,
                    ),
                  ),
                  _SettingRow(
                    icon: Icons.music_note_outlined,
                    title: 'Sound',
                    subtitle: _soundName(_selectedSound),
                    onTap: _pickSound,
                  ),
                  _SettingRow(
                    icon: Icons.vibration,
                    title: 'Vibrate',
                    trailing: Switch(
                      value: _vibrate,
                      onChanged: (v) => setState(() => _vibrate = v),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _AdvancedToggle(
                    expanded: _showAdvanced,
                    onTap: () => setState(() => _showAdvanced = !_showAdvanced),
                  ),
                  // Small tier: 200ms, per docs/reference-interactions.md.
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: _buildAdvanced(theme),
                    crossFadeState: _showAdvanced
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvanced(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _SettingRow(
          icon: Icons.bedtime_outlined,
          title: 'Smart alarm',
          subtitle: 'Wake in light sleep, up to $_smartWindow min early',
          trailing: Switch(
            value: _smartAlarm,
            onChanged: (v) => setState(() => _smartAlarm = v),
          ),
        ),
        if (_smartAlarm)
          _StepperRow(
            label: 'Window',
            value: '$_smartWindow min',
            onMinus: () => setState(
              () => _smartWindow = (_smartWindow - 5).clamp(0, 120),
            ),
            onPlus: () => setState(
              () => _smartWindow = (_smartWindow + 5).clamp(0, 120),
            ),
          ),
        _SettingRow(
          icon: Icons.graphic_eq,
          title: 'Gentle volume',
          subtitle: 'Starts quiet and rises over ${_gentleSeconds}s',
          trailing: Switch(
            value: _gentleWake,
            onChanged: (v) => setState(() => _gentleWake = v),
          ),
        ),
        if (_gentleWake)
          _StepperRow(
            label: 'Ramp',
            value: '${_gentleSeconds}s',
            onMinus: () => setState(
              () => _gentleSeconds = (_gentleSeconds - 15).clamp(15, 300),
            ),
            onPlus: () => setState(
              () => _gentleSeconds = (_gentleSeconds + 15).clamp(15, 300),
            ),
          ),
        _StepperRow(
          label: 'Snooze length',
          value: '$_snoozeMinutes min',
          onMinus: () => setState(
            () => _snoozeMinutes = (_snoozeMinutes - 1).clamp(1, 30),
          ),
          onPlus: () => setState(
            () => _snoozeMinutes = (_snoozeMinutes + 1).clamp(1, 30),
          ),
        ),
        _StepperRow(
          label: 'Max snoozes',
          value: '$_maxSnooze',
          onMinus: () => setState(() => _maxSnooze = (_maxSnooze - 1).clamp(0, 10)),
          onPlus: () => setState(() => _maxSnooze = (_maxSnooze + 1).clamp(0, 10)),
        ),
        _SettingRow(
          icon: Icons.verified_user_outlined,
          title: 'Wake-up check',
          subtitle: 'Confirm you are awake after dismissing',
          trailing: Switch(
            value: _wakeUpCheck,
            onChanged: (v) => setState(() => _wakeUpCheck = v),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text, ThemeData theme) => Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.onSurfaceVariant,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w600,
        ),
      );

  String _repeatSummary() {
    if (_repeatDays.isEmpty) return 'One time';
    if (_repeatDays.length == 7) return 'Every day';
    if (_repeatDays.length == 5 &&
        !_repeatDays.contains(5) &&
        !_repeatDays.contains(6)) {
      return 'Weekdays';
    }
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sorted = _repeatDays.toList()..sort();
    return sorted.map((d) => names[d]).join(', ');
  }

  String _difficultyLabel(int d) {
    const labels = ['', 'Gentle', 'Easy', 'Normal', 'Hard', 'Brutal'];
    return labels[d.clamp(0, 5)];
  }

  String _soundName(String id) =>
      _alarmSounds.firstWhere((s) => s['id'] == id, orElse: () => _alarmSounds.first)['name']!;

  Future<void> _pickSound() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final sound in _alarmSounds)
              ListTile(
                leading: Icon(
                  _selectedSound == sound['id']
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: _selectedSound == sound['id']
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
                title: Text(sound['name']!),
                onTap: () => Navigator.pop(context, sound['id']),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _selectedSound = picked);
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.primary : AppColors.surfaceHigh,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _MissionPicker extends StatelessWidget {
  const _MissionPicker({required this.selected, required this.onSelected});

  final MissionType selected;
  final ValueChanged<MissionType> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: MissionType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final mission = MissionType.values[i];
          final isSelected = mission == selected;
          return InkWell(
            onTap: () => onSelected(mission),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 84,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isSelected ? AppColors.primaryContainer : AppColors.surface,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.outline,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(mission.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 6),
                  Text(
                    mission.displayName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.onPrimaryContainer
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.onSurfaceVariant,
              ),
            ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 44, top: 2, bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
          ),
          _StepButton(icon: Icons.remove, onTap: onMinus),
          SizedBox(
            width: 76,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          _StepButton(icon: Icons.add, onTap: onPlus),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.surfaceHigh,
        ),
        child: Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
      ),
    );
  }
}

class _AdvancedToggle extends StatelessWidget {
  const _AdvancedToggle({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Text(
              'Advanced',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}