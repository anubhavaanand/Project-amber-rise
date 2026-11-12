# Reverse-engineering reference: Sleep as Android

Specs extracted from **Sleep as Android** by Urbandroid — package `com.urbandroid.sleep`,
production build `20261016` (versionCode `2311729`), `minSdk 24` / `targetSdk 36`.

## Provenance

| | |
|---|---|
| Source | `https://sleep.urbandroid.org/wp-content/uploads/release/Sleep-20261016-prod-release.apk` (the developer's own download page) |
| SHA-256 | `e1dc93bfe9541a64f24230637a1dfb0ed2fb72675ae0c15c867f1c9208fd86cf` |
| Signature | `CN=Petr Nalevka, OU=Urbandroid, O=Urbandroid, L=Prague, ST=Czech Republic, C=CZ` — cert SHA-256 `2f84fb3c3a39caf201a11154037b50d32c05a4c118b8f139f9c79c15fbd55482` |
| Verification | Re-download reproduces the identical digest; `apksigner verify` reports **Verifies** (APK Signature Scheme v2); the app's own bundled `assets/release-notes` lists `20261016` as its newest entry, matching `versionName` exactly |
| Tooling | REA MCP (`rea-agents` 6.7.0) with `jadx-headless-mcp` 0.7.1, apktool 2.11.1 |

The APK was **never executed**. Everything below is static analysis of the shipped artifact.

## Contents

| File | What it covers |
|---|---|
| [`01-sleep-detection.md`](01-sleep-detection.md) | Accelerometer → activity classification → deep/light sleep phase. Exact thresholds, window sizes, the adaptive normalization filter, the hypnogram, and REM detection. |
| [`02-alarm-engine.md`](02-alarm-engine.md) | Alarm scheduling via `AlarmManager`, the alarm data model, the gentle-volume curve, the klaxon, the dismiss/unlock flow, backup/bedtime/jet-lag alarms, post-boot rescheduling. |
| [`03-captcha-system.md`](03-captcha-system.md) | The 17 CAPTCHA types, the difficulty model, anti-cheating protection, wake-up check, captcha selection. |
| [`04-features-surface.md`](04-features-surface.md) | Component map, the 42 settings screens, the full permission comparison against this project, and the complete feature inventory. |
| [`05-gap-analysis.md`](05-gap-analysis.md) | Feature-by-feature gap between this project and the target, plus the implementation order. |
| [`06-audio-and-analytics.md`](06-audio-and-analytics.md) | Audio capture pipeline, TFLite sound classification, the Sleep Regularity Index algorithm, chronotype, the statistics measure catalogue. |
| [`settings-keys.json`](settings-keys.json) | Every preference key found in `res/xml/settings_*.xml` and `alarm_prefs*.xml`. |

## Conventions used in these documents

- **Verbatim decompiled snippets** are shown in fenced code blocks with the originating class named.
- **INFERRED** marks a conclusion that follows from the code but was not directly observed.
- **UNKNOWN** marks something that could not be determined. Numbers are never invented — if a
  constant was not recovered, the document says so instead of guessing.
- Kotlin `object`/`$r8$lambda` names are jadx's own artefacts; the original Kotlin source names
  are preserved in the comments where recoverable.

## Licensing note

These documents describe *observable behaviour* of a proprietary application. They are a
specification, not source code. Any implementation derived from them must be original work, and
must not copy Urbandroid's assets (Lottie animations, `.tflite` sound models, icons, the
`agent_sheep` web game) or their proprietary algorithms verbatim.
