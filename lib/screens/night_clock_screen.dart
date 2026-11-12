import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/sleep_record.dart';
import '../services/sleep_tracking_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hypnogram.dart';

/// The night screen.
///
/// While tracking, the phone sits on the nightstand, so this screen behaves as a
/// bedside clock: a large time display, a dim mode for the dark, and the night
/// drawing itself underneath. The tracking itself is entirely
/// [SleepTrackingService]'s job - this screen only presents and controls it.
class NightClockScreen extends StatefulWidget {
  const NightClockScreen({super.key});

  @override
  State<NightClockScreen> createState() => _NightClockScreenState();
}

class _NightClockScreenState extends State<NightClockScreen>
    with WidgetsBindingObserver {
  SleepTrackingService? get _service => SleepTrackingService.instance;

  StreamSubscription<SleepTrackingState>? _stateSub;
  Timer? _tick;
  Timer? _sample;

  SleepTrackingState _state =
      const SleepTrackingState(isTracking: false);
  bool _dim = false;
  bool _busy = false;

  /// Movement samples collected this session, one per 10 s, for the live graph.
  final List<double> _movement = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _stateSub = _service?.stateStream.listen((s) {
      if (mounted) setState(() => _state = s);
    });
    _startTick();
    _startSampling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stateSub?.cancel();
    _tick?.cancel();
    _sample?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Keep the screen awake while it is the visible night clock.
    if (state == AppLifecycleState.resumed) {
      _startTick();
    } else if (state == AppLifecycleState.paused) {
      _tick?.cancel();
    }
  }

  void _startTick() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _startSampling() {
    _sample?.cancel();
    _sample = Timer.periodic(const Duration(seconds: 10), (_) {
      final service = _service;
      if (service == null) return;
      final movement = service.currentMovement;
      if (!mounted) return;
      setState(() => _movement.add(movement < 0 ? -1 : movement));
    });
  }

  Future<void> _start() async {
    final service = _service;
    if (service == null || _busy) return;
    setState(() => _busy = true);
    service.startTracking();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _stop() async {
    final service = _service;
    if (service == null || _busy) return;
    setState(() => _busy = true);
    final record = await service.stopTracking();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (!mounted) return;
    setState(() => _busy = false);
    if (record != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved ${record.sleepDurationString} of sleep')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracking = _state.isTracking || (_service?.isTracking ?? false);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: _dim ? Colors.black : AppColors.background,
      body: GestureDetector(
        onTap: () => setState(() => _dim = !_dim),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _grabHandle(),
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Clock(
                        now: now,
                        dim: _dim,
                        bedTime: _state.bedTime,
                      ),
                      const SizedBox(height: 28),
                      if (tracking) ...[
                        _LiveGraph(movement: _movement, dim: _dim),
                        const SizedBox(height: 18),
                        _PhasePill(phase: _state.currentPhase, dim: _dim),
                      ] else
                        _StartPrompt(dim: _dim, busy: _busy, onStart: _start),
                    ],
                  ),
                ),
                if (tracking)
                  _Controls(
                    dim: _dim,
                    busy: _busy,
                    onStop: _stop,
                  )
                else
                  const SizedBox(height: 24),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _grabHandle() => Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: _dim ? Colors.white24 : AppColors.outline,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}

class _Clock extends StatelessWidget {
  const _Clock({
    required this.now,
    required this.dim,
    required this.bedTime,
  });

  final DateTime now;
  final bool dim;
  final DateTime? bedTime;

  @override
  Widget build(BuildContext context) {
    final color = dim ? Colors.white70 : AppColors.onSurface;
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');

    return Column(
      children: [
        Text(
          '$hh:$mm',
          style: TextStyle(
            fontSize: dim ? 76 : 88,
            height: 1.0,
            fontWeight: FontWeight.w300,
            letterSpacing: -2,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          bedTime == null ? 'Not tracking' : _elapsed(bedTime!),
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 0.3,
            color: dim ? Colors.white38 : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  static String _elapsed(DateTime from) {
    final d = DateTime.now().difference(from);
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return h > 0 ? '$h h $m m asleep' : '$m m asleep';
  }
}

class _LiveGraph extends StatelessWidget {
  const _LiveGraph({required this.movement, required this.dim});

  final List<double> movement;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dim ? 0.35 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: dim ? Colors.transparent : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dim ? Colors.white12 : AppColors.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TONIGHT',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: dim ? Colors.white38 : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Hypnogram(movement: movement, height: 96),
          ],
        ),
      ),
    );
  }
}

class _PhasePill extends StatelessWidget {
  const _PhasePill({required this.phase, required this.dim});

  final SleepPhase? phase;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    if (phase == null) return const SizedBox.shrink();

    final (label, color) = switch (phase!) {
      SleepPhase.awake => ('Awake', AppColors.phaseAwake),
      SleepPhase.rem => ('REM', AppColors.phaseRem),
      SleepPhase.light => ('Light sleep', AppColors.phaseLight),
      SleepPhase.deep => ('Deep sleep', AppColors.phaseDeep),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: dim ? 0.08 : 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartPrompt extends StatelessWidget {
  const _StartPrompt({
    required this.dim,
    required this.busy,
    required this.onStart,
  });

  final bool dim;
  final bool busy;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Rise will sample movement all night and wake you in light sleep.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: dim ? Colors.white38 : AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: busy ? null : onStart,
          icon: busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.bedtime, size: 18),
          label: const Text('Start tracking'),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.dim,
    required this.busy,
    required this.onStop,
  });

  final bool dim;
  final bool busy;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Tap the clock to dim',
          style: TextStyle(
            fontSize: 11.5,
            color: dim ? Colors.white24 : AppColors.onSurfaceFaint,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: busy ? null : onStop,
            style: FilledButton.styleFrom(
              backgroundColor: dim ? Colors.white12 : AppColors.error,
              foregroundColor: dim ? Colors.white70 : Colors.white,
            ),
            icon: const Icon(Icons.stop, size: 18),
            label: const Text('Stop and save'),
          ),
        ),
      ],
    );
  }
}