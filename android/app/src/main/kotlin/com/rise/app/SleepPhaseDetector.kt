package com.rise.app

import kotlin.math.abs
import kotlin.math.ln
import kotlin.math.pow
import kotlin.math.roundToInt

/**
 * Kotlin port of `SleepPhaseDetector` (lib/services/sleep_phase_detector.dart).
 *
 * The Dart class is the reference and the one with unit tests; this is the same
 * algorithm with the same constants, because it has to run inside a foreground
 * service where Dart cannot be relied on.
 *
 * Ported from Sleep as Android 20261016:
 *   DeepSleepDetectorV8 + ActivityAggregatorAccel + HighActivity.NormalizedAmplitudeBased
 *
 * One point = one 10 second sample.
 */
class SleepPhaseDetector(
    private val isSmartWatch: Boolean = false,
    private val sensitivity: MovementSensitivity = MovementSensitivity.STANDARD,
) {
    enum class Phase { UNKNOWN, DEEP_SLEEP, LIGHT_SLEEP }

    /** "Movement intensity": number of some-activity points in the 5 min window
     *  that disqualify a sample from deep sleep. */
    enum class MovementSensitivity(val checks: Int) {
        RESPONSIVE(1),   // seekbar 0
        STANDARD(3),     // seekbar 1, the default
        RELAXED(6),      // seekbar 2
        STRICT(10),      // seekbar 3
    }

    /** Sliding window mirroring com.urbandroid.sleep.snoring.feature.Moving. */
    private class Moving(private val period: Int) {
        private val values = ArrayDeque<Double>()

        fun sum(value: Double): Double {
            values.addLast(value)
            while (values.size > period + 1) values.removeFirst()
            val start = if (values.size > period) values.size - period else 0
            var total = 0.0
            for (i in start until values.size) total += values[i]
            return total
        }

        /** Exact percentile with linear interpolation (Periodile.evaluate). */
        fun quantile(value: Double, q: Double): Double {
            values.addLast(value)
            while (values.size > period + 1) values.removeFirst()
            val start = if (values.size > period) values.size - period else 0
            if (start >= values.size) return 0.0

            val sorted = values.toList().subList(start, values.size).sorted()
            if (sorted.size == 1) return sorted[0]

            val position = q * (sorted.size - 1)
            val lower = position.toInt()
            val upper = kotlin.math.ceil(position).toInt()
            if (lower == upper) return sorted[lower]
            val weight = position - lower
            return sorted[lower] * (1 - weight) + sorted[upper] * weight
        }

        fun clear() = values.clear()
    }

    private val baseline = Moving(BASELINE_WINDOW)
    private val median = Moving(NORMALIZATION_WINDOW)
    private val maximum = Moving(NORMALIZATION_WINDOW)

    private val highActivityWindow = ArrayDeque<Double>()
    private val someActivityWindow = ArrayDeque<Double>()
    private val missingWindow = ArrayDeque<Boolean>()

    private var callCount = 0
    private var pointsCount = 0
    private var phase = Phase.UNKNOWN

    val currentPhase: Phase get() = phase
    val pointCount: Int get() = pointsCount

    private val shortWindowLength: Int get() = if (isSmartWatch) 12 else 6

    /**
     * Feeds one raw accelerometer magnitude (m/s^2, ~9.8 at rest).
     * A negative value marks a missing sample.
     */
    fun addSample(magnitude: Double): Phase {
        callCount++

        val isMissing = magnitude < 0.0
        val raw = if (isMissing) 0.0 else magnitude

        var isSomeActivity = false
        var isHighActivity = false

        if (!isMissing) {
            val base = baseline.quantile(raw, 0.5)
            val deviation = abs(raw - base)

            // Normalise by the 2 h median of the deviation signal.
            val med = median.quantile(deviation, 0.5)
            var normalized = deviation
            if (med != 0.0) normalized = deviation / med

            // Scaling maximum: 99.5th percentile of the last 720 normalized points.
            var max = maximum.quantile(normalized, MAX_QUANTILE)
            if (max > 1.0) {
                if (callCount < MAX_FLOOR_POINTS && max < 100.0) max = 100.0
                // v = min(max, normalized) ^ (1 / log10(max))
                val exponent = 1.0 / (ln(max) / ln(10.0))
                val v = minOf(max, normalized).pow(exponent)
                isSomeActivity = v > SOME_ACTIVITY_THRESHOLD
                isHighActivity = v > HIGH_ACTIVITY_THRESHOLD
            }
        }

        trackMissing(isMissing)
        return updatePhase(isSomeActivity, isHighActivity)
    }

    private fun updatePhase(isSomeActivity: Boolean, isHighActivity: Boolean): Phase {
        if (missingRatio() > 0.9) {
            resetPhase()
            return phase
        }
        if (missingWindow.isEmpty() || missingWindow.last() == true) {
            // Last data point was missing: skip this point entirely.
            return phase
        }

        pushWindow(highActivityWindow, if (isHighActivity) 1.0 else 0.0, shortWindowLength)
        pushWindow(someActivityWindow, if (isSomeActivity) 1.0 else 0.0, LONG_WINDOW_LENGTH)

        pointsCount++
        phase = if (pointsCount < 12) {
            Phase.UNKNOWN
        } else {
            val highCount = highActivityWindow.sum().roundToInt()
            val someCount = someActivityWindow.sum().roundToInt()
            if (highCount < 1 && someCount < sensitivity.checks) Phase.DEEP_SLEEP else Phase.LIGHT_SLEEP
        }
        return phase
    }

    private fun resetPhase() {
        highActivityWindow.clear()
        someActivityWindow.clear()
        pointsCount = 0
        phase = Phase.UNKNOWN
    }

    fun reset() {
        baseline.clear()
        median.clear()
        maximum.clear()
        highActivityWindow.clear()
        someActivityWindow.clear()
        missingWindow.clear()
        callCount = 0
        pointsCount = 0
        phase = Phase.UNKNOWN
    }

    private fun trackMissing(isMissing: Boolean) {
        missingWindow.addLast(isMissing)
        while (missingWindow.size > LONG_WINDOW_LENGTH) missingWindow.removeFirst()
    }

    private fun missingRatio(): Double {
        if (missingWindow.isEmpty()) return 0.0
        val missing = missingWindow.count { it }
        return missing.toDouble() / LONG_WINDOW_LENGTH
    }

    private fun pushWindow(window: ArrayDeque<Double>, value: Double, length: Int) {
        window.addLast(value)
        while (window.size > length) window.removeFirst()
    }

    companion object {
        const val POINT_INTERVAL_MS = 10_000L

        private const val BASELINE_WINDOW = 6
        private const val NORMALIZATION_WINDOW = 720
        private const val WARMUP_POINTS = 30
        private const val MAX_FLOOR_POINTS = 360
        private const val LONG_WINDOW_LENGTH = 30
        private const val MAX_QUANTILE = 0.995

        const val SOME_ACTIVITY_THRESHOLD = 2.5
        const val HIGH_ACTIVITY_THRESHOLD = 3.3
    }
}