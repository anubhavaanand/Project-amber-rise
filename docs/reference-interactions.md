# Reference interaction spec

Behaviour extracted from Sleep as Android 20261016 (`com.urbandroid.sleep`, decoded APK).

**What this is:** a description of *behaviour and structure* — what responds to what, how
long it takes, how deep the hierarchy goes. **What it is not:** their artwork, layout XML, icons,
Lottie files or copy. Nothing here is copied expression. Patterns, timings and workflows are not
protectable, so these are safe to implement — the screens themselves must be built originally.

Every item cites the class or resource it was observed in.

---

## 1. The alarm row (the app's core component)

Structure from `res/layout/card_alarm.xml`:

```
CardView #card_alarm
├── #no_alarm                      empty state: illustration + "set alarm" + add button
└── #row_alarm                     the row
    ├── #icon_right                trailing affordance
    └── #box_alarm
        ├── #titleText             alarm name, 36dp band
        └── DigitalClock           custom composite view
            ├── #next_alarm        next-alarm badge
            ├── #timeDisplay       the time
            ├── #am_pm
            ├── #alarm_icon
            ├── #label
            ├── DontPressWithParentLayout
            │   └── MaterialSwitch #switchOnOff
            └── #details
        └── (second line) #daysOfWeek + #prefs
```

### 1.1 Interaction rules worth copying

| Behaviour | Why it matters |
|---|---|
| The switch is wrapped in `DontPressWithParentLayout` | Toggling the alarm must **not** open the editor. Without this wrapper the whole row is a tap target and every toggle also navigates — the single most common bug in alarm apps. |
| Two-line row: name + time on top, repeat days + settings summary below | Answers "what/when" and "how often/what mission" in one glance, no expansion needed. |
| A dedicated "empty" state inside the same card | The list never looks broken at zero alarms; the empty state advertises the primary action. |
| Trailing `#details` affordance | Opens the editor without making the whole card a link, so the switch and the editor have separate hit areas. |
| `#next_alarm` badge on the row | The next alarm is visually distinguished inside the list, not only at the top. |

### 1.2 What we do differently

Our `NextAlarmCard` already does the hero treatment. Adopt from the above: the
**switch/row hit-area separation**, the **two-line row**, and the **in-card empty state**.

---

## 2. Screen scaffolding

From `res/layout/activity_set_alarm.xml` and `activity_dashboard.xml`:

```
CoordinatorLayout #root
├── AppBarLayout #appbar          height = @dimen/app_bar_height_short
│   └── CollapsingToolbarLayout #ctoolbar
│       ├── MaterialToolbar #toolbar
│       └── RelativeLayout #label_parent      (editable label inside the toolbar)
├── <fragment>                    the content
└── NavigationView                height 48dp
```

**Observed pattern:** a *collapsing* toolbar, not a fixed one. The title area collapses on scroll
and the content takes the space. The alarm label is editable **inside the toolbar**, so naming an
alarm doesn't require a separate dialog.

**What to adopt:** collapsing toolbar on detail screens, editable label in the toolbar, content in
a fragment-like body, and a 48dp bottom bar.

---

## 3. Motion system

The APK ships ~110 named animations (`res/anim/`, `res/animator/`). They cluster cleanly into five
tiers, which is a usable motion scale:

| Tier | Durations observed | Use |
|---|---|---|
| **Micro** — press feedback | 60–100ms (`fade_fast` 80, `hide_short` 100, `big_buzz` 80, `buzz` 100) | button press, switch, ripple |
| **Small** — show/hide | 100–300ms (`hide`/`show` 160, `scale_show`/`scale_hide` 60/180, `scale_up`/`scale_down` 200, `click` 300) | expand/collapse, dialogs, chips |
| **Medium** — move/rotate | 200–600ms (`slide_up` 200, `slide_in_left` 200, `fly_in` 300, `rotate` 600, `flip` 600, `reveal` 600) | page content, cards, icons |
| **Large** — page/fragment | 300ms with a 50/66ms stagger (`fragment_open_enter` 50/300, `fragment_close_enter` 50/66/300) | screen transitions |
| **Ambient** — decorative loops | 600–3000ms (`sunrise` 600, `moonrise` 600, `slide_up_sunrise` 1200/1600, `wave` 2000, `alpha_pulse` 500, `pulse` 1000) | empty states, loading, success |

**Pager transitions:** `next_enter`/`next_exit`/`prev_enter`/`prev_exit` are all **180ms** — a
symmetric 180ms slide for horizontal paging.

**What to adopt:** these five tiers as our motion scale, the 180ms pager, and the 50/66ms stagger
on fragment enter. The ambient tier is where the sunrise icon motif can live.

---

## 4. Graph / hypnogram

From `res/layout/activity_graph.xml` + the phase colour tokens:

* Four phases on one time axis: **deep**, **light**, **REM**, **awake**.
* Phase colours (measured, `res/values/colors.xml`): deep `#E5E5E5`, light `#80CBC4`,
  REM `#4DB6AC`, awake `#B2DFDB`. Already recorded as `AppColors.phase*`.
* Gaps (no data) render as breaks in the series rather than as zero-height segments.
* A legend chip row sits under the graph (`res/layout/button_graph_legend.xml`).
* Detail view is a **separate translucent activity** (`Theme.sleep.graph.detail` with
  `windowIsTranslucent=true`), not an in-place expansion — the graph stays put underneath.

**What to adopt:** the four-phase colour mapping (already in our theme), gaps-as-breaks, and the
detail-as-translucent-overlay pattern.

---

## 5. Settings

* `res/xml/settings_*.xml` are **navigation only** — 42 screens, 403 preference keys, but the leaf
  preferences are constructed in Kotlin, not in XML.
* Preference spacing: `pref_spacing_horizontal` 28dp, `pref_spacing_vertical` 16dp.
* The app has a **search screen** (`SearchSettingsActivity`) over the whole settings tree.

**What to adopt:** a settings search. It is the single highest-leverage fix for a feature-heavy app,
and it is an idea, not expression.

---

## 6. What we are deliberately not taking

| Not taken | Reason |
|---|---|
| Layout XML, drawables, icons, Lottie, illustrations | Copyrighted expression |
| Their copy and string resources | Copyrighted |
| Their exact screen composition | Expression, not pattern |
| Their typeface choices | Licensed font files |

## 7. Open questions for the next pass

* The dashboard card system (`card_*.xml`, ~30 variants) — how cards are prioritised and reordered.
* The sleep-tracking screen's sensor affordances (`SensorPreviewActivity`, `sensor_graph`).
* The onboarding/first-use flow (`FirstUsePreviewActivity`, `QuickStartPreviewActivity`).
* Whether the pager is used for the tab bar or only for the onboarding carousel.
---

## 8. Sleep tracking screen (`activity_sleep_track.xml`)

The most interesting screen in the app, and the reason is structural rather than visual:
**while tracking, the phone sits on the nightstand, so the screen becomes a bedside clock.**

Observed hierarchy:

```
FrameLayout
├── CoordinatorLayout #sleep_track_parent
│   ├── toolbar_parent
│   │   ├── Toolbar
│   │   └── #squigllyProgress        h=16dp  (a wavy progress line under the toolbar)
│   ├── #clock_parent
│   │   └── DigitalClock
│   │       └── #timeDisplay                ← the hero
│   ├── #recording_parent
│   │   ├── #recording_img
│   │   ├── #recording_text
│   │   └── #recording_bar                  LinearProgressIndicator
│   ├── #step_alarm  (#step_alarm_icon, #step_alarm_text, #good_night)
│   ├── #graph_layout
│   │   ├── GraphView #graph                the live night graph
│   │   ├── LottieAnimationView #anim2      animated overlay
│   │   └── ScrollView of ~25 #step_* rows  contextual guidance
│   ├── #pause_indicator  (#pause_indicator_text, #pause_indicator_add_time)
│   ├── #battery_save_indicator
│   ├── #hr_indicator     (#hr_img, #hr_text, #hr_text2)
│   └── #bottom_sheet     (RecyclerView #drawer_recycler + #stop_and_save_parent)
├── #adsStub
├── LottieAnimationView #anim               full-screen animation
├── DigitalClock #dimClock  (#timeDisplayDim)  ← dimmed night clock
└── #hint
```

### 8.1 The ideas worth taking

| Idea | Why it works |
|---|---|
| **The clock is the hero** | At 3am you glance, you do not interact. The screen answers "what time is it" before anything else. |
| **A separate `#dimClock`** | A low-brightness clock face for the night, distinct from the interactive UI, so the screen does not blind you in a dark room. |
| **Live graph under the clock** | The night draws itself while you sleep, so you get feedback without opening anything. |
| **25 contextual `step_*` rows** | Each names one thing that is wrong and how to fix it: `step_recording_permission`, `step_battery_optimized`, `step_charger`, `step_sonar`, `step_airplane`, `step_smartwatch`, `step_external_not_mounted`, and so on. Guidance is contextual and ordered, not a wall of settings. |
| **Pause with `+X min`** | Pausing is a first-class action, not a stop. You can extend the night. |
| **Bottom sheet holds stop-and-save** | The destructive action is deliberately placed away from the clock, so it cannot be hit by accident in the dark. |
| **`#squigllyProgress`** | A 16dp wavy progress line under the toolbar: progress without a chart. |

### 8.2 What we should build

An equivalent night screen, originally drawn:

1. Full-screen clock as the hero, with the night's elapsed time.
2. A dim mode: tap to drop to a low-brightness clock face.
3. A live hypnogram of the night so far, drawn with the same painter as the Sleep tab.
4. A contextual checklist that names what is missing, ordered by severity.
5. Pause with `+15 min`, and stop-and-save in a bottom sheet.

### 8.3 What we must not take

The droid character animations, the Lottie files, the squiggly line artwork, and
the exact screen composition. The clock-and-graph *structure* and the contextual
checklist *behaviour* are the reusable parts.
