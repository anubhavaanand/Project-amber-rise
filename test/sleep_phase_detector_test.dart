import 'package:flutter_test/flutter_test.dart';
import 'package:rise/services/sleep_phase_detector.dart';

/// Tests for the port of Sleep as Android's `DeepSleepDetectorV8`.
///
/// The reference implementation is `com.urbandroid.sleep` v20261016.
void main() {
  group('SleepPhaseDetector', () {
    test('reports unknown until 12 points have been collected', () {
      final detector = SleepPhaseDetector();

      // 12 points at 10 s each = 2 minutes.
      for (var i = 0; i < 11; i++) {
        expect(
          detector.addSample(9.8),
          SleepPhase.unknown,
          reason: 'point $i should still be unknown',
        );
      }
      expect(detector.addSample(9.8), SleepPhase.deepSleep);
    });

    test('reports deep sleep while the phone is completely still', () {
      final detector = SleepPhaseDetector();

      SleepPhase phase = SleepPhase.unknown;
      for (var i = 0; i < 120; i++) {
        phase = detector.addSample(9.8);
      }

      expect(phase, SleepPhase.deepSleep);
    });

    test('reports light sleep when movement occurs every 6th point', () {
      final detector = SleepPhaseDetector();

      // A large spike every 6th sample. The 6 point "high activity" window
      // therefore always contains exactly one high activity sample, which is
      // enough to disqualify deep sleep.
      SleepPhase phase = SleepPhase.unknown;
      for (var i = 0; i < 120; i++) {
        final magnitude = (i % 6 == 5) ? 21.8 : 9.8;
        phase = detector.addSample(magnitude);
      }

      expect(phase, SleepPhase.lightSleep);
    });

    test('a single missing sample does not change the phase', () {
      final detector = SleepPhaseDetector();

      for (var i = 0; i < 60; i++) {
        detector.addSample(9.8);
      }
      expect(detector.phase, SleepPhase.deepSleep);

      // A negative magnitude marks a missing sample.
      expect(detector.addSample(-1.0), SleepPhase.deepSleep);
    });

    test('resets to unknown when more than 90% of the window is missing', () {
      final detector = SleepPhaseDetector();

      for (var i = 0; i < 60; i++) {
        detector.addSample(9.8);
      }
      expect(detector.phase, SleepPhase.deepSleep);

      // 30 missing samples in a row - the 5 minute missing ratio reaches 1.0,
      // which is above the 0.9 threshold, so the detector resets.
      for (var i = 0; i < 30; i++) {
        detector.addSample(-1.0);
      }

      expect(detector.phase, SleepPhase.unknown);
      expect(detector.pointCount, 0);
    });

    test('the movement intensity setting changes when deep sleep ends', () {
      // Moderate movement: a deviation of 8 m/s^2 normalizes to
      // v = sqrt(8) = 2.83, which is above the "some activity" threshold
      // (2.5) but below the "high activity" threshold (3.3).
      //
      // That isolates the long (5 minute) window: one "some activity" point
      // is enough to leave deep sleep with the strictest sensitivity
      // (sensitivityChecks = 1) but not with the default (3).
      int lightSleepPoints(SleepPhaseDetector detector) {
        var count = 0;
        for (var i = 0; i < 300; i++) {
          final magnitude = (i % 30 == 29) ? 17.8 : 9.8;
          detector.addSample(magnitude);
          if (detector.phase == SleepPhase.lightSleep) count++;
        }
        return count;
      }

      final responsive =
          SleepPhaseDetector(sensitivity: MovementSensitivity.responsive);
      final strict = SleepPhaseDetector(sensitivity: MovementSensitivity.strict);

      expect(lightSleepPoints(responsive), greaterThan(0));
      expect(lightSleepPoints(strict), 0);
    });
  });
}
