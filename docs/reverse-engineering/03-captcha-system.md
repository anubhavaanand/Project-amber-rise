# CAPTCHA / Wake-Up Verification System — Sleep as Android 20261016

Evidence: REA/jadx decompilation of `com.urbandroid.sleep.captcha.*` and
`com.urbandroid.sleep.alarmclock.settings.Captcha*`. All snippets are verbatim decompiled output
unless marked **INFERRED** or **UNKNOWN**.

The APK ships **17 CAPTCHA activities**. Each is an independent wake-up gate: the alarm will not
dismiss until the captcha reports success.

---

## 1. Framework contract

### 1.1 Difficulty

Difficulty is **not** a captcha-specific enum. It is a plain integer carried on the launching intent:

```java
// com.urbandroid.sleep.captcha.AbstractCaptchaSupport
@Override
public int getDifficulty() {
    Intent intent = this.intent;
    if (intent != null) {
        return intent.getIntExtra("difficulty", 1);
    }
    return 1;
}
```

Default **1**, no documented upper bound. Each captcha maps that integer onto its own thresholds
(see §2).

### 1.2 The alarm is passed by value, not by id

```java
// com.urbandroid.sleep.captcha.SleepCallbackIntentCreator.prepareIntent
private Intent prepareIntent(Context context, String operation, boolean solved) {
    boolean noOperation = "no_operation".equals(operation);
    Intent intent = new Intent(context, noOperation ? AlarmAlertFullScreen.class : CaptchaCallbackReceiver.class);
    if (noOperation) {
        intent.addFlags(131072);                       // FLAG_ACTIVITY_CLEAR_TOP
        intent.addFlags(ClientDefaults.MAX_MSG_SIZE);  // 0x10000
    }
    Alarm alarm = this.alarm;
    if (alarm != null) {
        intent.putExtra("intent.extra.alarm_raw", alarm.serializeToArray());
    } else {
        Logger.logWarning("Captcha: No alarm in captcha");
    }
    if (noOperation) {
        intent.putExtra(solved ? "captcha_result_success" : "captcha_result_left", true);
    }
    return intent;
}
```

* `createSolvedIntent(context, operation)` → `prepareIntent(..., true)`
* `createUnsolvedIntent(context, operation)` → `prepareIntent(..., false)`
* The whole `Alarm` is serialised with `Alarm.serializeToArray()` and carried as **`intent.extra.alarm_raw`**
  (a `byte[]`), then re-parsed with `Alarm.parseFromIntent(intent)`.
* Two delivery targets: `CaptchaCallbackReceiver` (normal) or `AlarmAlertFullScreen` with
  `FLAG_ACTIVITY_CLEAR_TOP` (for the `no_operation` variant, i.e. "dismiss without a captcha").

### 1.3 Callback actions

`CaptchaCallbackReceiver` declares three action constants and additionally understands a set of
"answer" extras:

| Action / extra | Effect |
|---|---|
| `CAPTCHA_ACTION_START` | Sets `AlarmAlertFullScreen.CAPTCHA_IN_PROGRESS = true`; broadcasts `CAPTCHA_ACTION_UPDATE` locally |
| `CAPTCHA_ACTION_STOP` | Sets `CAPTCHA_IN_PROGRESS = false`; broadcasts `CAPTCHA_ACTION_UPDATE` locally |
| `CAPTCHA_ACTION_UPDATE` | Local broadcast only (consumed by the UI) |
| `com.urbandroid.sleep.captcha.intent.action.ALIVE` | Heartbeat. If `getCaptchaSuppressMode() > 0` it is re-broadcast as `com.urbandroid.sleep.ACTION_DELAY_RESUMER`; otherwise ignored |
| *(any other action)* | Resets snooze-repeat and stamps `setLastCaptchaSolvedTimestampNow()`, then applies the extras below |
| `snooze_cancel` | `Alarms.saveSnoozeAlert(context, -1, -1L)`, resets wake-up-check repeat, deletes the alarm if self-disposable, cancels its notification, broadcasts `com.urbandroid.sleep.alarmclock.cancel_snooze_finished` |
| `delete_alarm` | Same as above but deletes unconditionally |
| `edit_alarm` | Launches `SetAlarm` with `alarm_id`; adds `set_time_extra` if `edit_alarm_time_extra` is also present |
| `disable_alarm` | `Alarms.enableAlarm(context, id, !enabled)`, cancels notification, broadcasts `cancel_snooze_finished` |
| `should_skip` | `Alarms.skipNextAlarm(context, fromIntent)` |
| `captcha_result_success` / `captcha_result_left` | Set by `SleepCallbackIntentCreator` on the `no_operation` path |

`AbstractCaptchaSupport` also implements a heartbeat/`aliveTimeout` mechanism
(`aliveTimeoutInSeconds`, `lastAliveSent`, `doAlive()`) and a `RemainingTimeListener` so the UI can
count down the time left before the alarm times out.

### 1.4 Result codes

`BaseMathCaptcha.answerProvided` calls `setResult(2)` before `solved()`. The captcha activities use
`RESULT_OK`/`setResult` codes to report back; the exact numeric contract for each captcha was not
fully enumerated — see UNKNOWNS.

---

## 2. Per-captcha reference

### 2.1 Simple math / typed math — *fully decoded*

`BaseMathCaptcha` generates a single arithmetic expression whose answer is always a positive
integer, and the user must solve it `difficulty` times in a row.

```java
// com.urbandroid.sleep.captcha.BaseMathCaptcha.doSetup
private void doSetup() {
    int difficulty = getDifficulty();
    int i = (difficulty * 2) + 6;                    // operand range ceiling
    this.status.x = random.nextInt(i) + 2;           // 2 .. i+1
    this.status.y = random.nextInt(i) + 2;
    this.status.z = random.nextInt(i) + 2;
    this.status.r = difficulty > 2 ? random.nextInt(i) + 2 : 0;
    this.status.s = difficulty > 4 ? random.nextInt(6) + 2 : 1;   // divisor, 2..7
    if (difficulty > 4) this.status.y *= 2;

    if (this.status.r == this.status.z) {
        this.status.z = random.nextInt(i) + 2;
    }
    int answer = (x * y) + z - r;
    int s = this.status.s;
    int zAdjusted = (s - (answer % s)) + z;          // force divisibility
    this.status.z = zAdjusted;
    this.status.correctAnswer = ((x * y) + zAdjusted - r) / s;
    setupValuesExtension(x, y, z, r, s, correctAnswer);
}
```

`setupValues()` retries `doSetup()` until `correctAnswer >= 1`.

**Display format** (`SimpleMathCaptcha.showValues`):

```java
StringBuilder sb = new StringBuilder(i5 != 1 ? "(" : "");   // "(" only if divisor != 1
// -> "x x y"  then append z, then (r != 0 ? "-" + r : ""),
//    then (s != 1 ? ")/" + s : ""), then "=?"
```

i.e. for difficulty ≤ 4 the divisor is 1 and the subtraction is omitted at difficulty ≤ 2, so the
question reads `7 x 8 12=?`. At difficulty > 4 it reads `(7 x 16 12-5)/3=?`.

**Answer checking:**

```java
// com.urbandroid.sleep.captcha.BaseMathCaptcha.answerProvided
if (answer == status.correctAnswer) {
    if (!status.wrong) status.tries++;
    status.wrong = false;
    anim(true);
    // replace "?" with "✔" (or "X" with "✔" when transition animations are off)
    if (status.tries >= getDifficulty()) { setResult(2); solved(); return; }
    setupValues();                       // next problem after 500 ms
    return;
}
// wrong answer:
MaterialAlertDialogBuilder("captcha_failed")  // non-cancelable
textView.startAnimation(buzz);                // shake the question
// replace "?" with "😭" (or "X" when transition animations are off)
status.wrong = true;
if (getDifficulty() <= 2 || getClass() != SimpleMathCaptcha.class || status.tries <= 0) return;
Toast("captcha_oops");                        // "Oops +1x"
status.tries--;                               // penalty: lose one correct answer
setupValues();                                // next problem after 500 ms
```

So: **difficulty = the number of consecutive correct answers required.** Wrong answers at
difficulty > 2 in `SimpleMathCaptcha` cost one already-earned correct answer.

**Wrong-answer options** (`SimpleMathCaptcha.generateAnswerSet`):

```java
HashSet<Integer> set = new HashSet<>();
set.add(correctAnswer);
while (set.size() < numberOfButtons) {
    int candidate = random.nextInt((Math.abs(correctAnswer) * 3) + 17);
    if (correctAnswer < 0) candidate *= -1;
    set.add(candidate);
}
Collections.shuffle(list, random);
```

`TypeMathCaptcha` uses an `EditText` + numeric keypad + submit button instead of buttons, and
overrides `answerProvided(int)` to parse the typed value.

### 2.2 Shake it — *decoded*

```java
// com.urbandroid.sleep.captcha.ShakeItCaptcha.onCreate
int difficulty = getDifficulty();
count = (difficulty == 1) ? 500 : difficulty * 1000;
countStart = count;
```

| Difficulty | Required shake count |
|---|---|
| 1 | **500** |
| 2 | **2000** |
| 3 | **3000** |
| 4 | **4000** |
| … | `difficulty × 1000` |

Progress is cached in `COUNT_CACHE` with a 10 second staleness window, so a configuration change
does not lose progress:

```java
if (COUNT_CACHE_TS == -1 || System.currentTimeMillis() - COUNT_CACHE_TS > 10000) {
    COUNT_CACHE = 0;      // reset cache
}
```

### 2.3 QR / barcode — *structure decoded, thresholds not*

`BaseScanningCaptcha` provides:

* `learn` / configuration mode vs. operational mode (`wasExecutedInLearnMode`, `setLearnedText`)
* `multiscanMode` / `isMultiscanMode` / `addScannedValue` — the "scan all codes" rule
* `homeMode` / `isHomeMode` / `notAtHome` — location-aware variants
* `convertToMD5` / `isValueEqual` / `parseScannedValue` — scanned values are stored as MD5 hashes
* `startFallback` / `processFallbackResult` / `fallbackMode` — the "lost my code/tag" fallback
* `forgetAllCaptchas`, `getStoredValues`, `showSkipButton`, `showTutorial`

`QRCaptcha` and `BarcodeCaptureActivity` build on it; `BarcodeCaptureActivity` wraps ML Kit's
barcode scanner (`BarcodeGraphic`, `BarcodeGraphicTracker`, `BarcodeTrackerFactory`).

**UNKNOWN:** which barcode formats are accepted, and the exact MD5 comparison inputs.

### 2.4 NFC — *structure decoded, NDEF format not*

`NFCCaptcha` mirrors `BaseScanningCaptcha` with `convertToMD5` **and** `convertToMD52`,
`isValueEqual2`, `parseScannedValue` (two overloads), `onPrepareDialog`/`onCreateDialog`.
`NFCScanner` + `NFCScannerHelper` handle tag discovery; `NFCUtil.isNfcEnabled()` gates the feature.

The tutorial strings describe the intended flow: place the tag somewhere far from the bed (ideally
another room), "learn" it once, then scan it each morning.

**UNKNOWN:** the NDEF record layout and tag matching rules.

### 2.5 Maze — *structure decoded, physics not*

`MazeCaptcha` is an accelerometer-driven ball-in-maze on a `SurfaceView`:

* `BallModel` — `setAccel(x, y)`, `updatePhysics()`, `addWall`, `setBallRadius`, `setGoalRect`,
  `getWalls`, `pixelsPerMeter`, `velocityX/velocityY`, `vibratorRef`
* `MazeCaptcha` — `gameLoop`, `solve()`, `wallThink`, `onSensorChanged`, `onAccuracyChanged`

Win condition: the ball reaches `goalRect` (`solve()`).

**UNKNOWN:** maze dimensions, wall layout, physics constants, and whether difficulty changes the maze.

### 2.6 Light — *decoded*

```java
// com.urbandroid.sleep.captcha.light.LightCaptcha.setInitialThreshold
private int setInitialThreshold() {
    return (getCaptchaSupport().getDifficulty() * 50) + 30;
}
```

| Difficulty | Threshold |
|---|---|
| 1 | **80 lux** |
| 2 | **130 lux** |
| 3 | **180 lux** |
| 4 | **230 lux** |

Uses the ambient light sensor (`Sensor.TYPE_LIGHT`), requires the level to be held above the
threshold (`overThresholdProgress`, `resetOverThresholdProgressCheckpoints`, `HUMAN_READABLE_PROGRESS_MAX`).

### 2.7 Zombie walk — *decoded*

```java
// com.urbandroid.sleep.captcha.zombie.ZombieWalkCaptcha.onCreate
this.target = getCaptchaSupport().getDifficulty() * 15;
```

| Difficulty | Required steps |
|---|---|
| 1 | **15** |
| 2 | **30** |
| 3 | **45** |
| 4 | **60** |

Uses `Sensor.TYPE_STEP_DETECTOR`.

### 2.8 Memoji — *decoded*

```java
// com.urbandroid.sleep.captcha.memoji.MemojiCaptcha.generateTask
this.question = emojiGenerator.getRandomList(RangesKt.coerceAtMost(this.difficulty + 2, 6));
```

A sequence of **min(difficulty + 2, 6)** random emoji is shown, then hidden; the user must
reproduce it. The action bar shows `<title> <remaining>x`.

| Difficulty | Sequence length |
|---|---|
| 1 | **3** |
| 2 | **4** |
| 3 | **5** |
| 4+ | **6** (capped) |

`setAnswerTime` / `setCount` / `startCountdown` drive the recall window.

### 2.9 Sleeping sheep — *structure decoded*

Fields `TOLERANCE`, `sleepX/sleepY`, `sleepResPos`, `tries`, `dist`, `redrawThread`, `redrawTimeout`,
`difficultyWhenFallback`, `difficultyWhenFallbackTimes`. A sheep is drawn at a random position and
must be tapped within `TOLERANCE` pixels. The companion object exposes only `random(int, int)`.

**UNKNOWN:** the `TOLERANCE` value (declared as a `const val` on the activity and not recovered) and
the fallback difficulty arithmetic.

### 2.10 Wake the droid — *decoded*

```java
// com.urbandroid.sleep.captcha.WakedroidCaptcha.setInitialTarget
private int setInitialTarget() {
    int difficulty = getCaptchaSupport().getDifficulty() * 100;
    if (difficulty < 0) return 100;
    return difficulty;
}
```

| Difficulty | Progress target |
|---|---|
| 1 | **100** |
| 2 | **200** |
| 3 | **300** |
| … | `difficulty × 100` |

Tapping/holding fills `progress` toward `target`; `solve()` fires when it is reached. `soundPool`
plays feedback sounds.

### 2.11 Laugh out loud — *decoded*

```java
// com.urbandroid.sleep.captcha.LOLCaptcha.onCreate
difficulty = (double) getDifficulty() * 3.0d;
```

| Difficulty | Required detected laughs |
|---|---|
| 1 | **3** |
| 2 | **6** |
| 3 | **9** |
| 4 | **12** |

Records from the microphone (`createNewAudioRecorder`) and runs `LaughterDetectorV4`
(`preprocess`, `processChunk`, `count`, `sampleRate`, `classifier`, `broadcast`), backed by
`assets/v3_laugh.q.tflite` — the same `TFLClassifier_10s_lmsd2_5cat` used for sleep-sound
classification. `count` accumulates until the target. `LOLView` + `waveDrawable` render the meter.

**UNKNOWN:** the TFLite confidence threshold inside `processChunk`.

### 2.12 Smile — *decoded*

```java
// com.urbandroid.sleep.captcha.SmileCaptcha.onCreate
this.targetHapiness = (getCaptchaSupport().getDifficulty() * 0.05f) + 0.55f;
```

| Difficulty | Required smile confidence |
|---|---|
| 1 | **0.60** |
| 2 | **0.65** |
| 3 | **0.70** |
| 4 | **0.75** |
| 5 | **0.80** |

Uses `CameraSource` + a face detector (`createDetector`, `getCameraFacing`, `getLayoutResource`);
`targetHapiness` is the required smile probability from the detector.

### 2.13 Dream diary — *decoded*

```java
// com.urbandroid.sleep.captcha.DreamDiaryCaptcha.onCreate
this.max = Math.max(getDifficulty() * 10, 10);
...
private int getMax() { return this.max + this.offset; }
```

The user must type at least `getMax()` characters before the OK button enables.

| Difficulty | Minimum characters |
|---|---|
| 1 | **10** |
| 2 | **20** |
| 3 | **30** |
| … | `max(difficulty × 10, 10)` |

`max`, `offset`, `count`, `progress`, `progressText`, `updateDuration`, `save`, `checkSolved`.

**UNKNOWN:** how `offset` is initialised (set after `onCreate`; not recovered).

### 2.14 Agent sheep — *WebView*

`AgentSheepCaptcha` hosts `assets/agent_sheep` in a WebView and bridges through
`CaptchaJavascriptInterface`; `setSolved` / `setUnsolved` are called from JavaScript.

### 2.15 NFC scanner — see §2.4.

---

## 3. Difficulty model

There is no global difficulty enum. Each captcha interprets the integer from
`intent.getIntExtra("difficulty", 1)`:

| Captcha | Mapping |
|---|---|
| Simple / typed math | number of consecutive correct answers; also widens the operand range (`2·d+6`) and enables subtraction (`d>2`) and division (`d>4`) |
| Shake it | `d == 1 ? 500 : d × 1000` |
| Zombie walk | `d × 15` steps |
| Light | `d × 50 + 30` lux |
| Memoji | `min(d + 2, 6)` emoji |
| Wake the droid | `d × 100` progress units |
| Laugh out loud | `d × 3` detected laughs |
| Smile | `d × 0.05 + 0.55` smile confidence |
| Dream diary | `max(d × 10, 10)` characters |
| Maze / sleeping sheep | UNKNOWN |

The UI entry point for the default is `alarmclock.settings.CaptchaSettingsActivity` /
`CaptchaPreferenceUtil`, with `captcha_mode` (default `0`) and `captcha_config`.

---

## 4. Anti-cheating ("CAPTCHA No cheating")

Referenced classes: `captcha.cheating.LockView`, `CaptchaAntiCheatingAccessibilityService`
(`BIND_ACCESSIBILITY_SERVICE`), `alarmclock.settings.NoEscapeManager`, `NoEscapeActivity`,
`NoEscapeFragment`, and `SleepDeviceAdminReceiver` (`BIND_DEVICE_ADMIN`).

From the string resources:

* `captcha_no_escape` — "Force stop and uninstall protection by making the app a device admin. Uncheck to revoke."
* `captcha_no_escape_nfc_warning` — "CAPTCHA Cheating protection is not compatible with NFC CAPTCHA when screen is locked!"
* `overlay_permission_captcha` — "CAPTCHA cheating protection requires permission to draw over other apps."
* `alarm_avoid_tip` — "Use all for maximum protection!"
* `alarm_avoid_wakeup_motivation_justification` — "Huh, you're the clever one who can cheat CAPTCHA? Try placing a small refundable deposit that is lost once you..."
* `alarm_avoid_protection_failed` — "Seems like you have cheated CAPTCHA recently."
* `settings_category_no_cheating` — "CAPTCHA No cheating"
* `captcha_no_escape` — toggled in `CaptchaCheatingSettingsActivity`

**INFERRED** (from component names and strings, not decompiled): the mechanism is device-admin
protection (blocks force-stop/uninstall), an overlay lock (`LockView` drawn over other apps), and an
accessibility service that detects when the user leaves the captcha. A refundable "wager" deposit
(`startWagerRefundFlow`) is refunded only if the captcha is completed honestly.

**Not decompiled:** `LockView`, `CaptchaAntiCheatingAccessibilityService`, `NoEscapeManager`,
`NoEscapeActivity` — see UNKNOWNS.

---

## 5. Wake-up check

Configured in `res/xml/settings_captcha_wake_up_check.xml` with:

* `settings_category_wake_up_check`
* `capctha_expl`
* `notification_channel` — a dedicated notification ringtone for the check

Related preference keys and strings:

| Key / string | Meaning |
|---|---|
| `settings_wake_up_check` | "Wake up check" |
| `settings_wake_up_check_after_alarm` | "Check after" — delay after the alarm is dismissed |
| `settings_wake_up_check_after_notification` | "Time to confirm" — how long the user has to confirm |
| `CaptchaWakeUpCheckSettingsActivity` | the settings screen |
| `getCaptchaSuppressMode()` | suppress mode consulted by `CaptchaCallbackReceiver` on the ALIVE heartbeat |

The idea: after the alarm is dismissed, the app waits the configured interval and re-asks for
confirmation; failing to confirm re-triggers the alarm.

**UNKNOWN:** the exact default delay and confirmation window, and the implementation class that
schedules the check.

---

## 6. Captcha selection

`captcha.finder.CaptchaFinder` (abstract), `BaseCaptchaFinder`, `CachedCaptchaFinder`,
`CaptchaInfoFilter`, and `captcha.domain.CaptchaInfo` / `CaptchaGroup` / `BaseCaptchaInfo`.

`CaptchaSupportFactory.create(...)` (two overloads) instantiates the support object for a captcha.
`CaptchaInfoFilter` composes filters — `AndCaptchaInfoFilter`, `IdCaptchaInfoFilter`,
`NotCaptchaInfoFilter`, `PackageCaptchaInfoFilter` — to select a captcha by id or by package
(the "CaptchaPack" add-on packs installed as separate APKs).

`captcha.list.CaptchaTileListActivity` / `CaptchaTileDialogFragment` is the tile picker;
`captcha.launcher.BaseCaptchaLauncher` / `CaptchaLauncher` launch the chosen captcha.

---

## 7. Pseudocode for a reimplementer

```
onAlarmRings():
    difficulty = alarm.captchaDifficulty          // intent extra "difficulty", default 1
    captcha = selectCaptcha(alarm, filters)       // by id, or by package for add-on packs

    result = captcha.run(difficulty)
        // captcha gets the serialised Alarm via "intent.extra.alarm_raw"
        // captcha may heartbeat: action ALIVE every N seconds

    if result == SOLVED:
        broadcast(CAPTCHA_ACTION_STOP)
        Alarms.dismissOrSnooze(alarm)             // via CaptchaCallbackReceiver
        settings.setLastCaptchaSolvedTimestampNow()
    else:
        broadcast(CAPTCHA_ACTION_STOP)
        keep ringing / apply alarm timeout

    // extras on the result intent decide what happens next:
    //   snooze_cancel, delete_alarm, edit_alarm, disable_alarm, should_skip
```

Per-captcha success conditions:

```
math(d)      : solve d problems in a row; operand ceiling = 2d+6; subtraction if d>2; division if d>4
shake(d)     : accumulate d==1 ? 500 : d*1000 shake counts (10 s progress cache)
zombie(d)    : take d*15 steps (TYPE_STEP_DETECTOR)
light(d)     : hold ambient light above (d*50+30) lux
memoji(d)    : reproduce a sequence of min(d+2, 6) emoji
qr/barcode   : scan the registered code (stored as MD5); multiscan variant requires all codes
nfc          : present the registered NFC tag
maze         : tilt the ball into the goal rectangle
droid        : fill the progress bar to target
sheep        : tap the sheep within TOLERANCE px
smile        : smile with intensity >= targetHapiness
laugh        : accumulate detected laughs (TFLite v3_laugh)
diary        : type a dream for >= max + offset
```

---

## 8. UNKNOWNS

Not recovered in this pass — do not treat as known:

* The `setResult(...)` numeric contract per captcha (only `setResult(2)` on math success was observed).
* Barcode/QR: accepted symbologies, the exact MD5 comparison inputs, and the fallback-code rules.
* NFC: the NDEF record layout and tag matching.
* Maze: maze dimensions, wall geometry, physics constants, and any difficulty scaling.
* Wake the droid: `target` value and per-difficulty scaling.
* Sleeping sheep: `TOLERANCE` and the fallback difficulty arithmetic.
* Smile: `targetHapiness`.
* Laugh: the laugh count target and TFLite confidence threshold.
* Dream diary: where `max` / `offset` are initialised.
* Anti-cheating: `LockView`, `CaptchaAntiCheatingAccessibilityService`, `NoEscapeManager` and
  `NoEscapeActivity` were not decompiled; §4 is inferred from component names and strings.
* Wake-up check: default delay and confirmation window, and the class that schedules it.
* Captcha selection: `CaptchaFinder` / `CaptchaInfoFilter` were not decompiled in detail.
* `CaptchaAntiCheatingAccessibilityService` — what events it observes and how it decides cheating.

---

## 9. Reimplementation notes for this project

This project currently has **8 missions** (`MissionType.math`, `shake`, `squat`, `barcode`, `photo`,
`typing`, `walking`, `memory`) with a flat `missionDifficulty: 1..5`, and no per-mission difficulty
mapping, no anti-cheat lock, and no wake-up check (both are flag-only columns).

Highest-value additions, in order:

1. **Per-mission difficulty mapping** — the original's rule is simply "difficulty = how many times
   you must succeed" (math), which is a one-line change and immediately makes `missionDifficulty`
   meaningful. Add the same idea to typing and memory.
2. **Wake-up check** — the app's core promise; currently `wakeUpCheckEnabled` does nothing.
3. **Anti-cheat lock** — `LockView`-style overlay + keeping the screen on during the captcha.
   Device-admin protection is a bigger commitment (Play policy sensitive).
4. **New captchas** — the maze, light and zombie-walk captchas are the cheapest to add (accelerometer
   and light sensor are already available via `sensors_plus`), and each needs only a threshold.