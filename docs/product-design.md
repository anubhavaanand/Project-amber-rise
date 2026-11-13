# Product design: personas and information architecture

Two decisions this document settles:

1. **All five personas ship as presets**, not one chosen niche. The user picks at onboarding and can
   change later.
2. **The UI is feature-heavy but not cluttered**, achieved by progressive disclosure: one primary
   action per screen, everything else one tap down.

---

## 1. Persona presets

### 1.1 The rule

A persona is **data, never a branch**. No `if (persona == student)` anywhere in the app. A preset is
a bundle of defaults that the user can then override individually.

```
PersonaPreset
  id                  stable string, e.g. "student"
  displayName         "Student"
  tagline             one line shown at onboarding
  icon                emoji or asset key
  defaults            Map<SettingKey, Value>   // applied once, on selection
  missionWeights      Map<MissionType, double> // which missions are offered first
  copy                tone overrides for a handful of strings
  friction            "low" | "normal" | "high"
```

Selecting a preset writes its defaults into the normal settings store. From then on the preset is
only used for (a) the mission ordering and (b) copy tone. The user can change any setting
individually and the preset never fights them.

### 1.2 The five presets

| Preset | Core job | Defaults it sets | Missions it surfaces first | Friction |
|---|---|---|---|---|
| **Student** | Survive exam season without wrecking sleep | Bedtime reminder 23:30, nap timer on, sleep-debt goal 8 h, gentle wake 60 s | Math, typing, memory | normal |
| **9-to-6 worker** | Never oversleep on a fixed schedule | Smart window 30 min, backup alarm on, wake-up check 10 min, bedtime 23:00 | Math, barcode, shake | high |
| **Heavy sleeper** | Physically cannot stay in bed | All anti-oversleep on: wake-up check, no-escape, backup alarm, max-volume ramp, 3-step challenge | Shake, QR, NFC, walking, math | high |
| **Shift worker** | Sleep at irregular hours | Jet-lag alarm, flexible bedtime, no fixed bedtime reminder, social-jetlag tracking | Light, typing, memory | low |
| **Biohacker** | Understand the data | Full tracking, HRV/SpO2 where available, all stats, raw export | Memory, typing, math | normal |

**Friction** is the ADHD lever. It is not a persona of its own — it is a dial any preset can set,
and the user can change independently:

- `low` — one tap to dismiss, no captcha required by default, no streak pressure, no guilt copy
- `normal` — a captcha is required, streaks shown
- `high` — multi-step challenge, anti-escape on, wake-up check on

That way "ADHD-friendly" is not a separate app; it is `friction: low` applied to whichever persona
the user picked.

### 1.3 Adding a persona later

Drop a new entry in the preset table plus its defaults and mission weights. No core change. This is
the extension point that keeps the door open for "new parents", "athletes", "night-shift nurses",
and so on without a rewrite.

### 1.4 What presets must never do

- Gate features behind a persona. Everything is reachable from Settings regardless of preset.
- Silently re-apply defaults after the user changes them. Presets are applied **once**, at selection.
- Change the alarm engine's behaviour. Reliability is identical for everyone.

---

## 2. Information architecture

### 2.1 The principle

Every screen answers **one question** and has **one primary action**. Secondary controls live in a
bottom sheet or a "More" section, never on the main surface.

The failure mode to avoid: a settings screen with 40 switches. The reference app has exactly that
problem — 42 preference screens and 403 preference keys. We keep the capability, not the clutter.

### 2.2 Navigation

Onboarding runs **once**, before the shell, and only when no preset has ever been applied:

```
[ Pick a persona ]  →  [ Review what it sets + friction ]  →  shell
```

Then three tabs, no drawer, no hamburger:

```
[ Alarms ]   [ Sleep ]   [ You ]
```

| Tab | Answers | Primary action |
|---|---|---|
| **Alarms** | "What will wake me, and when?" | The next alarm card with a toggle |
| **Sleep** | "How did I sleep?" | Start/stop tracking |
| **You** | "How am I doing over time?" | The score card |

Everything else is reached from a screen, never from the tab bar.

### 2.3 Screen-by-screen

**Alarms**
- Next-alarm card: time, label, repeat, mission icon, toggle. Tap → edit.
- Alarm list below, collapsed to one line each.
- FAB → new alarm.
- Alarm editor: a **single scroll** with the 6 things people actually set — time, repeat, label,
  sound, mission, smart window. Everything else behind "Advanced" (volume ramp, backup alarm,
  offset, orientation, delete-after-ring, vibration pattern).

**Sleep**
- Tonight card: bedtime suggestion, tracking toggle.
- Last night card: duration, score, a tappable hypnogram.
- Below: sleep-debt, regularity, chronotype — each a card that expands to its chart, not a wall of
  charts.

**You**
- Score, streaks, achievements.
- Stats entry point → the full stats screen with a measure picker (this is where the ~40 extractors
  live, behind a searchable list).

**Settings** — grouped by the user's question, not by the app's internals:

```
Alarms        default alarm, smart window, backup alarm, snooze
Wake-up       missions, difficulty, wake-up check, no-escape
Sleep         tracking, sensors, awake detection, auto-start
Sounds        alarm sounds, lullabies, volume ramp
Persona       preset, friction dial
Data          export, import, backup
About         version, license, privacy
```

Persona lives in Settings so it can be changed later; first-run selection happens in onboarding.

Each group is one screen with a short list. Nothing nested more than two levels deep.

### 2.4 Progressive disclosure patterns

- **One primary action per screen.** A filled button, or a card that is obviously tappable. Never two
  competing filled buttons.
- **Advanced is collapsed.** Default-visible settings are the ones that change behaviour; the rest are
  behind "Advanced" on the same screen.
- **Charts expand in place.** A card shows the headline number; tapping it reveals the chart.
- **Search over menus.** Settings has a search field, like the reference app's `SearchSettingsActivity`
  — it is the single best fix for a feature-heavy app.
- **Presets do the configuring.** A new user picks a persona and gets a working setup in one tap,
  instead of facing 403 switches.

### 2.5 Accessibility and tone

- Minimum 48 dp touch targets, WCAG AA contrast in both light and dark.
- The alarm screen must work with the phone face down and the screen off (full-screen intent).
- Copy tone: direct, never shaming. No "you failed", no guilt streaks. This matters for the ADHD
  persona specifically — streak-loss shaming is the fastest way to make someone delete the app.

---

## 3. Build order that follows from this

| # | Work | Why now |
|---|---|---|
| 1 | Preset model + settings store | Everything else reads from it |
| 2 | Three-tab shell with the next-alarm card | The app needs a spine before screens fill in |
| 3 | Alarm editor with collapsed Advanced | The core flow |
| 4 | Sleep tab: last-night card + hypnogram | Depends on the detector being wired |
| 5 | Settings grouped by question + search | Where the 403 keys become navigable |
| 6 | You tab: score, streaks, stats picker | Last, once there is data to show |