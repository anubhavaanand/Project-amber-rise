/// Port of the sleep-phase detection algorithm used by Sleep as Android
/// (`com.urbandroid.sleep.domain.DeepSleepDetectorV8` +
/// `com.urbandroid.sleep.sensor.aggregator.ActivityAggregatorAccel` +
/// `com.urbandroid.sleep.snoring.feature.HighActivity.NormalizedAmplitudeBased`).
///
/// Ported from `com.urbandroid.sleep` v20261016. The constants below are the
/// values observed in that build.
///
/// The pipeline is two stages:
///
/// 1. **Activity classification** — turn a raw accelerometer magnitude into
///    `isSomeActivity` / `isHighActivity` booleans.
/// 2. **Phase state machine** — combine those booleans over two sliding
///    windows to decide DEEP_SLEEP vs LIGHT_SLEEP.
///
/// Units: one *point* is one 10 second sample.
library;

import 'dart:math' as math;

/// The sleep phase reported by the detector.
enum SleepPhase {
  /// Not enough data yet (during warm-up, or right after a data gap).
  unknown,

  /// Deep sleep - low movement.
  deepSleep,

  /// Light sleep - some movement.
  lightSleep,

  /// Awake - high movement.
  awake,
}

/// "Movement intensity" setting, mapping to the number of *some activity*
/// points inside the 5 minute window that disqualify the sample from deep
/// sleep.
///
/// Mirrors `SettingsExtKt.mapSmartWakeupSensitivityChecks`. The original app
/// exposes this as a seekbar with the title "Movement intensity"; position 0
/// leaves deep sleep after a single movement point, position 3 needs ten.
///
/// A lower [sensitivityChecks] therefore means the detector reacts to movement
/// sooner and reports light sleep earlier.
enum MovementSensitivity {
  /// Seekbar position 0 - a single movement point ends deep sleep.
  responsive(1),

  /// Seekbar position 1 - the default in the original app.
  standard(3),

  /// Seekbar position 2.
  relaxed(6),

  /// Seekbar position 3 - needs sustained movement to end deep sleep.
  strict(10);

  const MovementSensitivity(this.sensitivityChecks);

  /// Number of *some activity* points in the 5 minute window that makes the
  /// phase LIGHT_SLEEP rather than DEEP_SLEEP.
  final int sensitivityChecks;
}

/// Sliding-window helpers, mirroring `com.urbandroid.sleep.snoring.feature.Moving`.
///
/// The original uses an approximate percentile (`quantileScalable`, two priority
/// queues) for the 99.5th percentile; this port uses the exact percentile with
/// linear interpolation, which is equivalent for the window sizes involved.
class _Moving {
  _Moving(this.period);

  final int period;
  final List<double> _values = [];

  /// Pushes [value] and returns the sum over the last [period] values.
  double sum(double value) {
    _values.add(value);
    while (_values.length > period + 1) {
      _values.removeAt(0);
    }
    final start = _values.length > period ? _values.length - period : 0;
    var total = 0.0;
    for (var i = start; i < _values.length; i++) {
      total += _values[i];
    }
    return total;
  }

  /// Pushes [value] and returns the [quantile] over the last [period] values.
  ///
  /// [quantile] is in the range 0..1. Uses linear interpolation between the
  /// two surrounding order statistics, matching `Periodile.evaluate`.
  double quantile(double value, double quantile) {
    _values.add(value);
    while (_values.length > period + 1) {
      _values.removeAt(0);
    }
    final start = _values.length > period ? _values.length - period : 0;
    if (start >= _values.length) return 0.0;

    final sorted = _values.sublist(start)..sort();
    if (sorted.length == 1) return sorted.first;

    final position = quantile * (sorted.length - 1);
    final lower = position.floor();
    final upper = position.ceil();
    if (lower == upper) return sorted[lower];
    final weight = position - lower;
    return sorted[lower] * (1 - weight) + sorted[upper] * weight;
  }
}

/// Detects deep vs light sleep from a stream of accelerometer magnitudes.
///
/// Feed it one magnitude per [pointIntervalMs] with [addSample] and read
/// [phase] (or use the value returned by [addSample]).
///
/// A negative [magnitude] marks a *missing* sample, exactly like the original
/// app's `IActivityAggregator.Result.hasNoData()`.
class SleepPhaseDetector {
  SleepPhaseDetector({
    this.isSmartWatch = false,
    this.sensitivity = MovementSensitivity.standard,
  });

  /// Sampling interval of one point, in milliseconds.
  static const int pointIntervalMs = 10000;

  /// Median window used for the movement baseline (6 points = 60 s).
  static const int _baselineWindow = 6;

  /// Window used to normalise and scale the movement signal (720 points = 2 h).
  static const int _normalizationWindow = 720;

  /// Number of points before activity classification starts (30 points = 5 min).
  static const int _warmupPoints = 30;

  /// While fewer than this many points have been seen, the scaling maximum is
  /// floored at 100 so the log exponent cannot explode (360 points = 1 h).
  static const int _maxFloorPoints = 360;

  /// Activity above this normalized magnitude counts as *some* activity.
  static const double someActivityThreshold = 2.5;

  /// Activity above this normalized magnitude counts as *high* activity.
  static const double highActivityThreshold = 3.3;

  /// Quantile used for the scaling maximum.
  static const double _maxQuantile = 0.995;

  /// Whether the samples come from a wearable accelerometer, which uses a
  /// longer short window.
  final bool isSmartWatch;

  /// "Movement intensity" setting.
  final MovementSensitivity sensitivity;

  late final _Moving _baseline = _Moving(_baselineWindow);
  late final _Moving _median = _Moving(_normalizationWindow);
  late final _Moving _maximum = _Moving(_normalizationWindow);

  final List<double> _highActivityWindow = [];
  final List<double> _someActivityWindow = [];
  final List<bool> _missingWindow = [];

  int _callCount = 0;
  int _pointsCount = 0;
  SleepPhase _phase = SleepPhase.unknown;

  /// The most recent phase.
  SleepPhase get phase => _phase;

  /// Number of points fed in so far.
  int get pointCount => _pointsCount;

  /// Short window length: 1 minute on the phone, 2 minutes on a wearable.
  int get _shortWindowLength => isSmartWatch ? 12 : 6;

  /// Long window length: 5 minutes.
  static const int _longWindowLength = 30;

  /// Feeds one raw accelerometer magnitude and returns the resulting phase.
  ///
  /// [magnitude] is the acceleration magnitude in m/s^2 (for example the
  /// Euclidean length of the accelerometer vector, which is ~9.8 at rest).
  /// Pass a negative value to signal a missing sample.
  SleepPhase addSample(double magnitude) {
    _callCount++;

    final isMissing = magnitude < 0.0;
    final raw = isMissing ? 0.0 : magnitude;

    // Stage 1: activity classification.
    var deviation = 0.0;
    var isSomeActivity = false;
    var isHighActivity = false;

    if (!isMissing) {
      // Absolute deviation from the median of the last 6 points.
      final baseline = _baseline.quantile(raw, 0.5);
      deviation = (raw - baseline).abs();

      // Normalise by the 2 h median of the deviation signal.
      final median = _median.quantile(deviation, 0.5);
      var normalized = deviation;
      if (median != 0.0) {
        normalized = deviation / median;
      }

      // Scaling maximum: 99.5th percentile of the last 720 normalized points.
      var max = _maximum.quantile(normalized, _maxQuantile);
      if (max > 1.0) {
        if (_callCount < _maxFloorPoints && max < 100.0) {
          max = 100.0;
        }
        // v = min(max, normalized) ^ (1 / log10(max))
        final exponent = 1.0 / (math.log(max) / math.ln10);
        final v = math.pow(_min(max, normalized), exponent).toDouble();
        isSomeActivity = v > someActivityThreshold;
        isHighActivity = v > highActivityThreshold;
      }
    }

    // Stage 2: phase state machine.
    _trackMissing(isMissing);
    return _updatePhase(isSomeActivity, isHighActivity);
  }

  /// Updates the missing-data guard and the phase.
  SleepPhase _updatePhase(bool isSomeActivity, bool isHighActivity) {
    final missingRatio = _missingRatio();

    if (missingRatio > 0.9) {
      // Too much missing data - reset the detector.
      _resetPhase();
      return _phase;
    }

    if (_isLastDataMissing) {
      // Skip this point entirely.
      return _phase;
    }

    _pushWindow(_highActivityWindow, isHighActivity ? 1.0 : 0.0,
        _shortWindowLength);
    _pushWindow(_someActivityWindow, isSomeActivity ? 1.0 : 0.0,
        _longWindowLength);

    _pointsCount++;
    if (_pointsCount < 12) {
      // The original app reports UNKNOWN for the first 12 points (2 minutes).
      _phase = SleepPhase.unknown;
    } else {
      final highCount = _windowSum(_highActivityWindow).round();
      final someCount = _windowSum(_someActivityWindow).round();
      _phase = (highCount < 1 && someCount < sensitivity.sensitivityChecks)
          ? SleepPhase.deepSleep
          : SleepPhase.lightSleep;
    }
    return _phase;
  }

  /// Resets the phase state machine (not the activity classifier).
  void _resetPhase() {
    _highActivityWindow.clear();
    _someActivityWindow.clear();
    _pointsCount = 0;
    _phase = SleepPhase.unknown;
  }

  /// Clears all state, including the activity classifier.
  void reset() {
    _baseline._values.clear();
    _median._values.clear();
    _maximum._values.clear();
    _highActivityWindow.clear();
    _someActivityWindow.clear();
    _missingWindow.clear();
    _callCount = 0;
    _pointsCount = 0;
    _phase = SleepPhase.unknown;
  }

  void _trackMissing(bool isMissing) {
    _missingWindow.add(isMissing);
    while (_missingWindow.length > _longWindowLength) {
      _missingWindow.removeAt(0);
    }
  }

  bool get _isLastDataMissing =>
      _missingWindow.isNotEmpty && _missingWindow.last;

  /// Ratio of missing points over the last 5 minutes.
  double _missingRatio() {
    if (_missingWindow.isEmpty) return 0.0;
    var missing = 0;
    for (final value in _missingWindow) {
      if (value) missing++;
    }
    return missing / _longWindowLength;
  }

  static void _pushWindow(List<double> window, double value, int length) {
    window.add(value);
    while (window.length > length) {
      window.removeAt(0);
    }
  }

  static double _windowSum(List<double> window) {
    var total = 0.0;
    for (final value in window) {
      total += value;
    }
    return total;
  }

  static double _min(double a, double b) => a < b ? a : b;
}
