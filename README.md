<div align="center">

<img src="docs/brand/sunrise-bar.svg" alt="" width="360" />

# Rise

### The alarm clock that makes sure you're actually awake.

<sub>Deep black. One warm accent. No five more minutes.</sub>

&nbsp;

![Android](https://img.shields.io/badge/Android_8.0%2B-070A0E?style=for-the-badge&logo=android&logoColor=FFB347&labelColor=070A0E)
![Flutter](https://img.shields.io/badge/Flutter_3.50-070A0E?style=for-the-badge&logo=flutter&logoColor=FFB347&labelColor=070A0E)
![Kotlin](https://img.shields.io/badge/Kotlin-070A0E?style=for-the-badge&logo=kotlin&logoColor=FFB347&labelColor=070A0E)
![License](https://img.shields.io/badge/Noncommercial-070A0E?style=for-the-badge&logoColor=FFB347&labelColor=070A0E)

</div>

---

Rise is an Android alarm app built around one idea: the alarm is only useful if you are actually
awake when it goes off. So it pairs an unkillable native alarm with wake-up missions, sleep-phase
detection, and a morning check-up that catches you if you drifted back off.

Built for three kinds of people, from one codebase:

| Persona | What they need | What Rise gives them |
|---|---|---|
| **Students** | Sleep debt, late nights, early lectures, naps between classes | Nap timer, sleep-debt tracking, bedtime nudges, gentle wake |
| **9-to-6 workers** | A fixed schedule they cannot move, and mornings that do not wreck them | Smart wake-up inside a window, backup alarm, no-oversleep guarantee |
| **ADHD-friendly** | Low-friction starts, external structure, no decision fatigue in the morning | Persona presets, routine checklists, adaptive mission difficulty, streaks |

The persona layer is a **preset**, not a fork. All three share one alarm engine, one tracking
pipeline, one stats model — what changes is default times, which missions are enabled, copy tone,
and how much friction the morning routine adds.

---

## Status

Rise is early. The foundation is real; most features are not built yet.

| Layer | State |
|---|---|
| Build | ✅ Compiles, 16/16 tests pass, 0 analyzer errors |
| Native alarm pipeline | ✅ `AlarmManager.setAlarmClock`, foreground service, wake lock, boot rescheduling, full-screen intent |
| Gentle volume ramp | ✅ Logarithmic gain ramp, ported from a reference implementation |
| Sleep-phase detector | ✅ Algorithm implemented and unit-tested; **not yet connected to the alarm** |
| Wake-up missions | 🟡 8 of ~17 exist, difficulty is flat and not per-mission |
| Sleep tracking | 🟡 Basic accelerometer tracking; no hypnogram, no REM, no adaptive normalisation |
| Stats & insights | 🟡 Partial; no sleep score, chronotype, debt model or regularity index |
| Wake-up check | ❌ Column exists, no behaviour |
| Anti-oversleep protection | ❌ Not implemented |
| Wearables, integrations, cloud | ❌ Deferred by design (see `docs/reverse-engineering/07-deferred.md`) |

See `docs/reverse-engineering/05-gap-analysis.md` for the full 66-row feature matrix.

---

## Getting started

### Prerequisites

- Flutter 3.50+ (stable)
- JDK 21
- Android SDK Platform 36 + Build-Tools 36

### Setup

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs   # required: Isar codegen
flutter analyze
flutter test
```

The `build_runner` step is **not optional**. The Isar `.g.dart` files are gitignored, so a fresh
clone will not compile until you run it.

### Run

```bash
flutter run                      # debug on a connected device
flutter build apk --debug        # verify a full Android build
```

### Verify the alarm actually works

These are the tests that matter, and they need a real device:

1. **Doze** — set an alarm 2 minutes out, enable airplane mode, lock the phone, wait.
2. **Force-kill** — set an alarm, force-stop the app from Settings, confirm it still rings.
3. **Reboot** — set an alarm, reboot, confirm it is rescheduled and still rings.
4. **Low battery** — repeat at under 15% with battery saver on.

An emulator cannot reproduce Doze or force-kill behaviour, so these only count on hardware.

---

## Project layout

```
lib/
  main.dart                      App entry, theme, routing
  models/
    alarm.dart                   Isar alarm schema + MissionType enum
    alarm_stats.dart             Derived statistics
    sleep_record.dart            Sleep session record
  services/
    alarm_service.dart           Dart side of the native alarm bridge
    notification_service.dart    Notification channels
    sleep_phase_detector.dart    Deep/light sleep classification (ported algorithm)
    sleep_tracking_service.dart  Accelerometer tracking session
  screens/                       Home, edit, ring, tracking, stats, settings, sleep history
  missions/                      The 8 wake-up missions

android/app/src/main/kotlin/com/rise/app/
  MainActivity.kt                MethodChannel bridge
  AlarmReceiver.kt               AlarmManager entry point + AlarmScheduler
  AlarmService.kt                Foreground service: sound, vibration, volume ramp
  AlarmRingActivity.kt           Full-screen alarm overlay
  BootReceiver.kt                Reschedules after reboot

docs/reverse-engineering/        Behavioural specs for the reference implementation
test/                            Unit and widget tests
```

---

## Design notes

- **Native-first alarm.** The alarm is scheduled with `setAlarmClock()`, the only `AlarmManager` API
  that reliably wakes a device out of Doze. The foreground service and wake lock keep it ringing
  after the app is killed.
- **Volume is a gain curve, not a stream ramp.** The alarm stream is pinned to maximum immediately;
  perceived loudness comes from a logarithmic `MediaPlayer` gain, so the alarm starts effectively
  silent and rises evenly.
- **Missions are gates, not decoration.** The alarm cannot be dismissed until the mission reports
  success.
- **Personas are data.** Niche behaviour lives in presets, never in branches of the core.

## Documentation

`docs/reverse-engineering/` documents how the reference implementation behaves, with exact
constants and evidence trails. It is a specification, not source code — see the licensing note in
that directory's `README.md`.

## License

PolyForm Noncommercial 1.0.0 — free for noncommercial use, including by students and for personal
projects. **Commercial use requires a separate license.** See [LICENSE](LICENSE).

## Contributing

Bug reports and pull requests are welcome. Keep changes surgical: one concern per change, and run
`flutter analyze` and `flutter test` before opening a PR.