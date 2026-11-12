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

The persona layer is a preset, not a fork. All three share one alarm engine, one tracking pipeline,
one stats model — what changes is default times, which missions are enabled, copy tone, and how much
friction the morning routine adds.

## Status

Rise is early. The foundation is real; most features are not built yet.

| Layer | State |
|---|---|
| Build | ✅ Compiles, 36/36 tests pass, 0 analyzer errors |
| Native alarm pipeline | ✅ `AlarmManager.setAlarmClock`, foreground service, wake lock, boot rescheduling, full-screen intent |
| Gentle volume ramp | ✅ Logarithmic gain ramp with a configurable duration |
| Sleep-phase detector | ✅ Implemented and unit-tested; not yet wired to the alarm |
| Night clock | ✅ Bedside clock with dim mode, live hypnogram, pause and stop-and-save |
| Wake-up missions | 🟡 8 exist, difficulty is flat and not per-mission |
| Sleep tracking | 🟡 Basic accelerometer tracking; no hypnogram from history, no REM, no adaptive normalisation |
| Stats & insights | 🟡 Score, streak and averages; no chronotype, debt model or regularity index |
| Wake-up check | ❌ Column exists, no behaviour |
| Anti-oversleep protection | ❌ Not implemented |
| Wearables, integrations, cloud | ❌ Not planned |

## Getting started

### Prerequisites

- Flutter 3.50+ (stable)
- JDK 21
- Android SDK Platform 36 + Build-Tools 36

### Setup

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

The `build_runner` step regenerates the Isar code. Generated files are committed, so a fresh clone
already builds — run it only when you change a schema.

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

## Project layout

```
lib/
  main.dart                      App entry, theme, routing
  theme/app_theme.dart           Colour, type, shape and motion tokens
  models/
    alarm.dart                   Isar alarm schema + MissionType enum
    alarm_stats.dart             Alarm outcome statistics
    sleep_record.dart            Sleep session record
    persona_preset.dart          Persona presets and the friction dial
  services/
    alarm_service.dart           Dart side of the native alarm bridge
    notification_service.dart    Notification channels
    preset_service.dart          Persona persistence
    sleep_phase_detector.dart    Deep/light sleep classification
    sleep_tracking_service.dart  Accelerometer tracking session
  screens/                       Dashboard, alarm editor, night clock, sleep, you, settings
  widgets/                       Hypnogram, wheel time picker, buttons, alarm card
  missions/                      The 8 wake-up missions

android/app/src/main/kotlin/com/rise/app/
  MainActivity.kt                MethodChannel bridge
  AlarmReceiver.kt               AlarmManager entry point + AlarmScheduler
  AlarmService.kt                Foreground service: sound, vibration, volume ramp
  AlarmRingActivity.kt           Full-screen alarm overlay
  SleepTrackingService.kt        Background sleep tracking
  SleepPhaseDetector.kt          Kotlin phase detector
  BootReceiver.kt                Reschedules after reboot
```

## Design notes

**Native-first alarm.** The alarm is scheduled with `setAlarmClock()`, the only `AlarmManager` API
that reliably wakes a device out of Doze. The foreground service and wake lock keep it ringing after
the app is killed.

**Volume is a gain curve, not a stream ramp.** The alarm stream is pinned to maximum immediately;
perceived loudness comes from a logarithmic `MediaPlayer` gain, so the alarm starts effectively
silent and rises evenly.

**Missions are gates, not decoration.** The alarm cannot be dismissed until the mission reports
success.

**Personas are data.** Niche behaviour lives in presets, never in branches of the core.

**The night screen is a bedside clock.** While tracking, the phone sits on the nightstand, so the
screen answers "what time is it" before anything else, and can dim itself so it does not light up a
dark room.

## License

PolyForm Noncommercial 1.0.0 — free for noncommercial use, including by students and for personal
projects. Commercial use requires a separate license. See [LICENSE](LICENSE).

## Contributing

Bug reports and pull requests are welcome. Keep changes surgical: one concern per change, and run
`flutter analyze` and `flutter test` before opening a PR.