import 'package:flutter/material.dart';

import '../models/persona_preset.dart';
import '../services/preset_service.dart';

/// First-run onboarding.
///
/// Two questions only: who are you, and how much friction do you want in the
/// morning. The second step shows exactly what will change before anything is
/// written, so applying a preset is always a deliberate act.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  /// Called after the preset has been applied and the user confirms.
  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  PersonaPreset? _selected;
  Friction _friction = Friction.normal;
  bool _saving = false;

  void _next() {
    if (_selected == null) return;
    setState(() {
      _selected = _selected;
      _friction = _selected!.friction;
      _step = 1;
    });
  }

  Future<void> _apply() async {
    final preset = _selected;
    if (preset == null) return;

    setState(() => _saving = true);
    await PresetService.applyPreset(preset);
    await PresetService.setFriction(_friction);
    if (!mounted) return;
    setState(() => _saving = false);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rise'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _step == 0 ? _buildPersonaStep() : _buildReviewStep(),
      ),
    );
  }

  Widget _buildPersonaStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text('How do you want to wake up?',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Pick the one closest to your life. You can change it later, and every '
          'setting stays editable.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        ...presets.map(
          (preset) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: RadioListTile<PersonaPreset>(
              value: preset,
              groupValue: _selected,
              onChanged: (value) => setState(() => _selected = value),
              title: Row(
                children: [
                  Text(preset.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(preset.displayName)),
                ],
              ),
              subtitle: Text(preset.tagline),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _selected == null ? null : _next,
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    final preset = _selected!;
    final changes = preset.defaults.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text('Here is what ${preset.displayName} sets',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Nothing is written until you confirm. After this you can change any of '
          'it in Settings.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                for (final entry in changes)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(_humanize(entry.key)),
                    trailing: Text(_format(entry.value)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Morning friction',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'How much effort it takes to dismiss the alarm. This is independent of '
          'your persona, and you can change it any time.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<Friction>(
          segments: const [
            ButtonSegment(value: Friction.low, label: Text('Low')),
            ButtonSegment(value: Friction.normal, label: Text('Normal')),
            ButtonSegment(value: Friction.high, label: Text('High')),
          ],
          selected: {_friction},
          onSelectionChanged: (selection) =>
              setState(() => _friction = selection.first),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            TextButton(
              onPressed: _saving ? null : () => setState(() => _step = 0),
              child: const Text('Back'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _saving ? null : _apply,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Start using Rise'),
            ),
          ],
        ),
      ],
    );
  }

  static String _humanize(String key) {
    final words = key
        .replaceAll('_enabled', '')
        .replaceAll('_minutes', ' (min)')
        .replaceAll('_seconds', ' (s)')
        .replaceAll('_hours', ' (h)')
        .split('_');
    final text = words.join(' ');
    return text.isEmpty ? key : text[0].toUpperCase() + text.substring(1);
  }

  static String _format(Object value) {
    if (value is bool) return value ? 'On' : 'Off';
    if (value is double) return value.toStringAsFixed(1);
    return '$value';
  }
}