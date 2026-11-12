# Sleep Detection & Phase Algorithms (Sleep as Android 20261016)

Target: `com.urbandroid.sleep` — APK `/tmp/opencode/sleep-analysis/Sleep-prod.apk`
versionName `20261016`, versionCode `2311729` (from `decoded/apktool.yml`).

Everything below was extracted from the DEX with jadx (REA MCP) and cross-checked
against the apktool-decoded smali in `/tmp/opencode/sleep-analysis/smali/`.
Claims that are reasoned rather than directly observed are marked **INFERRED**.
Anything that could not be determined is marked **UNKNOWN**.

---

## Data model (events/points, sampling, storage)

### 1.1 The physical sample

The accelerometer is read by `com.urbandroid.sleep.sensor.AccelManager` /
`com.urbandroid.sleep.sensor.BaseAccelManager`.

* Non-batched mode: `SensorManager.registerListener(..., SENSOR_DELAY_UI /*3*/)`
  → hardware rate is device dependent (~16.7 Hz typical). **INFERRED** from the
  constant `const/4 p1, 0x3` in `AccelManager.start(I)`.
* Batched mode: sampling period `0x2710` = 10 000 µs (100 Hz),
  maxReportLatency `0x3938700` = 60 000 000 µs (60 s) — or `batchPeriod*1000`
  when `Experiments.isBatchingFixExperiment()` is on.
* The **change value** is the acceleration magnitude (m/s²):

```java
// BaseAccelManager.onValuesUpdateNew(FFFJ)
p1 = p1*p1 + p2*p2 + p3*p3;
float magnitude = (float) Math.sqrt(p1);
if (firstValue) magnitude = 0f;          // first sample forced to 0
```

* Legacy path `onValuesUpdateLegacy` subtracts the previous sample per axis and
  then takes the magnitude of the difference (only used when
  `isNewActigraphy == false`).

### 1.2 Rate limiting to one point per 10 s

`com.urbandroid.sleep.smartwatch.generic.DataFrequencyGuard` is applied to every
batch before classification:

```java
// DataFrequencyGuard.<init>
this.sampleRateMillis = 10000L;          // 10 s
```

It buffers incoming values and emits **at most one value per 10 000 ms**
(`sampleRateMillis`). If more values arrive in a bucket they are collapsed with
`ScienceUtil.max(...)`. Therefore:

> **One "actigraph point" == one 10-second bucket of accelerometer magnitude.**

This 10 s granularity is the fundamental time unit of every window used below.

### 1.3 Storage of the graph

* `com.urbandroid.sleep.domain.AccelSleepRecorder` owns the live graph.
  `SleepService.FRAMERATE = 0x2710 = 10000` ms → the recorder's updater thread
  runs every 10 s.
* `AccelSleepRecorder.updateGraphValue(IActivityAggregator.Result[], boolean)`
  puts `result.actigraph` into the history array and `result.rawActivity` into
  `SleepRecord.addTempHistory(...)`.
* `AccelSleepRecorder.updateGraphValueWait(float[])` → `SleepRecord.addRecordIfNotFinished(...)`
  → `SleepRecord.addRecordInternal(float...)` appends one `Float` per point to
  `SleepRecord.history` (`List<Float>`).

```java
// SleepRecord.addRecordInternal
for (float f : fArr) { this.history.add(f); this.lastEntry = f; }
this.lastActivityUpdate = Utils.now();
```

* Legacy transform (records with `version < 10003` only):

```java
// AccelSleepRecorder.transformChange
if (record.getVersion() >= 10003 || f < 0.0f) return f;
return d < 1.0d ? f * f : (float) Math.sqrt(d);
```

### 1.4 `Event`, `Events`, `EventLabel`

`com.urbandroid.sleep.domain.Event` — immutable value object:

```java
public class Event {
    final long timestamp;      // epoch millis
    final EventLabel label;    // null => EventLabel.UNKNOWN on insert
    final String labelString;  // only for free-text labels
    final float value;         // payload (e.g. DHA bit, lux, hr)
    // ctors: Event(), (long, EventLabel), (long, EventLabel, float),
    //        (long, EventLabel, String, float)
    // withLabel(l) / withTimestamp(ts) return copies
    // toString(): "E(<label>)@<time>=<value>"
}
```

`com.urbandroid.sleep.domain.Events` — thread-safe (`synchronized (this.sync)`)
`ArrayList<Event>` kept **sorted by timestamp** (insertion via `ListIterator`).
`addEvent(long ts, EventLabel l, float v, int retry)`:

* if an event with the same label **and** the same timestamp already exists,
  and the label is one of `AWAKE_START / AWAKE_END / TRACKING_PAUSED /
  TRACKING_RESUMED`, the new event is retried at `ts + 1` (up to 30 retries);
* otherwise the event is inserted at the sorted position.

`com.urbandroid.sleep.domain.EventLabel` — 46-value enum. Phase-relevant
values: `DEEP_START/DEEP_END`, `LIGHT_START/LIGHT_END`, `REM_START/REM_END`,
`BROKEN_START/BROKEN_END`, `AWAKE_START/AWAKE_END`, `DHA`, `TRACKING_PAUSED`,
`TRACKING_RESUMED`, `WALKING_START/END`, `ALARM_STARTED`, `HR`, `SPO2`, `RR`,
`T`, `LUX`, `ANTISNORE`, `FLAGS`, `LAUGH`, `DEVICE`, `SDNN`, `SDANN`, `RDI`,
`NO_AWAKE`, `UNKNOWN`.
`hasValue == true` for: `HR, SPO2, RR, DHA, LUX, DEVICE, SDNN, SDANN, RDI`.

### 1.5 The `DHA` bit-set channel (high-activity flags)

`com.urbandroid.sleep.domain.EventsRawStorageKt` stores an arbitrary `BitSet`
inside `Events` under one label:

```java
writeBitSet(events, startTime, EventLabel.DHA, bits)
  -> write(): clears the label, splits the bytes into 4-byte floats and stores
     one Event per float, with timestamps startTime + i (1 ms apart),
     the *value* being the raw float bits.
readBitSet(events, EventLabel.DHA)
  -> read(): collects all DHA events sorted by timestamp, concatenates their
     4-byte float representations and reinterprets them as a BitSet.
```

The DHA bit-set is produced by `AdaptiveNormalizationFilter` (one bit per
**raw 10-second** point) and written during `SleepRecordHypnogram.aggregateHistoryNew`
for `record version >= 10007`.

### 1.6 `ShiftedEventsFix` (legacy data repair)

`com.urbandroid.sleep.domain.ShiftedEventsFix` repairs records written by an
older build where a group of labels was stored shifted by one slot.
Only applied to records starting after `BROKEN_RECORDS_START = 2019-09-06`.

`looksLikeShifted(events)` returns true when:

* two `DHA` events are **not** exactly 1 ms apart, or
* two `FLAGS` events are exactly 1 ms apart, or
* an `ANTISNORE` event carries `value > 0`.

`fixShiftedEvents(events)` then rotates the labels:

| old label | new label |
|---|---|
| DHA | LAUGH |
| FLAGS | DHA |
| ANTISNORE | LUX |
| T | FLAGS |
| LUX | T |
| NO_AWAKE | ANTISNORE |

and re-adds all events with `addEventDirect` (no sorting, no de-duplication).

---

## Activity classification (`isHighActivity` / `isSomeActivity`) with exact constants

### 2.1 `IActivityAggregator.Result`

```java
// com.urbandroid.sleep.sensor.aggregator.IActivityAggregator$Result
public final float rawActivity;   // p1 of the 4-arg ctor
public final float actigraph;     // p2 of the 4-arg ctor
public final boolean isSomeActivity;  // p3
public final boolean isHighActivity;  // p4
public boolean hasNoData() { return rawActivity < 0.0f; }
```

Implementations: `ActivityAggregatorAccel` (accelerometer) and
`ActivityAggregatorSonar` (ultrasonic).

### 2.2 `ActivityAggregatorAccel`

```java
// ctor
this.baseline = Moving.quantilePrecise(6, 0.5f);              // median of last 6 points
this.highActivityDetector = (sensorType == SensorType.SLEEPPHASER)
        ? HighActivity.normalizedAmplitudeBased(0.9f)
        : HighActivity.normalizedAmplitudeBased(1.1f);

// update(float raw)
float fAbs   = Math.abs(raw - baseline.apply(raw));
HighActivity.Result r = highActivityDetector.update(fAbs);
return new IActivityAggregator.Result(raw, fAbs, r.isSomeActivity, r.isHighActivity);
```

So the classifier input is the **absolute deviation of the acceleration
magnitude from the median of the previous 6 points** (6 points ≈ 60 s).

`raw` is the raw accelerometer magnitude; `fAbs` (stored in `actigraph`) is the
deviation from baseline. `hasNoData()` is true when the raw value is negative
(missing sample marker).

### 2.3 `HighActivity.NormalizedAmplitudeBased` — the actual thresholds

```java
// ctor(float f)   f = 0.9 (SleepPhaser) or 1.1 (everything else)
if (Experiments.getInstance().isActigraphyImprovementsExperiment2()) {
    someActivityThreshold = 2.5f;
    highActivityThreshold = 3.3f;
} else {
    someActivityThreshold = mapDeepSleepSensitivity(settings, 4.0f, 3.0f, 2.5f, 2.0f, 2.5f) * f;
    highActivityThreshold = f * mapDeepSleepSensitivity(settings, 6.75f, 4.5f, 3.0f, 2.0f, 3.0f);
}
if (Experiments.getInstance().isActigraphyImprovementsExperiment1())
    maximum = Moving.quantileScalable(720, 0.995f);
else
    maximum = Moving.max(720);
median = Moving.quantileScalable(720, 0.5f);
```

**In this build both experiment flags are hard-coded `true`**:

```java
// com.urbandroid.util.Experiments
public boolean isActigraphyImprovementsExperiment1() { return true; }
public boolean isActigraphyImprovementsExperiment2() { return true; }
public boolean isActigraphyImprovementsExperiment3() { return !isOptedOut(); }
```

⇒ **Active configuration**:
`someActivityThreshold = 2.5`, `highActivityThreshold = 3.3`,
`maximum = Moving.quantileScalable(720, 0.995)` (99.5th percentile over the last
720 points ≈ 2 h), `median = Moving.quantileScalable(720, 0.5)` (median over the
last 720 points).

The legacy (experiment-2 off) values, for reference:

| Deep-sleep sensitivity | `someActivityThreshold` | `highActivityThreshold` |
|---|---|---|
| HIGH | 2.0 × f | 2.0 × f |
| MEDIUM (default) | 2.5 × f | 3.0 × f |
| LOW | 3.0 × f | 4.5 × f |
| VERY_LOW | 4.0 × f | 6.75 × f |
| unknown (fallback) | 2.5 × f | 3.0 × f |

where `f = 0.9` for SleepPhaser, `1.1` otherwise.

`mapDeepSleepSensitivity` argument order is
`(settings, valueVeryLow, valueLow, valueMedium, valueHigh, default)` and maps
`Sensitivity.VERY_LOW→arg1, LOW→arg2, MEDIUM→arg3, HIGH→arg4`, else `arg5`
(verified in `com/urbandroid/util/SettingsExtKt$WhenMappings`).

### 2.4 The per-point decision

```java
// HighActivity.NormalizedAmplitudeBased.update(float f)
callCount++;
return (callCount >= 30) ? doUpdate(f) : RESULT_NONE;

// doUpdate(float f)
float fAbs = Math.abs(f);
float med  = median.apply(fAbs);
if (med != 0.0f) fAbs /= med;             // normalise by the 2 h median
float mx   = maximum.apply(fAbs);
if (mx <= 1.0f) return RESULT_NONE;       // no signal
if (callCount < 360) mx = Math.max(100.0f, mx);
float v = (float) Math.pow(Math.min(mx, fAbs), 1.0d / Math.log10(mx));
return new Result(v > someActivityThreshold, v > highActivityThreshold);
```

* Warm-up: the first **30** points (≈ 5 min) always report “no activity”.
* `mx` is the 99.5 % percentile of the last 720 normalized points (≈ 2 h);
  while `callCount < 360` (≈ 1 h) it is floored at 100 so the log-scale
  exponent cannot explode.
* The reported magnitude is `min(max, value) ^ (1 / log10(max))` — a
  log-like compression into roughly [1 … 100].
* `isSomeActivity` ⇔ `v > 2.5`; `isHighActivity` ⇔ `v > 3.3` (active build).

### 2.5 `Moving` primitives (com.urbandroid.sleep.snoring.feature.Moving)

* `sum(period)` — running **sum** over the last `period` values (ring buffer of
  `period + 1`).
* `avg(period)` — running average.
* `max(period)` / `min(period)` — sliding max/min.
* `quantilePrecise(period, q)` — exact percentile over the last `period` values
  (`Periodile.evaluate`, linear interpolation).
* `quantileScalable(period, q)` — approximate percentile using two priority
  queues over a ring buffer of `period + 1`.

---

## Deep sleep detector V8 — exact algorithm, window sizes, sensitivity mapping, pseudocode

### 3.1 What V8 is

`com.urbandroid.sleep.domain.DeepSleepDetectorV8` is the **real-time** sleep
phase detector. It is created in `AccelSleepRecorder.start(int)`:

```java
if (!isPairTrackingEnabled() || Experiments.getInstance().isActigraphyImprovementsExperiment1())
    this.deepSleepDetector = new DeepSleepDetectorV8(this.sensorType.isWearableAccelerometer());
else
    this.deepSleepDetector = new DeepSleepDetectorV6(this.sensorType.isWearableAccelerometer());
```

Experiment 1 is `true`, so **V8 is always used**. The `boolean` flag is
`isWearableAccelerometer()` = `isSmartWatch() || isBleAccel() || isPhaser()`.

`DeepSleepDetectorV8` has two collaborators:
* `DeepSleepIndicator` — the phase state machine (the “graph” phase source),
* `SleepPhaseIntentBroadcast` — broadcasts `com.urbandroid.sleep.TRACKING_DEEP_SLEEP`
  / `TRACKING_LIGHT_SLEEP` and drives the REM/lucid detector.

### 3.2 `DeepSleepIndicator.reset()` — the window sizes (the key answer)

```java
private void reset() {
    this.missingDataGuard = new MissingDataGuard(0);
    this.highActivityCountShortWindow = Moving.sum(this.isSmartWatch ? 12 : 6);
    this.someActivityCountLongWindow  = Moving.sum(30);
    this.lastResult = DeepSleepDetector.SleepPhase.UNKNOWN;
    this.pointsCount = 0;
}
```

| field | construction | points | wall-clock (10 s/point) |
|---|---|---|---|
| `highActivityCountShortWindow` | `Moving.sum(isSmartWatch ? 12 : 6)` | 6 (phone/sonar) / 12 (wearable) | 60 s / 120 s |
| `someActivityCountLongWindow` | `Moving.sum(30)` | 30 | 300 s (5 min) |

Both are **sums** (counts of qualifying points) over a sliding window, not
averages. The names "short"/"long" window are relative: short = 1–2 min,
long = 5 min.

### 3.3 `DeepSleepIndicator.update()` — the classifier

```java
public void update(IActivityAggregator.Result result) {
    this.missingDataGuard.update(result);
    if (this.missingDataGuard.getMissingDataRatio5min() > 0.9d) {
        Logger.logInfo("DeepSleepDetectorV8: reset - a lot of data missing");
        reset();
    } else if (this.missingDataGuard.isLastDataMissing()) {
        return;                                   // point ignored entirely
    } else {
        float fApply  = highActivityCountShortWindow.apply(result.isHighActivity ? 1.0f : 0.0f);
        float fApply2 = someActivityCountLongWindow.apply(result.isSomeActivity  ? 1.0f : 0.0f);
        int i = ++this.pointsCount;
        if (i < 12) {
            this.lastResult = DeepSleepDetector.SleepPhase.UNKNOWN;
        } else {
            this.lastResult = (Math.round(fApply) < 1
                    || Math.round(fApply2) < this.smartWakeupSensitivityChecks)
                    ? DeepSleepDetector.SleepPhase.DEEP_SLEEP
                    : DeepSleepDetector.SleepPhase.LIGHT_SLEEP;
        }
    }
}
```

* `Math.round(fApply) < 1` ⇔ **zero** high-activity points in the short window.
* `Math.round(fApply2) < smartWakeupSensitivityChecks` ⇔ the number of
  some-activity points in the 5-minute window is below the sensitivity threshold.
* Warm-up: the first **12** points (2 min) report `UNKNOWN`.
* `smartWakeupSensitivityChecks` is captured **once** in the constructor:
  `this.smartWakeupSensitivityChecks = DeepSleepDetectorV8.getSmartWakeupSensitivityChecks();`

### 3.4 `smartWakeupSensitivityChecks` — the user-facing setting

```java
public static int getSmartWakeupSensitivityChecks() {
    return SettingsExtKt.mapSmartWakeupSensitivityChecks(
            SharedApplicationContext.getSettings(), 1, 3, 6, 10, 3);
}
```

```java
// com.urbandroid.util.SettingsExtKt
public static final int mapSmartWakeupSensitivityChecks(
        Settings settings, int i, int i2, int i3, int i4, int i5) {
    int v = settings.getSmartWakeupSensitivityChecks();
    if (v == 0) return i;    // 1
    if (v == 1) return i2;   // 3
    if (v == 2) return i3;   // 6
    if (v == 3 || v == 4 || v == 8) return i4;   // 10
    Logger.logWarning("Unknown SmartWakeupSensitivityChecks: " + v);
    return i5;               // 3
}
```

Storage:

```java
// com.urbandroid.sleep.service.Settings
public int getSmartWakeupSensitivityChecks() {
    return getPrefInt("non_deep_sleep_sensitivity_checks_new", -1) == -1
         ? getSmartWakeupSensitivityChecksLegacy()
         : getPrefInt("non_deep_sleep_sensitivity_checks_new", 1);
}
public int getSmartWakeupSensitivityChecksLegacy() {
    return getPrefStringAsInt("non_deep_sleep_sensitivity_checks", 1);
}
```

UI (`decoded/res/xml/settings_smart.xml`):

```xml
<com.urbandroid.sleep.gui.SeekBarPreference
    android:max="3"
    android:title="@string/non_deep_sleep_sensitivity_title"   <!-- "Movement intensity" -->
    android:key="non_deep_sleep_sensitivity_checks_new"
    android:defaultValue="1"
    app:maxString="@string/low_sensitivity"
    app:minString="@string/high_sensitivity"
    app:seekBarStringArray="@array/sensitivity_array_smart_wake" />
```

`sensitivity_array_smart_wake` = `["@string/high_sensitivity",
"@string/medium_sensitivity", "@string/low_sensitivity",
"@string/very_low_sensitivity"]`.

### 3.5 Sensitivity → threshold table (final)

| UI label | stored int | `smartWakeupSensitivityChecks` |
|---|---|---|
| High sensitivity | 0 | **1** |
| Medium sensitivity (default) | 1 | **3** |
| Low sensitivity | 2 | **6** |
| Very low sensitivity | 3 | **10** |
| (legacy values 4 and 8) | 4 / 8 | **10** |
| unknown | – | 3 (fallback) |

### 3.6 `SleepPhaseIntentBroadcast` — the *broadcast* variant of the same logic

This second, slightly different consumer of the same setting drives the
`TRACKING_DEEP_SLEEP` / `TRACKING_LIGHT_SLEEP` broadcasts and the lucid-dream
detector:

```java
// ctor
this.someActivityCount = Moving.sum(30);
this.highActivityCount = Moving.sum(30);      // NOTE: 30, not 6/12
this.smartWakeupSensitivityChecks = DeepSleepDetectorV8.getSmartWakeupSensitivityChecks();

// update(result)
missingDataGuard.update(result);
if (missingDataGuard.isLastDataMissing()) return;
long now = clock.invoke();
int someCount = Math.round(someActivityCount.apply(result.isSomeActivity ? 1f : 0f));
int highCount = Math.round(highActivityCount.apply(result.isHighActivity ? 1f : 0f));
if (highCount < 1 && someCount < smartWakeupSensitivityChecks) {
    // DEEP
    if (deepSleepFrom == -1L) deepSleepFrom = now;
    if (deepSleepFrom > 0 && now - deepSleepFrom > 60000L) {   // > 1 min continuous
        if (!deepSleepReported) { broadcast TRACKING_DEEP_SLEEP; deepSleepReported = true; }
        remDetector.handleDeepSleep();
    }
} else {
    deepSleepFrom = -1L;
    if (deepSleepReported) { deepSleepReported = false; broadcast TRACKING_LIGHT_SLEEP; }
    remDetector.handleLightSleep();
}
if (SleepService.isAwake()) lastAwake = now;
if (now - lastAwake < 180000L /*0x2bf20 = 3 min*/) remDetector.handleAwake();
```

Note the asymmetry: the broadcast variant uses a **30-point (5 min)** window for
*both* counters, while `DeepSleepIndicator` uses 6/12 for the high-activity
counter.

---

## Missing-data guard

`com.urbandroid.sleep.domain.DeepSleepDetectorV8.MissingDataGuard`:

```java
private MissingDataGuard() {
    this.missingDataCount5min  = Moving.sum(30);
    this.missingDataCount10min = Moving.sum(60);
}

public void update(IActivityAggregator.Result result) {
    boolean zHasNoData = result.hasNoData();          // rawActivity < 0
    this.lastDataMissing = zHasNoData;
    float f = zHasNoData ? 1.0f : 0.0f;
    float c5  = this.missingDataCount5min.apply(f);
    float c10 = this.missingDataCount10min.apply(f);
    this.missingDataRatio5min  = c5  / 30.0f;
    this.missingDataRatio10min = c10 / 60.0f;
}
```

* 30 points = 300 s = **5 minutes** (matches the name `getMissingDataRatio5min`).
* 60 points = 600 s = **10 minutes** (`missingDataRatio10min` — computed but
  never read anywhere in the app).
* The ratio is *the number of missing points in the last 5 min divided by 30*.

Behaviour of the consumers:

* `DeepSleepIndicator`: if ratio5min > 0.9 → **full reset** (windows cleared,
  `pointsCount = 0`, phase back to `UNKNOWN`); else if the current point is
  missing → the point is **skipped** (neither counter advances, `pointsCount`
  is not incremented).
* `SleepPhaseIntentBroadcast`: only checks `isLastDataMissing()` and skips the
  point.

---

## Hypnogram / phase labelling — exact thresholds & formulas

The **graph** phases (DEEP / LIGHT / BROKEN / REM / AWAKE) are computed
offline from the stored record, not from the live V8 detector.

### 4.1 Dispatch

```java
// SleepRecordHypnogram
public static void computeHypnogramFromActigraph(SleepRecord sleepRecord) {
    if (sleepRecord.getVersion() < 10007 || !sleepRecord.getEvents().hasLabel(EventLabel.DHA))
        computeHypnogramFromActigraphOld(sleepRecord);
    else
        SleepRecordHypnogramKt.computeHypnogramFromActigraphNew(sleepRecord);
}
```

Current record version:

```java
// SleepRecord.getCurrentSetupVersion()
int v = 0x2717;                                        // 10007
if (Experiments.getInstance().isActigraphyImprovementsExperiment3()) v = 0x2718;   // 10008
```

`isActigraphyImprovementsExperiment3()` = `!isOptedOut()` — so users who have
not opted out of the experiment get **version 10008** (the thresholds below);
users who opted out get **10007** (threshold 3.3, min deep length 600 000 ms for
watch/sonar/phaser tags and 900 000 ms otherwise).

### 4.2 Aggregation of the raw actigraph (`SleepRecordHypnogram.aggregateHistoryNew`)

```java
public static List<Float> aggregateHistoryNew(int version, Date from, Date to,
        List<Float> history, Events events, long lastActivityUpdate) {
    if (version < 10005) return null;
    int size = history.size();
    if (size == 0 || ((to.getTime() - from.getTime()) / size > 15000) || size < 12)
        return history;                                   // no aggregation
    int agg = (size < 90) ? 3 : (size < 360 ? 6 : 30);
    BitSet excluded = computeExcludedIndices(events, version, size, lastActivityUpdate);
    if (PairTracking.hasSufficientDataForPairTracking()) {
        writeBitSet(events, from.getTime(), EventLabel.DHA, new BitSet());
        return convertArrayToList(PairTracking.getAggregatedActigraph(excluded));
    }
    ANFResult anf = AdaptiveNormalizationFilter.normalizeAmplitudes(
            ScienceUtil.toFloatArray(history), excluded);
    if (version >= 10007)
        writeBitSet(events, from.getTime(), EventLabel.DHA, anf.getHighActivityFlags(2.5f));
    return convertArrayToList(anf.aggregateOutput(agg));
}
```

* Aggregation factor: **3** for < 90 raw points, **6** for 90–359, **30** for ≥ 360.
* Aggregation itself = **max** over each window of `agg` points
  (`ANFResult.aggregateOutput` uses `Moving.max(agg)`).
* The **DHA** bit-set (high activity flags) is stored at **raw** resolution with
  threshold `output > 2.5`.

`SleepRecord.getFilteredHistory()` = `version >= 10005 ? aggregateHistoryNew() : aggregateHistoryOld(history)`.

### 4.3 `getMillisPerPoint` — the graph time base

```java
public static long getMillisPerPoint(int version, long from, long to, int count) {
    if (version < 10005) return (to - from) / count;
    long d = (to - from) / count;
    if (d <=  25000) return 10000L;
    if (d <=  50000) return 30000L;
    if (d <= 100000) return 60000L;
    return 300000L;
}
```

`timeStampToHistoryIndex(ts, count, from)` = `(count - 1) - (int)((from - ts) / 10000)`.

### 4.4 `computeHypnogramFromActigraphNew` — the top-level pipeline

```java
public static final void computeHypnogramFromActigraphNew(SleepRecord record) {
    if (record.getVersion() < 10007) return;
    long from = record.getFromTime(), to = record.getToTime();
    List<Float> filteredHistory = record.getFilteredHistory();
    long millisPerPoint = getMillisPerPoint(version, from, to, filteredHistory.size());
    int aggregation = (int) (millisPerPoint / SleepService.FRAMERATE);   // FRAMERATE = 10000
    float[] highActivityFreq = getHighActivityFrequency(
            EventsRawStorageKt.readBitSet(record.getEvents(), EventLabel.DHA),
            filteredHistory.size(), aggregation);
    List<Event> events = computeHypnogramNew(filteredHistory, highActivityFreq,
            from, to, millisPerPoint, version, record.getComment());
    record.getEvents().clearLabels(DEEP_START, DEEP_END, LIGHT_START, LIGHT_END,
                                   REM_START, REM_END, BROKEN_START, BROKEN_END);
    for (Event e : events) record.getEvents().addEvent(e);
    record.setQuality(getDeepSleepRatio(events));
    record.setCycles(getNoOfDeepSleepCycles(events));
}
```

`getHighActivityFrequency(bits, targetSize, aggregation)`:

```java
float[] raw = new float[targetSize * aggregation];
int n = Math.min(bits.length(), raw.length);
for (int i = 0; i < n; i++) if (bits.get(i)) raw[i] = 1.0f;
return ScienceUtil.decimate(ScienceUtil.movingAverage(raw, aggregation), aggregation);
```

⇒ `highActivityFreq[i]` = **fraction of the `aggregation`-point window that was
flagged as high activity** (0.0 … 1.0). `movingAverage` is a *forward* window
`avg(raw, i, i+aggregation)`.

### 4.5 `computeHypnogramNew` — top level

```java
if ((long) history.size() * millisPerPoint <= 1200000L) return emptyList();   // need > 20 min
List<EventInterval> phases = postProcessDeepIntervals(
        classifyActivitySegments(history, highActivityFreq, version, from, to, millisPerPoint),
        version, tags);
List<EventInterval> all = phases + detectREM(phases);
return all.flatMap { listOf(it.from, it.to) };     // Event list
```

### 4.6 `classifyActivitySegments` — DEEP vs LIGHT vs BROKEN

```java
float deepSleepThreshold = getDeepSleepThreshold(history, version);
float fMin = Math.min(3 / ((int) (millisPerPoint / SleepService.FRAMERATE)), 0.1f);

for (i in history.indices) {
    if (history[i] < 0f)                      → BROKEN_START/BROKEN_END
    else if (history[i] >= deepSleepThreshold) {
        float f = highActivityFreq[i];
        if (f <= 0.0f || f >= fMin)           → LIGHT_START/LIGHT_END
        else                                   → DEEP_START/DEEP_END
    }
    else                                      → DEEP_START/DEEP_END
}
```

**IMPORTANT (integer division).** `3 / aggregation` is *integer* division in the
bytecode (`div-int/2addr`), so:

| `millisPerPoint` | `aggregation` | `3 / aggregation` | `fMin = min(that, 0.1)` |
|---|---|---|---|
| 10 000 | 1 | 3 | **0.1** |
| 30 000 | 3 | 1 | **0.1** |
| 60 000 | 6 | 0 | **0.0** |
| 300 000 | 30 | 0 | **0.0** |

⇒ For a typical night (aggregation 6 or 30) `fMin = 0`, so the
“high-activity” veto never fires and the rule collapses to:

* `history[i] < 0` → BROKEN (no data)
* `0 ≤ history[i] < deepSleepThreshold` → **DEEP**
* `history[i] ≥ deepSleepThreshold` → **LIGHT**

For short records (aggregation 1 or 3) `fMin = 0.1`, and a point above the
threshold is only DEEP if `0 < highActivityFreq[i] < 0.1` (less than 10 % of the
window flagged high); `highActivityFreq == 0` still means LIGHT.

Timestamps of the produced events: start of point `i` = `from + i * millisPerPoint`,
end = `from + (i + 1) * millisPerPoint`; the last end is clamped to `to`.

### 4.7 `getDeepSleepThreshold`

```java
public static float getDeepSleepThreshold(List<Float> history, int version) {
    if (version >= 10008) return 3.1f;
    if (version >= 10005) return 3.3f;
    return (version > 10001)
         ? ScienceUtil.percentile(history.toArray(), 65.0f)   // 65th percentile
         : getAverageOfNonNegativeValues(history);
}
```

⇒ **3.1** for the current version (10008).

### 4.8 `getMinDeepSleepLength`

```java
public static int getMinDeepSleepLength(int version, String tags) {
    switch (version) {
        case 10000: case 10001: case 10002:
            return Tag.hasTag(tags, Tag.WATCH) ? 960000 : 1190000;
        case 10003: case 10004: return 960000;
        case 10005: case 10006: case 10007:
            return (Tag.hasTag(tags, Tag.WATCH) || Tag.hasTag(tags, Tag.SONAR)
                    || Tag.hasTag(tags, Tag.PHASER)) ? 600000 : 900000;
        case 10008: return 900000;
        default: return Tag.hasTag(tags, Tag.WATCH) ? 960000 : 1190000;
    }
}
```

⇒ **900 000 ms = 15 min** minimum length of a DEEP interval (version 10008).

### 4.9 `postProcessDeepIntervals`

1. Any interval whose start label is `DEEP_START` and whose length is
   `< minDeepSleepLength` is relabelled `LIGHT_START`/`LIGHT_END`.
2. Consecutive `LIGHT` intervals are merged into one.

### 4.10 `computeExcludedIndices` — points that must not influence normalization

```java
if (version < 10007 || !Experiments.isActigraphyImprovementsExperiment1()) return new BitSet();
BitSet out = new BitSet();
setForIntervals(out, intervals(AWAKE_START, AWAKE_END),   size, lastActivityUpdate, 60000L);
setForIntervals(out, intervals(TRACKING_PAUSED, TRACKING_RESUMED), size, lastActivityUpdate, 60000L);
setForIntervals(out, intervals(WALKING_START, WALKING_END), size, lastActivityUpdate, 60000L);
Event alarm = first(ALARM_STARTED);
if (alarm != null && alarm.timestamp <= lastActivityUpdate)
    setForInterval(out, new Interval(alarm.timestamp, lastActivityUpdate), size, lastActivityUpdate, 1000L);
out.set(0, Math.min(size / 5, 60));                    // first ≤ 12 min excluded
if (out.cardinality() > size * 0.66) out.clear();      // give up if too much excluded
```

`setForInterval` expands an interval to history indices with a ±60 s (or ±1 s for
the alarm tail) margin.

### 4.11 AWAKE phase

AWAKE intervals are produced **outside** the hypnogram, by
`com.urbandroid.sleep.service.awake.AwakeWhenHighActivityFrequency`:

```java
this.windowSize = 30;                                  // 5 min
int s = settings.getAwakeDetectionHighActivitySensitivity();
this.threshold = (s == 1) ? 0.475f : (s == 2) ? 0.35f : (s == 3) ? 0.25f : Float.POSITIVE_INFINITY;

// live decision
ANFResult anf = AdaptiveNormalizationFilter.normalizeAmplitudes(record.getHistory());
float[] flags = anf.getHighActivityFlagsFloat(3.0f);   // threshold 3.0 !
float avg = ScienceUtil.avg(flags, flags.length - windowSize, flags.length);
awake = (avg >= threshold);
```

and, once, at the beginning of the record (`recomputeBeginning`, needs ≥ 720
points ≈ 2 h and a ~10 s point spacing):

```java
Moving.sum(30) applied to the DHA flags;
awakeFlag[i] = (sum >= threshold * 30);
AWAKE_START / AWAKE_END events are written at from + i * millisPerPoint.
```

---

## REM detection

Two unrelated mechanisms exist.

### 5.1 Graph REM (`SleepRecordHypnogramKt.detectREM`)

Applied to the ordered list of DEEP/LIGHT/BROKEN intervals produced by
`classifyActivitySegments`:

```java
minutes10 = 10 min, minutes15 = 15 min, minutes5 = 5 min, minutes50 = 50 min
minOffset = 50   // minutes

for (i in 1 until intervals.size) {
    prev = intervals[i-1]; next = intervals[i];
    if (prev.from.label == DEEP_START && prev.length >= 10 min) {
        if (next.from.label == LIGHT_START && next.length >= 15 min) {
            long remStart = next.from.timestamp + 10 min;
            long avail    = next.length - 10 min;
            long dur = Math.min(avail,
                        Math.min(50 min, Math.max(5 min, ((avail / 5 min + 1) / 2) * 5 min)));
            long remEnd = remStart + dur;
            long earliest = intervals[0].from.timestamp + 50 min;
            if (earliest <= remStart)          add(REM_START=remStart, REM_END=remEnd);
            else if (remEnd - earliest >= 5 min) add(REM_START=earliest, REM_END=remEnd);
        }
    }
}
```

(The `avail / 5 min + 1) / 2) * 5 min` term is **long integer division**:
`avail=10 min → 5 min`, `15 → 10`, `20 → 10`, `25 → 15`, `30 → 15`, … capped
at 50 min, floored at 5 min.)

So a REM episode is: *at least 10 min of DEEP followed by at least 15 min of
LIGHT*; REM starts 10 min into the light phase, lasts roughly half of the
remaining light time (5-minute granularity, 5–50 min), and never starts before
50 min after the first sleep interval.

`clearRemAtAwake(Events)` additionally removes REM intervals that overlap AWAKE
intervals and drops REM fragments shorter than 5 min.

### 5.2 Real-time REM / lucid-dreaming detector (`com.urbandroid.sleep.domain.RemDetector*`)

`RemDetector` interface: `handleAwake()`, `handleDeepSleep()`, `handleLightSleep()`.

* `RemDetectorV1` (legacy, used only when experiment 1 is off) — a simple state
  machine: INIT → DEEP (on `handleDeepSleep`, `deepStart = now - 5 min`) →
  LIGHT (on `handleLightSleep`, only if the deep phase lasted > 15 min) → REM
  (if the light phase lasted > 10 min → fire lucid cue) ; a 20 min light phase
  also fires a second cue. `handleAwake` resets the state.

* `RemDetectorV2` (current) — interval bookkeeping + lucid cue firing:

```java
// factories (com.urbandroid.sleep.domain.RemDetectorV2$Companion)
newInstanceLowSensitivity:    deepWindow=15 min, minDeepLength=13 min, maxAwakeLength=0,        maxLucidCues=2
newInstanceMediumSensitivity: deepWindow=20 min, minDeepLength= 9 min, maxAwakeLength=0,        maxLucidCues=2
newInstanceHighSensitivity:   deepWindow=20 min, minDeepLength= 5 min, maxAwakeLength=7 min,    maxLucidCues=3
```

```java
handleAwake():    awakeIntervals.add(now-3min, now)  (or extendLast if the gap ≤ 3 min)
handleDeepSleep(): if status==DEEP → deepIntervals.extendLast(now)
                   else status=DEEP; deepIntervals.add(now-5min, now)
handleLightSleep(): if status==LIGHT → lightIntervals.extendLast(now); evaluateRemAndSendCues(now)
                   else status=LIGHT; lightIntervals.add(now-10s, now);
                        lucidCuesFiredCount=0; lucidCueIntervalStart=now-10s
```

```java
evaluateRemAndSendCues(now):
  if (now - sleepStart >= 55 min && lucidCuesFiredCount < maxLucidCuesCount) {
      if (now - lucidCueIntervalStart < 10 min) return;
      if ((awakeIntervals.isEmpty() || now - awakeIntervals.last().to >= 5 min)
          && awakeIntervals.intersectionLength(lightIntervals.last()) <= maxAwakeLength) {
          long from = lightIntervals.last().from;
          if (deepIntervals.intersectionLength(from - deepWindow, from) < minDeepLength) return;
          fireLucidCue(now); lucidCuesFiredCount++; lucidCueIntervalStart = now;
      }
  }
```

Which factory is used is selected by `Settings.getLucidSensitivity()`:
`1 → Low`, `2 → Medium`, `3 → High`, anything else → Medium with a warning.

`RemDetectorsKt.fireLucidCue(now)` only broadcasts
`com.urbandroid.sleep.LUCID_CUE_ACTION` if
`(now - record.fromTime)/3 600 000 ≥ settings.getLucidAfterHours()`.

`RemDetectorsKt.minutes(i) = i*60000`, `seconds(i) = i*1000`.

---

## Adaptive normalization

`com.urbandroid.sleep.domain.AdaptiveNormalizationFilter` turns raw
actigraph magnitudes into a device- and night-independent scale, and produces
the DHA high-activity flags.

```java
public static ANFResult normalizeAmplitudes(float[] input, BitSet excluded) {
    float[] out = Arrays.copyOf(input, input.length);
    float noise = getNoiseAmplitudeEstimate(input, excluded);
    if (noise == 0.0f) return new ANFResult(input, out, 0, 0, 1);
    for (int i = 0; i < out.length; i++) {
        float v = out[i];
        if (v >= 0.0f) v /= noise;                 // negatives kept as-is (missing data)
        out[i] = v;
    }
    float upper = getConservativeUpperBound(out, excluded);
    if (upper <= 1.0f) return new ANFResult(input, out, 0, 0, 1);
    double max = upper;
    double exponent = 1.0 / Math.log10(max);
    for (int i = 0; i < out.length; i++) {
        float v = out[i];
        if (v >= 0.0f) v = (float) Math.pow(Math.min(upper, v), exponent);
        out[i] = v;
    }
    return new ANFResult(input, out, noise, max, exponent);
}
```

### 6.1 `getNoiseAmplitudeEstimate`

```java
List<Float> vals = all input[i] >= 0 && !excluded.get(i);
if (vals.size() < 3) return 0f;
p = percentile(vals, 50); if (p > 0) return p;      // median
p = percentile(vals, 70); if (p > 0) return p;
p = percentile(vals, 90); if (p > 0) return p;
p = percentile(vals, 95); if (p > 0) return p;
return 0f;
```

⇒ the noise floor is the **median** of the non-excluded, non-negative samples
(falling back to the 70th / 90th / 95th percentile if the median is 0).

### 6.2 `getConservativeUpperBound`

```java
float[] copy = Arrays.copyOf(normalized, normalized.length);
for (int i = excluded.nextSetBit(0); i >= 0 && i < copy.length; i = excluded.nextSetBit(i+1))
    copy[i] = 1.0f;                        // excluded points count as "small"
float q = (length < 1000) ? 99.7f : (length < 2500 ? 99.8f : 99.9f);
return new Percentile().evaluate(copy, q);
```

⇒ the 99.7 / 99.8 / 99.9 th percentile of the normalized signal.

### 6.3 `ANFResult`

* `input` — raw values; `output` — normalized values; `median` = noise estimate;
  `max` = conservative upper bound; `exponent` = `1/log10(max)`.
* `getHighActivityFlags(float threshold)` → `BitSet` with bit *i* set iff
  `output[i] > threshold`.
* `getHighActivityFlagsFloat(float threshold)` → float array of 0.0/1.0.
* `aggregateOutput(int agg)` → sliding **max** over `agg` points:

```java
FloatFunction max = Moving.max(agg);
int n = (int) Math.ceil((double) output.length / agg);
float[] res = new float[n];
float cur = 0;
for (int i = 0; i < output.length; i++) {
    cur = max.apply(output[i]);
    if (i % agg == agg - 1) res[i / agg] = cur;
}
res[n - 1] = cur;
```

### 6.4 `Percentile` (`com.urbandroid.util.Percentile`)

Standard linear-interpolation percentile:
`v = (n + 1) * q / 100`; `v < 1 → sorted[0]`; `v ≥ n → sorted[n-1]`;
otherwise `sorted[floor(v)-1] + frac * (sorted[floor(v)] - sorted[floor(v)-1])`
with `frac = v - floor(v)`.

---

## Pseudocode summary (language-agnostic)

```
# ---------- constants ----------
POINT_MS                = 10_000          # one actigraph point = 10 s
FRAMERATE_MS           = 10_000
SOME_ACTIVITY_THRESHOLD = 2.5            # experiment2 ON (this build)
HIGH_ACTIVITY_THRESHOLD = 3.3            # experiment2 ON (this build)
NORMALIZE_WINDOW       = 720            # points (~2 h)
MAX_QUANTILE           = 0.995
MEDIAN_QUANTILE        = 0.5
WARMUP_POINTS          = 30             # ~5 min, before which no activity is reported
MAX_FLOOR_POINTS       = 360            # ~1 h, below which max is floored at 100
BASELINE_WINDOW        = 6              # points, median baseline

# ---------- per raw accelerometer sample (m/s^2 magnitude) ----------
raw = sqrt(x^2 + y^2 + z^2)              # first sample forced to 0
value = |raw - median(last 6 values)|    # baseline = Moving.quantilePrecise(6, 0.5)

# ---------- per 10-second point (after DataFrequencyGuard) ----------
n  = median(last 720 normalized)         # Moving.quantileScalable(720, 0.5)
mx = 99.5th percentile(last 720 normalized)   # Moving.quantileScalable(720, 0.995)
if n != 0: v = value / n
if mx <= 1: isSome = isHigh = false
else:
    if callCount < 360: mx = max(100, mx)
    v = min(mx, v) ^ (1 / log10(mx))
    isSome = v > 2.5
    isHigh = v > 3.3
callCount++

# ---------- live deep/light detector (DeepSleepDetectorV8) ----------
missing5 = sum(last 30 points where rawActivity < 0)      # 5 min
if missing5 / 30 > 0.9:  reset everything; phase = UNKNOWN
elif rawActivity < 0:    skip this point
else:
    highCount = sum(last (6 or 12) points where isHigh)    # 1 min phone / 2 min wearable
    someCount = sum(last 30 points where isSome)           # 5 min
    pointsCount++
    if pointsCount < 12: phase = UNKNOWN
    elif round(highCount) < 1 AND round(someCount) < sensitivityChecks:
        phase = DEEP_SLEEP
    else: phase = LIGHT_SLEEP
# sensitivityChecks: High=1, Medium=3, Low=6, VeryLow=10

# ---------- offline graph (hypnogram) ----------
rawHistory = list of 10-second magnitudes (one per point)
if rawHistory.size() == 0 or (to-from)/size > 15_000 or size < 12:
    filtered = rawHistory                      # no aggregation
else:
    agg = 3 if size < 90 else (6 if size < 360 else 30)
    excluded = indices of AWAKE / PAUSED / WALKING / post-alarm points
               (+ first min(size/5, 60) points); dropped if > 66 % of the record
    normalized[i] = (raw[i] >= 0) ? raw[i] / noiseEstimate : raw[i]
        noiseEstimate = median of non-negative, non-excluded values
                        (fallback 70th / 90th / 95th percentile, else 0)
    if noiseEstimate == 0: output = raw
    else:
        upper = percentile(normalized with excluded->1.0, 99.7/99.8/99.9 by size)
        if upper <= 1: output = normalized
        else: output[i] = min(upper, normalized[i]) ^ (1/log10(upper))
    filtered[i] = max(output[i-agg+1 .. i])          # sliding max over `agg`
    dhaFlags[i]  = (output[i] > 2.5)                  # stored in the DHA bit-set

millisPerPoint = (to-from)/len(filtered) bucketed to 10s / 30s / 60s / 300s
aggregation     = millisPerPoint / 10_000
highActivityFreq[i] = fraction of the `aggregation` raw points flagged DHA
                       (moving average over the window, then decimate)

if len(filtered) * millisPerPoint <= 1_200_000: no phases
threshold = 3.1                                  # version >= 10008
fMin = min(3 / aggregation (INTEGER division), 0.1)

for each point i:
    if filtered[i] < 0:                             -> BROKEN
    elif filtered[i] >= threshold:
        if highActivityFreq[i] <= 0 or >= fMin:     -> LIGHT
        else:                                       -> DEEP
    else:                                           -> DEEP

merge consecutive DEEP/LIGHT/BROKEN runs into intervals
DEEP intervals shorter than 900_000 ms (15 min)  -> relabelled LIGHT
consecutive LIGHT intervals are merged

REM (graph):
    for each consecutive pair (prev, next) of intervals sorted by start:
        if prev is DEEP and prev.length >= 10 min
           and next is LIGHT and next.length >= 15 min:
               remStart = next.start + 10 min
               avail    = next.length - 10 min
               dur      = min(avail, min(50 min, max(5 min, ((avail/5min + 1)/2)*5 min)))
               remEnd   = remStart + dur
               earliest = firstInterval.start + 50 min
               if earliest <= remStart:            emit REM[remStart, remEnd]
               elif remEnd - earliest >= 5 min:    emit REM[earliest, remEnd]

quality = sum(DEEP durations) / (sum(DEEP durations) + sum(LIGHT durations))   # -1 if 0
cycles  = number of DEEP intervals
```

---

## Evidence table

| # | Claim | Class | Method / field |
|---|---|---|---|
| 1 | Point cadence = 10 s | `com.urbandroid.sleep.smartwatch.generic.DataFrequencyGuard` | `<init>` (`sampleRateMillis = 10000L`), `process` |
| 2 | Graph refresh = 10 s | `com.urbandroid.sleep.SleepService` | `FRAMERATE = 0x2710` |
| 3 | Accel change = magnitude | `com.urbandroid.sleep.sensor.BaseAccelManager` | `onValuesUpdateNew` |
| 4 | Sample rate / batching | `com.urbandroid.sleep.sensor.AccelManager` | `start(I)` |
| 5 | History storage | `com.urbandroid.sleep.domain.SleepRecord` | `addRecordInternal`, `addTempHistory` |
| 6 | Legacy value transform | `com.urbandroid.sleep.domain.AccelSleepRecorder` | `transformChange` |
| 7 | `Event` model | `com.urbandroid.sleep.domain.Event` | fields, `<init>`, `withLabel`, `withTimestamp` |
| 8 | Sorted event store | `com.urbandroid.sleep.domain.Events` | `addEvent(long,EventLabel,float,int)`, `addEventDirect` |
| 9 | Event labels | `com.urbandroid.sleep.domain.EventLabel` | `<clinit>` |
| 10 | DHA bit-set codec | `com.urbandroid.sleep.domain.EventsRawStorageKt` | `writeBitSet`, `readBitSet`, `write`, `read`, `toBytes`, `toBitSet` |
| 11 | Shifted-label repair | `com.urbandroid.sleep.domain.ShiftedEventsFix` | `looksLikeShifted`, `fixShiftedEvents` (both overloads), `BROKEN_RECORDS_START` |
| 12 | Aggregator result fields | `com.urbandroid.sleep.sensor.aggregator.IActivityAggregator$Result` | `<init>(FFZZ)`, `hasNoData` |
| 13 | Baseline = median of 6 | `com.urbandroid.sleep.sensor.aggregator.ActivityAggregatorAccel` | `<init>`, `update` |
| 14 | Threshold constants 2.5 / 3.3 | `com.urbandroid.sleep.sensor.aggregator.HighActivity$NormalizedAmplitudeBased` | `<init>` |
| 15 | Normalisation + warm-up | `com.urbandroid.sleep.sensor.aggregator.HighActivity$NormalizedAmplitudeBased` | `update`, `doUpdate` |
| 16 | `Moving` primitives | `com.urbandroid.sleep.snoring.feature.Moving` | `sum`, `avg`, `max`, `quantilePrecise`, `quantileScalable` |
| 17 | V8 window sizes 6/12 & 30 | `com.urbandroid.sleep.domain.DeepSleepDetectorV8.DeepSleepIndicator` | `reset` |
| 18 | V8 classifier | `com.urbandroid.sleep.domain.DeepSleepDetectorV8.DeepSleepIndicator` | `update` |
| 19 | Sensitivity → checks (1/3/6/10) | `com.urbandroid.util.SettingsExtKt` | `mapSmartWakeupSensitivityChecks` |
| 20 | Setting storage | `com.urbandroid.sleep.service.Settings` | `getSmartWakeupSensitivityChecks`, `getSmartWakeupSensitivityChecksLegacy` |
| 21 | Setting UI (0..3, labels) | `decoded/res/xml/settings_smart.xml`, `decoded/res/values/arrays.xml` | `non_deep_sleep_sensitivity_checks_new`, `sensitivity_array_smart_wake` |
| 22 | Missing-data guard | `com.urbandroid.sleep.domain.DeepSleepDetectorV8.MissingDataGuard` | `<init>`, `update`, `getMissingDataRatio5min`, `isLastDataMissing` |
| 23 | Broadcast-phase logic (30/30, 1 min, 3 min) | `com.urbandroid.sleep.domain.DeepSleepDetectorV8.SleepPhaseIntentBroadcast` | `<init>`, `update`, `createRemDetector` |
| 24 | Experiment flags = true | `com.urbandroid.util.Experiments` | `isActigraphyImprovementsExperiment1/2` |
| 25 | Deep-sleep sensitivity mapping | `com.urbandroid.util.SettingsExtKt` | `mapDeepSleepSensitivity` (+ `WhenMappings`) |
| 26 | Sensitivity enum ↔ pref | `com.urbandroid.sleep.service.Settings` | `getDeepSleepSensitivity` (smali) |
| 27 | Aggregation factors 3/6/30 | `com.urbandroid.sleep.domain.SleepRecordHypnogram` | `aggregateHistoryNew` |
| 28 | `getMillisPerPoint` buckets | `com.urbandroid.sleep.domain.SleepRecordHypnogram` | `getMillisPerPoint` |
| 29 | History index mapping | `com.urbandroid.sleep.domain.SleepRecordHypnogram` | `timeStampToHistoryIndex` |
| 30 | Deep-sleep threshold 3.1 | `com.urbandroid.sleep.domain.SleepRecordHypnogram` | `getDeepSleepThreshold` |
| 31 | Min deep length 900 000 ms | `com.urbandroid.sleep.domain.SleepRecordHypnogram` | `getMinDeepSleepLength` |
| 32 | DEEP/LIGHT/BROKEN rules + `fMin` | `com.urbandroid.sleep.domain.SleepRecordHypnogramKt` | `classifyActivitySegments` (smali-verified) |
| 33 | Short-deep → LIGHT + merge | `com.urbandroid.sleep.domain.SleepRecordHypnogramKt` | `postProcessDeepIntervals` |
| 34 | High-activity frequency | `com.urbandroid.sleep.domain.SleepRecordHypnogramKt` | `getHighActivityFrequency` |
| 35 | Top-level hypnogram | `com.urbandroid.sleep.domain.SleepRecordHypnogramKt` | `computeHypnogramFromActigraphNew`, `computeHypnogramNew` |
| 36 | Legacy hypnogram | `com.urbandroid.sleep.domain.SleepRecordHypnogram` | `computeHypnogramFromActigraphOld` |
| 37 | Excluded indices | `com.urbandroid.sleep.domain.SleepRecordHypnogram` | `computeExcludedIndices`, `setForInterval(s)` |
| 38 | REM rules | `com.urbandroid.sleep.domain.SleepRecordHypnogramKt` | `detectREM(List)`, `detectREM(Events)`, `clearRemAtAwake` |
| 39 | Quality / cycles | `com.urbandroid.sleep.domain.SleepRecordHypnogramKt` | `getDeepSleepRatio`, `getNoOfDeepSleepCycles` |
| 40 | Adaptive normalization | `com.urbandroid.sleep.domain.AdaptiveNormalizationFilter` | `normalizeAmplitudes`, `getNoiseAmplitudeEstimate`, `getConservativeUpperBound` |
| 41 | ANF result helpers | `com.urbandroid.sleep.domain.AdaptiveNormalizationFilter$ANFResult` | `getHighActivityFlags`, `getHighActivityFlagsFloat`, `aggregateOutput` |
| 42 | Percentile semantics | `com.urbandroid.util.Percentile` | `evaluate`, `evaluateSorted` |
| 43 | Moving average / decimation | `com.urbandroid.util.ScienceUtil` | `movingAverage`, `inPlaceMovingAverage`, `decimate`, `max`, `avg` |
| 44 | AWAKE detection thresholds | `com.urbandroid.sleep.service.awake.AwakeWhenHighActivityFrequency` | `<init>`, `isAwake`, `recomputeBeginning` |
| 45 | REM V2 factories | `com.urbandroid.sleep.domain.RemDetectorV2$Companion` | `newInstanceLow/Medium/HighSensitivity` |
| 46 | REM V2 state machine | `com.urbandroid.sleep.domain.RemDetectorV2` | `handleAwake`, `handleDeepSleep`, `handleLightSleep`, `evaluateRemAndSendCues` |
| 47 | REM V1 state machine | `com.urbandroid.sleep.domain.RemDetectorV1` | `handleAwake`, `handleDeepSleep`, `handleLightSleep`, `reset` |
| 48 | Lucid cue gating | `com.urbandroid.sleep.domain.RemDetectorsKt` | `fireLucidCue`, `minutes`, `seconds` |
| 49 | Record version 10007/10008 | `com.urbandroid.sleep.domain.SleepRecord` | `getCurrentSetupVersion` (smali, `0x2717`/`0x2718`) |
| 50 | Wearable detection | `com.urbandroid.sleep.domain.SensorType` | `isWearableAccelerometer` |

---

## Still UNKNOWN

* The exact hardware accelerometer sampling frequency in non-batched mode is
  device dependent (`SENSOR_DELAY_UI`); the *effective* rate is normalised to
  10 s by `DataFrequencyGuard`, which is what all algorithms use.
* `Settings.getSmartWakeupSensitivityChecksLegacy()` reads the legacy pref
  `non_deep_sleep_sensitivity_checks` as a *string* int; the set of legacy
  values that may appear in the wild (other than 1) is **UNKNOWN** (the mapping
  only handles 0,1,2,3,4,8 explicitly).
* `Settings.getAwakeDetectionHighActivitySensitivity()` levels 1/2/3 are
  documented by the code above, but the UI labels for that separate setting are
  **UNKNOWN** (not traced in this pass).
* `Experiments.isActigraphyImprovementsExperiment3()` (the only user-opt-out
  experiment) gates the record version bump 10007 → 10008, which in turn selects
  `getDeepSleepThreshold` 3.3 → 3.1 and the min-deep-length rules; the default
  state of `isOptedOut()` for a fresh install is **UNKNOWN**.
* The `PairTracking` branch of `aggregateHistoryNew` (when a paired phone +
  watch is used) was not decompiled; the actigraph then comes from
  `PairTracking.getAggregatedActigraph(excluded)` instead of the ANF.
* `SleepRecord.computeAll()` overall orchestration order (and exactly when
  `aggregateHistoryNew` runs relative to `computeHypnogramFromActigraph`) was
  not fully traced.
