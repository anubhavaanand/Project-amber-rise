# Gap Analysis — `wake_me_up_pro` (this project) vs. Sleep as Android 20261016

Target analyzed: `com.urbandroid.sleep` v20261016 (versionCode 2311729)
SHA-256 `e1dc93bfe9541a64f24230637a1dfb0ed2fb72675ae0c15c867f1c9208fd86cf`

This project as of commit `3233cea`: 8,373 lines Dart + 664 lines Kotlin, 8 missions, Isar DB, native alarm pipeline.

---

## 0. Build status (measured, not assumed)

| Check | Before | After |
|---|---|---|
| `flutter pub get` | OK | OK |
| `flutter pub run build_runner build` | OK (10 outputs; Isar `.g.dart` regenerated) | OK |
| `flutter analyze` | **5 errors** | **0 errors** (178 lints) |
| `flutter test` | 10/10 | **16/16** |
| `flutter build apk --debug` | **FAILED** (AGP/Kotlin incompatibility) | **OK — 207 MB `app-debug.apk`** |

### Blocker 1 — the app did not compile (fixed)

`lib/main.dart:190-191` referenced `CupertinoPageTransitionsBuilder` without importing
`package:flutter/cupertino.dart`. That symbol lives in `src/cupertino/route.dart`, exported
only by `cupertino.dart` — `material.dart` does not re-export it. Five analyzer errors
(`undefined_method`, `invalid_constant`, `non_constant_map_value`) made the app **not compile**.

Fix applied (1 line):

```dart
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
```

`show` is used deliberately: `cupertino.dart` also exports symbols that would shadow Material ones.

### Blocker 2 — the Android build failed on Flutter 3.50 (fixed)

```
⛔ Android Gradle Plugin Version Incompatible with Kotlin Gradle Plugin
The applied Android Gradle Plugin version (8.5.0) is lower than the minimum supported 8.5.2.
```

The project was on AGP 8.5.0 / Gradle 8.7 / Kotlin 2.0.21. Flutter 3.50 requires
AGP ≥ 9.1.1, Gradle ≥ 9.3.1, KGP ≥ 2.4.10, and its template relies on AGP 9's built-in Kotlin
(`android.builtInKotlin=false` means *Flutter* applies the Kotlin plugin, so the app module must
not also declare `id("kotlin-android")`).

Migration applied, matching Flutter 3.50's own template:

| File | Change |
|---|---|
| `android/settings.gradle.kts` | AGP `8.5.0` → `9.3.1`; Kotlin `2.0.21` → `2.4.20` |
| `android/gradle/wrapper/gradle-wrapper.properties` | Gradle `8.7` → `9.5.0` |
| `android/app/build.gradle.kts` | dropped `id("kotlin-android")`; `kotlinOptions {}` → `kotlin { compilerOptions { jvmTarget = JVM_17 } }` |
| `android/gradle.properties` | recreated with `android.useAndroidX=true` + JVM args (see blocker 3) |
| `.gitignore` | stopped ignoring `/android/gradle.properties` (see blocker 3) |

### Blocker 3 — a fresh clone could not build at all (fixed)

`/android/gradle.properties` was listed in `.gitignore` (line 131), so it was **not tracked in git**.
A fresh clone therefore had no `android.useAndroidX=true` and no JVM args. Flutter's migrator
recreated the file on this machine with only the two migration flags appended, silently dropping
`android.useAndroidX=true` — which is mandatory for an AndroidX-based Flutter app.

Fix: the file is now tracked and contains the values from Flutter's template.

### Non-blocking issues found

- **`.g.dart` files are gitignored** (`.gitignore:141` `*.g.dart`, `.gitignore:257` `lib/**/*.g.dart`).
  A fresh clone cannot build without running `build_runner` first. CI works around this
  (commit `b90a966`) but a developer cloning locally hits a wall. *Recommendation: commit the
  generated files, or add a `make setup` / `just` target.*
- `assets/images/` is **empty** but declared in `pubspec.yaml`.
- `README.md` and `ARCHITECTURE.md` describe files that **do not exist**: `AlarmScheduler.kt`,
  `AlarmProvider`, `AlarmRingScreen` mission flow descriptions, `MemoryGame`/`Barcode` etc.
  `AlarmScheduler` actually lives inside `AlarmReceiver.kt` as an `object`. *Docs are aspirational —
  they should be corrected or the code completed.*
- Release build signs with the **debug key** (`android/app/build.gradle.kts:37`, marked TODO).
- The APK was verified by extracting it and confirming the new code is present:
  `Gentle volume ramp started`, `AlarmVolumeRamp`, `gentle_duration_ms` in the DEX, and
  `gentleEnabled` / `gentleDurationMs` in `assets/flutter_assets/kernel_blob.bin`.

---

## 0b. Changes implemented as part of this work

### P2 — Gentle volume ramp (**DONE**)

Before: `AlarmService` ramped the **system stream** linearly over 10 steps in 30 s, starting at
30% of max. The alarm was audibly loud from the first second and the ramp was not user-configurable.

After: ported from Sleep as Android's `GentleAlarmRunnable` (see
[`02-alarm-engine.md`](02-alarm-engine.md) §6.2). The system stream is set to **max** immediately
and the *MediaPlayer gain* is ramped logarithmically:

```
gain(v) = 1 - ln(100 - v) / ln(100)      for v < 100, else 1.0
tick    = durationMs / 100 ms           (one volume unit per tick)
```

Sample gains: v=0 → 0.000, v=10 → 0.023, v=50 → 0.151, v=75 → 0.301, v=90 → 0.500, v=99 → 1.000.

The ramp now honours the per-alarm `gentleWakeEnabled` / `gentleWakeDurationSeconds` settings,
which are carried Dart → MethodChannel → `AlarmScheduler` → `AlarmReceiver` → `AlarmService` via
two new extras (`gentle_enabled`, `gentle_duration_ms`).

### P1 — Smart alarm detector (**algorithm ported, not yet wired**)

`lib/services/sleep_phase_detector.dart` implements the reversed `DeepSleepDetectorV8` pipeline:

- movement baseline = median of the last 6 points (60 s)
- deviation = |raw − baseline|, normalized by the 2 h median
- scaling maximum = 99.5th percentile of the last 720 points, floored at 100 for the first hour
- `v = min(max, x) ^ (1 / log10(max))`; `isSomeActivity = v > 2.5`, `isHighActivity = v > 3.3`
- phase = DEEP iff `round(highCount) < 1 && round(someCount) < sensitivityChecks`, over a 6-point
  (1 min) and a 30-point (5 min) sliding window; UNKNOWN for the first 12 points
- missing-data guard: > 90% missing over 5 min resets the detector

Covered by 6 unit tests in `test/sleep_phase_detector_test.dart`.

**Still missing:** the detector is not connected to the alarm flow. It needs a background sensor
service that keeps sampling through the night and can re-trigger the alarm early — that part is
native work and cannot be verified without a device.

### Bug fix — repeat alarms fired immediately after rescheduling

`AlarmService.scheduleAlarm` used `alarm.time.millisecondsSinceEpoch` directly. `alarm.time` is a
**fixed** `DateTime`, so after the first trigger (or after a reboot) the rescheduled trigger time
was in the past and `AlarmManager.setAlarmClock` fired immediately. It now uses
`calculateNextAlarmTime(alarm)` for repeat alarms — that helper already existed but was never used.

---

## 1. Feature-by-feature gap

Status legend: **DONE** = implemented and working · **PARTIAL** = UI/flag exists, logic stubbed ·
**FLAG-ONLY** = a boolean column exists, no behaviour · **MISSING** = absent

### 1.1 Alarm core

| Feature | Target | This project | Gap |
|---|---|---|---|
| Exact alarm scheduling | `setAlarmClock()` + `AlarmClockInfo` | `setAlarmClock()` in `AlarmReceiver.kt:116` | **DONE** — but no separate `showIntent`, so the alarm is not rendered as a system alarm card |
| Repeat days | yes | `repeatDays: List<int>` (0=Mon) | **DONE** |
| Skip next alarm | yes (`SkipNextAlarmActivity`) | `skipCount` counter only | **MISSING** — no real skip-next-once |
| Adjust next time / offset | yes (`alarm_offset_title`) | none | **MISSING** |
| Backup alarm (after timeout) | yes (`settings_backup_alarm.xml`) | none | **MISSING** |
| Bedtime alarm (sleep-window) | yes (`SetAlarmBedtime`, `BedtimeReceiver`) | `isNapAlarm` only | **MISSING** |
| Jet-lag alarm | yes (`SetAlarmJetLag`, `JetLagPreviewActivity`) | none | **MISSING** |
| Nap alarm | yes | `Alarm.createNap` + `isNapAlarm` | **DONE** |
| Alarm timeout | yes (`alarm_kill_time_summary`) | none | **MISSING** |
| Sound delay after trigger | yes (`alarm_sound_delay`) | none | **MISSING** |
| Sleep-alarm dismissal flow | `UnlockFlow` + `CaptchaCallbackReceiver` | `AlarmRingScreen` + mission widget | **PARTIAL** |
| Alarms-only mode | yes (`settings_simple_alarm_only.xml`) | none | **MISSING** |
| Morning screen / briefing | yes (`MorningActivity`, `morning_briefing`) | none | **MISSING** |
| Notification channel per alarm | yes (`notification_channel`) | `notification_service.dart` | **PARTIAL** |

### 1.2 Volume / audio engine

| Feature | Target | This project | Gap |
|---|---|---|---|
| Gentle volume ramp | `GentleAlarmRunnable` + `VolumeControlRunnable` | `gentleWakeEnabled` + `gentleWakeDurationSeconds` | **FLAG-ONLY** — no ramp code exists |
| Lullaby volume down on dismiss | `LullabyVolumeDown` | none | **MISSING** |
| Lullaby playlist engine | `LullabyService`, `LullabyActivity` | none | **MISSING** |
| Binaural beats | yes (`binaural_alarm_title`) | none | **MISSING** |
| Online radio alarm | yes | none | **MISSING** |
| Spotify alarm | yes (`SpotifyManagerAuthActivity`) | `spotifyPlaylistUri` column | **FLAG-ONLY** |
| Flashlight wake-up | yes (`alarm_with_flashlight_title`) | none | **MISSING** |
| Sleep sound recording | `AudioRecorder`, `RecordingAudioConsumer` | none | **MISSING** |
| Snoring detection | `SnoringDetectionAudioConsumer` + TFLite | none | **MISSING** |
| TFLite sound classification | 6 models shipped | none | **MISSING** |
| Anti-snoring | `anti-snoring` | none | **MISSING** |

### 1.3 Sleep detection & smart wake-up  ← highest-value gap

| Feature | Target | This project | Gap |
|---|---|---|---|
| Actigraph sampling | `AccelSleepRecorder` | `sensors_plus` accelerometer | **DONE** (basic) |
| Movement classification | `IActivityAggregator.Result.isHighActivity/isSomeActivity` | thresholds `_awakeThreshold=1.5`, `_lightSleepThreshold=0.8`, `_remSleepThreshold=0.3`, `_stationaryThreshold=0.05` | **PARTIAL** — single magnitude threshold, no high/some activity split, no dual sliding windows |
| Deep sleep detector | `DeepSleepDetectorV8` (dual window, 12-pt warmup, missing-data guard) | inline magnitude compare | **PARTIAL** |
| Smart wake-up | `DeepSleepDetector` + windowed early trigger | `smartAlarmEnabled` + `smartAlarmWindowMinutes` | **FLAG-ONLY** — no early trigger exists; the alarm always fires at the exact time |
| Adaptive normalization | `AdaptiveNormalizationFilter` | none | **MISSING** |
| REM detection | `RemDetectorV1/V2` | `_remSleepThreshold` | **PARTIAL** |
| Hypnogram | `SleepRecordHypnogram` | `_addPhase` | **PARTIAL** |
| Awake detection (post-dismiss) | `awake` settings, sensitivity levels | `wakeUpCheckEnabled` column | **FLAG-ONLY** |
| Automatic tracking | `AutoTrackingService`, `AutoTrackingProcessor` | `_isAutoTracking` + `_startAutoDetection` | **PARTIAL** |
| Pair tracking | `settings_pair.xml` | none | **MISSING** |
| Sonar (contactless) tracking | `sensor_sonar` | none | **MISSING** |

### 1.4 CAPTCHA / missions

Target ships **17 captcha types**. This project ships **8 missions**.

| Target captcha | This project | Note |
|---|---|---|
| Simple math | `math_mission.dart` | present |
| Typed math | `typing_mission.dart` | present (different: types a sentence) |
| Shake it | `shake_mission.dart` | present |
| QR / Barcode | `barcode_mission.dart` | present, but no *registration/learning* flow and no "scan all codes" rule |
| Zombie walk | `walking_mission.dart` | partial analogue (step count) |
| Memoji | `memory_mission.dart` | partial analogue (memory game) |
| Dream diary, Smile, NFC tag, Let there be light, Wake the droid, Maze, Agent sheep, Sleeping sheep, Laugh Out Loud, Flags | — | **MISSING** (10) |
| Difficulty model | per-captcha thresholds | flat `missionDifficulty: 1-5` passed to each mission | **PARTIAL** — no per-captcha difficulty mapping |
| No-cheating protection | device-admin + overlay + accessibility lock | `captchaRequired` column | **FLAG-ONLY** |
| Wake-up check (confirm after N min) | `CaptchaWakeUpCheckSettingsActivity` | `wakeUpCheckEnabled` column | **FLAG-ONLY** |
| CAPTCHA store / addon packs | `CaptchaPack` addons | none | **MISSING** |

### 1.5 Health & analytics

| Feature | Target | This project | Gap |
|---|---|---|---|
| Heart rate + HRV | `HrReceiver`, `apnea.HrAlarmDetector` | none | **MISSING** — needs `BODY_SENSORS` + wearable |
| Apnea / SpO2 / breath rate | `ApneaReceiver`, `WeirdSpo2Guard` | none | **MISSING** |
| Chronotype | `CalculateChronotypeService`, `ChronoRecord` | none | **MISSING** |
| Social jetlag | `SocialJetlagStats` + K-means clustering | none | **MISSING** |
| Sleep regularity index | `SleepRegularityIndexUtil2` | none | **MISSING** |
| Sleep debt / deficit | `DeficitExtractor` | `alarm_stats.dart` (partial) | **PARTIAL** |
| Sleep score | `SleepScore`, `ScoreAiPrompt` | `alarm_stats.dart` (partial) | **PARTIAL** |
| Graph & charts | 30+ `ChartBuilder` classes | `stats_screen.dart` | **PARTIAL** |
| Goals with refundable deposit | `GoalCreateActivity`, `startWagerRefundFlow` | none | **MISSING** |
| Achievements | `achievement.*` | none | **MISSING** |
| Tags / ratings | `domain.tag.*` | none | **MISSING** |
| AI morning briefing | `ai.AiActivity`, `ScoreAiPrompt` | none | **MISSING** |

### 1.6 Integrations & platform

| Feature | Target | This project | Gap |
|---|---|---|---|
| Google Fit / Health Connect | yes | none | **MISSING** |
| Google Calendar alarms | yes | none | **MISSING** |
| Wearables (Pebble/Wear/Fitbit/Garmin/Zepp/Samsung) | yes | none | **MISSING** |
| Philips Hue smartlight | yes | none | **MISSING** |
| Tasker / IFTTT / webhooks / MQTT | yes | none | **MISSING** |
| App Actions (Assistant) | yes | none | **MISSING** |
| App widgets | 4 (`AlarmWidget`, `SleepWidget`, `GraphWidget`, `DroidWidget`) | none | **MISSING** |
| Quick-settings tile | `SleepTrackTileService` | none | **MISSING** |
| Shortcuts / App Actions intents | `shortcut.*`, `SleepStartAppAction` | none | **MISSING** |
| CSV / ZIP import-export | `ImportCsvActivity`, `ImportZipActivity` | none | **MISSING** |
| Cloud backup / SleepCloud | yes | none | **MISSING** |
| Device-admin no-escape | yes | none | **MISSING** |
| Lucid dreaming | `LucidReceiver` | none | **MISSING** |
| Pair tracking | yes | none | **MISSING** |

---

## 2. The three things that actually matter

Ranked by (impact × feasibility), ignoring integrations that need accounts/hardware:

### P1 — Make the smart alarm real — *algorithm done, wiring outstanding*
`smartAlarmEnabled` is still a lie: the alarm fires at exactly the set time regardless.
The detector is now implemented and tested (§0b), but it needs a native background sensor
service that keeps sampling through the night and can re-trigger the alarm early. That is the
remaining work; the hard part (getting the algorithm right) is done.

### P2 — Implement the gentle volume ramp — **DONE**
Ported from the target's `GentleAlarmRunnable`: the system stream goes to max immediately and the
MediaPlayer gain is ramped logarithmically, honouring the per-alarm settings. See §0b.

### P3 — Implement the wake-up check
`wakeUpCheckEnabled` is a flag. The target re-checks after dismissal. This is the app's core
"unkillable" promise and is currently unimplemented — meaning the project doesn't actually do the
thing it's named for.

---

## 3. Suggested implementation order

| # | Work | Touches | Depends on | Status |
|---|---|---|---|---|
| 1 | Gentle volume ramp | `AlarmService.kt` | — | **done** |
| 2 | Smart alarm: detector algorithm | `lib/services/sleep_phase_detector.dart` | — | **done** |
| 3 | Smart alarm: background sensor service + early wake | new Kotlin service, `AlarmReceiver.kt` | 2 | todo |
| 4 | Wake-up check after dismissal | `alarm_ring_screen.dart`, `alarm_service.dart` | — | todo |
| 5 | Skip-next + adjust-next-time | `alarm_service.dart`, `alarm_edit_screen.dart` | — | todo |
| 6 | Backup alarm (timeout) | `AlarmReceiver.kt` | 1 | todo |
| 7 | Bedtime alarm | new screen + `AlarmReceiver.kt` | 5 | todo |
| 8 | Per-captcha difficulty mapping + QR registration flow | `lib/missions/*` | — | todo |
| 9 | Alarm `showIntent` (system alarm card) | `AlarmReceiver.kt` | — | todo |
| 10 | Chronotype + social jetlag | new service + stats screen | 2 | todo |
| 11 | Health Connect / Google Fit export | new service | 2 | todo |

---

## 4. What was deliberately not attempted

- Copying Urbandroid's **assets** (Lottie animations, TFLite sound models, icons, the `agent_sheep`
  web game). These are copyrighted. A clone must ship original assets.
- Reproducing **proprietary algorithms verbatim** (e.g. their exact `SleepRegularityIndexUtil2`).
  The specs here describe *observable behaviour*; implementations should be independent.
- Cloud sync / SleepCloud / MQTT / Tasker — all need accounts, servers and OAuth apps. These are
  weeks of work each and cannot be verified without live services.

## 5. Open items

- **No physical device is attached** (`adb devices` → empty), so **no runtime verification** of alarm
  behaviour, Doze survival, or the sensor pipeline is possible yet. Every behavioural claim above
  is from static analysis of source, not from observed execution. The next verification step is to
  attach a phone and run the Phase-0 tests in the README (Doze, force-kill, reboot).
- The `flutter_ringtone_player`, `google_mlkit_*` and other plugins still apply KGP directly, which
  Flutter warns will stop working in a future release. They will need a built-in-Kotlin migration.
- `03-captcha-system.md` covers the framework contract, the difficulty model, and 8 of the 17 captcha
  rules with exact thresholds; the remaining 9 are documented structurally with their unknowns listed
  in that file's §8. The anti-cheating and wake-up-check implementations were not decompiled.
- `docs/reverse-engineering/` is new and untracked — it should be committed once reviewed.
- `android/gradle.properties` is newly un-ignored but not yet committed; a fresh clone still lacks it
  until the change is committed.
