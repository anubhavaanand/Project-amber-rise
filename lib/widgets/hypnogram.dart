import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// One 10-minute sleep phase.
enum SleepPhase { awake, rem, light, deep }

/// A hypnogram: sleep depth over time, as a staircase.
///
/// The reference implementation renders deep/light/REM/awake on one time axis
/// with gaps shown as breaks rather than zero-height segments. This follows the
/// same structure, drawn from scratch.
///
/// [movement] is the per-10-minute movement intensity recorded during tracking.
/// Values are classified with the same thresholds the tracking service uses.
class Hypnogram extends StatelessWidget {
  const Hypnogram({
    super.key,
    required this.movement,
    this.height = 150,
  });

  final List<double> movement;
  final double height;

  static const double awakeThreshold = 1.5;
  static const double lightThreshold = 0.8;
  static const double remThreshold = 0.3;

  /// Classifies one movement sample. Negative or absent values are "no data".
  static SleepPhase? classify(double value) {
    if (value.isNaN || value < 0) return null;
    if (value > awakeThreshold) return SleepPhase.awake;
    if (value > lightThreshold) return SleepPhase.light;
    if (value > remThreshold) return SleepPhase.rem;
    return SleepPhase.deep;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _HypnogramPainter(movement: movement),
      ),
    );
  }
}

class _HypnogramPainter extends CustomPainter {
  _HypnogramPainter({required this.movement});

  final List<double> movement;

  /// Top to bottom: awake, REM, light, deep.
  static const _order = [
    SleepPhase.awake,
    SleepPhase.rem,
    SleepPhase.light,
    SleepPhase.deep,
  ];

  static Color _color(SleepPhase phase) {
    switch (phase) {
      case SleepPhase.awake:
        return AppColors.phaseAwake;
      case SleepPhase.rem:
        return AppColors.phaseRem;
      case SleepPhase.light:
        return AppColors.phaseLight;
      case SleepPhase.deep:
        return AppColors.phaseDeep;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final data = movement;
    if (data.isEmpty) {
      _paintEmpty(canvas, size);
      return;
    }

    // Four phase bands, with padding top and bottom.
    const padTop = 10.0;
    const padBottom = 10.0;
    final usable = size.height - padTop - padBottom;
    final rowHeight = usable / _order.length;

    double yFor(SleepPhase phase) {
      final index = _order.indexOf(phase);
      return padTop + rowHeight * index + rowHeight / 2;
    }

    // Subtle band separators.
    final gridPaint = Paint()
      ..color = AppColors.outline
      ..strokeWidth = 1;
    for (var i = 1; i < _order.length; i++) {
      final y = padTop + rowHeight * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Group consecutive samples that share a phase, so a long stretch is one
    // bar rather than many touching ones.
    final stepWidth = size.width / data.length;
    final stroke = math.max(3.0, stepWidth * 0.9);

    var runStart = 0;
    var runPhase = Hypnogram.classify(data.first);

    void flush(int endExclusive) {
      if (runPhase == null || endExclusive <= runStart) return;
      final paint = Paint()
        ..color = _color(runPhase!)
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      final y = yFor(runPhase!);
      final x1 = runStart * stepWidth + stroke / 2;
      final x2 = endExclusive * stepWidth - stroke / 2;
      canvas.drawLine(Offset(x1, y), Offset(math.max(x1, x2), y), paint);
    }

    for (var i = 1; i <= data.length; i++) {
      final phase = i < data.length ? Hypnogram.classify(data[i]) : null;
      if (phase != runPhase) {
        flush(i);
        runStart = i;
        runPhase = phase;
      }
    }
  }

  void _paintEmpty(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceHigh
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_HypnogramPainter oldDelegate) =>
      oldDelegate.movement.length != movement.length ||
      !_sameValues(oldDelegate.movement, movement);
}

bool _sameValues(List<double> a, List<double> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}