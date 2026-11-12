# Audio Analysis, Sleep Regularity & Analytics — Sleep as Android 20261016

Evidence: REA/jadx decompilation of `com.urbandroid.sleep.audio.*`,
`com.urbandroid.sleep.snoring.*`, `com.urbandroid.sleep.addon.stats.model.socialjetlag.*`.
All snippets below are verbatim decompiled output unless marked INFERRED.

---

## 1. Audio capture pipeline

### 1.1 Recorder construction — `AudioRecorder.initialize()`

```java
private final AudioRecord initialize() {
    AudioRecordBuilder audioRecordBuilder = new AudioRecordBuilder(2, 3, 0, 262144, new int[]{48000, 44100}, 4, null);
    AudioRecord audioRecordBuild = audioRecordBuilder.build();
    if (audioRecordBuild == null) return null;
    this.sampleRate = audioRecordBuilder.getSampleRate();
    this.stereo   = audioRecordBuilder.getIsStereo();
    return audioRecordBuild;
}
```

`AudioRecordBuilder(int,int,int,int,int[])` maps to:

| Field | Value | Meaning |
|---|---|---|
| `audioFormat` | `2` | `AudioFormat.ENCODING_PCM_16BIT` |
| `attempts` | `3` | retry passes over the candidate sample rates |
| `channelConfig` | `0` | `AudioFormat.CHANNEL_IN_MONO` |
| `bufferSize` | `262144` | initial value; **overwritten** in `build()` |
| `sampleRates` | `{48000, 44100}` | tried in this order |
| (6th arg `4`) | — | Kotlin default-argument mask on the synthetic constructor |

### 1.2 Buffer sizing — `AudioRecordBuilder.build()`

```java
int minBufferSize = AudioRecord.getMinBufferSize(i8 /*sampleRate*/, this.channelConfig, this.audioFormat);
this.bufferSize = 131072;                       // 128 KiB floor
if (minBufferSize > 131072) {
    Logger.logInfo(... "Increasing buffer size from " + 131072 + " to " + minBufferSize + ".");
    this.bufferSize = minBufferSize;            // grow to the device minimum
}
audioRecord = new AudioRecord(SonarConfig.RECORDING_INPUT, i8, this.channelConfig, this.audioFormat, this.bufferSize);
if (audioRecord.getState() == 1) {              // STATE_INITIALIZED
    this.isStereo = (this.channelConfig == 12); // CHANNEL_IN_STEREO
    audioRecord.startRecording();
    SharedApplicationContext.getSettings().setFailedToInitRecording(false);
    return audioRecord;
}
```

Failure path: on a non-initialized `AudioRecord` or a thrown exception, the recorder is released and
an explicit broadcast `"recording_initialization_failed"` is sent. After all sample rates × attempts
are exhausted, `setFailedToInitRecording(true)` is set and `build()` returns `null`.

**Effective buffer size = `max(131072, AudioRecord.getMinBufferSize(sampleRate, MONO, PCM_16BIT))`.**

### 1.3 Consumer architecture

`AudioRecorder` owns a list of `ConsumerHolder`s (`consumers`). Each consumer declares the sample
rate it wants (`addConsumer(consumer, sampleRate)`); the recorder opens only the consumers whose
requested rate matches the recorder's actual rate. Known consumers:

| Consumer | Role |
|---|---|
| `RecordingAudioConsumer` | writes raw PCM to disk (sleep-talk / snore recording) |
| `SnoringDetectionAudioConsumer` | snore event detection |
| `SoundDetectionAudioConsumer` | generic sound-event detection |
| `TensorflowAudioConsumerV3` | legacy TF sound classifier |
| `TensorflowAudioConsumerV4` | current TF sound classifier |
| `NoiseLevelRecorder` | RMS noise level over time (room-noise stats) |

Pause/resume is reference-counted via `activePauseReasons: Set<PauseReason>` with a `ReentrantLock`
(`pauseLock`) and a separate `recorderLock` guarding the `AtomicReference<AudioRecord>`.

---

## 2. Sound classification (TFLite)

### 2.1 Model

`Classifier` holds `tfLiteClassifier: com.urbandroid.sleep.snoring.classifier.tfv4.TFLClassifier_10s_lmsd2_5cat`.

* **10 s** analysis window
* **lmsd2** — Log-Mel Spectrogram, 2-dimensional (delta features)
* **5 cat** — 5 output categories

Shipped model files (from `assets/`):

| File | Purpose |
|---|---|
| `v4_model.q.tflite` | current 5-class classifier |
| `v3_snore.q.tflite` | v3 snore |
| `v3_baby.q.tflite` | v3 baby crying |
| `v3_laugh.q.tflite` | v3 laughter |
| `v3_sick.q.tflite` | v3 sickness |
| `v3_talk.q.tflite` | v3 talking |
| `cnn_mfcc_old.tflite` | legacy CNN MFCC model |

### 2.2 `SoundClass` enum — exact labels

| Ordinal | Name | `intLabel` | `charLabel` |
|---|---|---|---|
| 0 | `OTHER` | 0 | `0x20` (space) |
| 1 | `SNORE` | 1 | `0x77` (`w`) |
| 2 | `TALK` | 2 | `0x6f` (`o`) |
| 3 | `COUGH` | 3 | `0x78` (`x`) |
| 4 | `BABY` | 4 | `0x3d` (`=`) |
| 5 | `LAUGH` | 5 | `0x5e` (`^`) |

`charLabel` is a compact single-character glyph used where horizontal space is tight.

### 2.3 Per-class confidence handling

`Classifier` carries one Kotlin `Function1<Float, Boolean>` handler per class:

```java
handleBaby:  (Float) -> Boolean
handleLaugh: (Float) -> Boolean
handleSick:  (Float) -> Boolean
handleSnore: (Float) -> Boolean
handleTalk:  (Float) -> Boolean
noiseMixin:  boolean
```

`classify(SafeChunksBuffer): Set<SoundClass>` returns the set of classes whose confidence passes that
class's handler threshold. The exact threshold values live in the handler lambdas and were **not**
extracted — see UNKNOWNS.

---

## 3. Sleep Regularity Index (SRI) — fully decoded

Class: `com.urbandroid.sleep.addon.stats.model.socialjetlag.SleepRegularityIndexUtil2`
(there is also an inner `SplitIndexCandidate`).

### 3.1 Construction

```java
public SleepRegularityIndexUtil2(List<? extends SleepRecord> list) {
    // 1. endTime = end of the UTC day AFTER the latest record
    long toTime = <max of record.getToTime()>;
    Calendar calendar = Calendar.getInstance(this.UTC);
    calendar.setTimeInMillis(toTime);
    calendar.add(5, 1);                       // Calendar.DAY = 5, +1 day
    this.endTime = DateUtil.getDayEnd(calendar.getTimeInMillis(), this.UTC);

    // 2. bitSet: one bit per minute, counted BACKWARDS from endTime.
    //    bit = 1 means "asleep"
    for (SleepRecord sleepRecord : list2) {
        int index  = getIndex(this.endTime, sleepRecord.getToTime());
        int index2 = getIndex(this.endTime, sleepRecord.getFromTime());
        this.bitSet.set(index, index2, true);
        // 3. clear the awake intervals
        for (EventInterval eventInterval : EventsUtil.getEventIntervals(
                sleepRecord.getEvents().getCopiedEvents(),
                EventLabel.AWAKE_START, EventLabel.AWAKE_END)) {
            this.bitSet.set(getIndex(this.endTime, eventInterval.toInterval().getTo()),
                            getIndex(this.endTime, eventInterval.toInterval().getFrom()),
                            false);
        }
    }

    // 4. choose the best "split index": the minute-of-day at which sleep most often splits
    long midDay = DateUtil.getMidDay(this.endTime, TimeZone.getDefault());
    midDay = midDay > this.endTime ? midDay - TimeChart.DAY : midDay;
    for (int hours : IntRange(-10, 10)) {                 // 21 candidates: midday ± 10 h
        int index3 = getIndex(this.endTime, (hours * 3600000L) + midDay);
        if (index3 >= 0) {
            arrayList.add(new SplitIndexCandidate(index3,
                    numberOfSplits(this.bitSet, index3),   // how many days split at this time
                    Math.abs(hours)));                      // tie-break: closest to midday
        }
    }
    // sort by splits DESC, then distance ASC; take the first
    this.splitIndex = first(sortedWith(arrayList, cmp)).getIndex();
}
```

### 3.2 Helpers

```java
private final int getIndex(long endTime, long currentTime) {
    return (int) ((endTime - currentTime) / 60000);          // minutes, counting backwards
}

private final int numberOfSplits(BitSet bitSet, int startSplitIndex) {
    int i = 0;
    while (startSplitIndex < bitSet.size()) {
        if (bitSet.get(startSplitIndex)) i++;
        startSplitIndex += 1440;                              // 1440 min = 1 day
    }
    return i;
}
```

### 3.3 Scoring — `fillSleepRegularityIndex(StatRecord)`

```java
int index = getIndex(this.endTime, record.getToDate().getTime());
int i  = index - ((index - this.splitIndex) % 1440);   // start of the record's 24 h window
int i2 = i  + 1440;
int i3 = i  + 2880;
BitSet bitSet  = this.bitSet.get(i,  i2);              // day A (1440 minutes)
BitSet bitSet2 = this.bitSet.get(i2, i3);              // day B (1440 minutes)
if (bitSet.cardinality() != 0 && bitSet2.cardinality() != 0) {
    bitSet.xor(bitSet2);
    record.setIrregularityIndex(1.0f - (bitSet.cardinality() / 1440.0f));
    return;
}
record.setIrregularityIndex(-1.0f);                    // insufficient data
```

### 3.4 Reimplementable pseudocode

```
SRI(record):
    windowStart = recordEndIndex - ((recordEndIndex - splitIndex) mod 1440)
    dayA = bits[windowStart .. windowStart+1440)
    dayB = bits[windowStart+1440 .. windowStart+2880)
    if dayA is empty or dayB is empty: return -1.0
    differing = popcount(dayA XOR dayB)
    return 1.0 - differing / 1440.0
```

Interpretation: `1.0` = the sleep/wake pattern is identical on both days; `0.0` = the two days are
completely complementary. The `splitIndex` is chosen to maximise how often sleep actually splits at
that time of day, which is what makes the metric sensitive to a *shift* in bed/wake time rather
than merely to total duration.

**Split index selection** — scan 21 candidate times (midday ± 10 h in 1 h steps); for each, count how
many distinct days contain a sleep split at that time; pick the candidate with the highest count,
breaking ties toward midday.

---

## 4. Chronotype

`com.urbandroid.sleep.service.CalculateChronotypeService` is a `WorkManager` job with two constants:

| Field | Purpose |
|---|---|
| `CALCULATE_CHRONOTYPE_INTERVAL: int` | re-computation period |
| `CALCULATE_CHRONOTYPE_WHEN_MIN_RECORDS: int` | minimum sleep records before computing |

The underlying model is `com.urbandroid.sleep.addon.stats.model.socialjetlag.ChronoRecord` /
`ChronoRecords`, clustered by `KMeansPlusPlusClusterer` into `ChronoRecordClusterable` /
`ClusteredChronoRecords`, with `CoreAndOutliers` separating typical from atypical days and
`SleepLabel` naming each cluster. `PopulationChronoStats` and `SocialJetlagStats` consume the result.

**Not yet extracted:** the exact interval and min-record values, and the cluster→chronotype label
mapping. See UNKNOWNS.

---

## 5. Statistics measure catalogue

`com.urbandroid.sleep.addon.stats.model.extractor.*` implements one `IValueExtractor` per measure.
Observed extractors (each computes one statistic over a set of `SleepRecord`s):

`AwakeExtractor`, `AwakeMinutesToHourExtractor`, `BedtimeHourExtractor`, `CyclesExtractor`,
`DeepSleepExtractor`, `DeepSleepFloatExtractor`, `DeepSleepLengthExtractor`, `DeepSleepTrendExtractor`,
`DeficitExtractor`, `DeficitMinutesToHourExtractor`, `DurationExtractor`,
`DurationMinutesToHourExtractor`, `EfficiencyExtractor`, `EfficiencyPercentageExtractor`,
`FallAsleepHourExtractor`, `FallAsleepMinutesExtractor`, `HrExtractor`, `HrvAfterExtractor`,
`HrvBeforeExtractor`, `HrvExtractor`, `HrvGainExtractor`, `IrregularityExtractor`,
`IrregularityIndexChartExtractor`, `IrregularityMinutesToHourExtractor`, `MinHrExtractor`,
`NoiseLevelExtractor`, `RatingExtractor`, `RatingStarExtractor`, `RdiExtractor`,
`RegularityIndexExtractor`, `RegularityIndexGoalExtractor`, `SmartExtractor`, `SnoozeExtractor`,
`SnoringExtractor`, `SnoringMinutesToHourExtractor`, `SnoringPercentageExtractor`,
`SnoringPercentageFloatExtractor`, `WakeUpHourExtractor`, `StaticValueExtractor`.

Supporting machinery:

* **Aggregators** — `MeasureAverageAggregator`, `MeasureListAggregator`,
  `SleepIrregularityMeasureAggregator`, `SocialJetLagMeasureAggregator`, `TagAggregator`,
  `PeriodAggregators`.
* **Collectors** — `Average`, `AverageStatRecord`, `BeforeMidnightCollector`, `DurationCollector`,
  `SemanticCollector`, `TagMapStatRecord`, `WeekdayCollector`, `WeightedAverage`.
* **Mergers** — `AbstractMerger`, `SameDateMerger`, `ShortGapMerger`.
* **Filters** — `AcceptAllFilter`, `TagFilter`, `WeekdaysFilter`, `WeekendFilter`, `FilterFactory`.
* **Charts** — 30+ `ChartBuilder` subclasses (`DeepSleepChartBuilder`, `DebtChartBuilder`,
  `ChronotypeBarChartBuilder`, `SocialJetlagBarChartBuilder`, `SleepScoreChartBuilder`,
  `SnoringChartBuilder`, `GoalChartBuilder`, …) driven by `ChartFactory`.
* **Regression** — `RegressionCollector`, `Point`, `PointSeries`.
* **Clustering** — `KMeansPlusPlusClusterer` with `DoubleFunction`, `ChronoRecordClusterable`.

---

## 6. UNKNOWNS

- The exact confidence threshold per sound class (held in the `handle*` lambdas of `Classifier`).
- `CALCULATE_CHRONOTYPE_INTERVAL` and `CALCULATE_CHRONOTYPE_WHEN_MIN_RECORDS` literal values.
- The cluster→chronotype-label mapping inside `KMeansPlusPlusClusterer` / `SleepLabel`.
- `SonarConfig.RECORDING_INPUT` value (the `AudioRecord` source constant).
- The `NoiseLevelRecorder` RMS window and the `UltrasoundPlayer` frequency.
- Whether the v4 classifier's thresholds differ from v3's.

---

## 7. Reimplementation notes for this project

1. **Mono, 16-bit PCM at 48 kHz** (fallback 44.1 kHz) is sufficient for snore/baby/talk detection —
   no stereo needed. The 128 KiB buffer floor is generous; a 32 KiB buffer works on modern devices.
2. The SRI implementation is self-contained and cheap: one `BitSet` of ~1 bit/minute across the
   record history, plus a per-record XOR over two 1440-bit slices. Directly portable to Dart with a
   `List<bool>` or `BitSet`-like structure.
3. A 5-class audio classifier is a large piece of work: it needs a TFLite model, a log-mel
   spectrogram implementation (FFT → mel filterbank → log), and per-class thresholds. The original
   `.tflite` files are **Urbandroid's assets and must not be copied**. Train an equivalent model on
   a public snoring/baby/talking dataset, or start with energy-band heuristics for snore detection.
