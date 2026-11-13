# Design Brief — Rise UI/UX

**Read this first.** It is the single document that says what to build, how it should look, and
what not to do. Everything else in `docs/` is reference.

**Target:** Android only. Flutter 3.50, Material 3, Kotlin. Portrait phone.
**Audience:** students, 9-to-6 workers, and ADHD-friendly users — one codebase, three presets.

---

## 1. The one rule

**Every screen answers one question and has one primary action.**

If a screen has two equally loud buttons, it is wrong. If a user has to read to find out what to
tap, it is wrong. Everything secondary goes behind "Advanced", into a sheet, or one level down.

The reference app this project is modelled on has 403 preference keys across 42 settings screens.
That is the failure mode. We keep the capability and drop the wall.

---

## 2. Colour

Dark only. There is no light theme, and there will not be one.

### Surfaces, darkest first

| Token | Hex | Use |
|---|---|---|
| `background` | `#070A0E` | Scaffold, app bar, nav bar |
| `surface` | `#0E1319` | Cards, sheets, dialogs |
| `surfaceHigh` | `#161D25` | Inputs, switches, chips |
| `surfaceHighest` | `#1E262E` | Raised controls |
| `outline` | `#232C36` | Hairlines, borders |

### The accent split — do not break this

| Token | Hex | Allowed on |
|---|---|---|
| `primary` | `#FFB347` | **Actions only** — buttons, switches, selection |
| `onPrimary` | `#1A1206` | Text on amber |
| `secondary` | `#4DB6AC` | **Sleep data only** — never a button |
| `error` | `#FF5C5C` | Destructive actions |

Amber never appears on the hypnogram. Teal never appears on a button. This separation is the
single thing that keeps a feature-heavy interface legible.

### Text ramp — exactly four alphas of white

| Token | Value | Use |
|---|---|---|
| `onSurface` | `#FFFFFF` (100%) | Titles, values |
| `onSurfaceVariant` | `#B2FFFFFF` (70%) | Subtitles, labels |
| `onSurfaceFaint` | `#54FFFFFF` (33%) | Hints, captions |
| `onSurfaceGhost` | `#1EFFFFFF` (12%) | Disabled |

### Sleep phases

| Phase | Hex |
|---|---|
| Deep | `#E5E5E5` |
| Light | `#80CBC4` |
| REM | `#4DB6AC` |
| Awake | `#B2DFDB` |

---

## 3. Shape

| Token | Value | Why |
|---|---|---|
| Card radius | 24 dp | A card is a container you look at |
| Button radius | 8 dp | A button is a control you press |
| Sheet / dialog radius | 28 dp | |
| Screen gutter | 16 dp | |

**No drop shadows.** On a near-black background a shadow is invisible; the 1 dp `outline` border
does the separating.

**No pure black `#000000` surfaces**, with one exception: the night clock's dim mode, where it is the
point.

---

## 4. Typography

**Inter**, bundled at `assets/fonts/Inter.ttf` (variable, `wght` 100–900). Never fetched at runtime.

With a variable font, `fontWeight` alone does not move the axis — set `fontVariations: [FontVariation('wght', N)]` explicitly or text renders flat.

| Style | Weight | Use |
|---|---|---|
| `displayMedium` | 600 | The alarm time |
| `displaySmall` | 600 | Big numbers |
| `headlineSmall` | 600 | Card headlines |
| `titleMedium` | 600 | Section titles |
| `bodyMedium` | 400 | Body |
| `bodySmall` | 400 | Captions |
| `labelSmall` | 600 | Section headers (uppercase, +1.1 tracking) |

### Apple HIG reference points (iOS)

Measured from Apple's Human Interface Guidelines, for calibration — not because we are on iOS:

| Guideline | Value |
|---|---|
| Body text default | 17 pt |
| Body text minimum | 11 pt |
| Minimum touch target | 44 × 44 pt |
| Button centre spacing | at least 60 pt apart |
| Layout inset, primary content | 60 pt top/bottom, 80 pt sides |

Our equivalent: body 14–15 dp, minimum label 11 dp, touch target 48 dp, primary actions 56 dp apart.
We exceed Apple's minimums because Android's guidance is 48 dp and our audience includes users who
will be half-asleep.

---

## 5. Motion

Five tiers. Never invent a duration outside these.

| Tier | Duration | Use |
|---|---|---|
| **Micro** | 60–100 ms | Press feedback, ripple, switch |
| **Small** | 100–300 ms | Show/hide, dialogs, expand/collapse |
| **Medium** | 200–600 ms | Move, rotate, page content |
| **Large** | 300 ms + 50/66 ms stagger | Route transitions |
| **Ambient** | 600–3000 ms | Decorative loops, empty states |

Rules:
- Press feedback is a **100 ms scale to 0.97**, not only a ripple.
- The Advanced section uses a **200 ms cross-fade**.
- Never animate a value the user is directly manipulating.
- Respect the OS "reduce motion" setting — if set, drop to instant.

Apple's own durations for comparison: `.fast` ≈ 250 ms, `.regular` ≈ 350 ms, `.slow` ≈ 400 ms. Our
small/medium tiers sit inside that band on purpose.

---

## 6. Components

### `RiseButton`

Capsule, 52 dp tall. Three weights — a screen should never offer two equally loud choices.

| Weight | Style | Use |
|---|---|---|
| `primary` | filled amber | the one thing to do |
| `secondary` | outlined, 1.5 dp border | a real alternative |
| `ghost` | text only | cancel, skip, back |

Disabled uses `onSurfaceGhost` and no fill.

### Time picker

Flutter's Cupertino wheel (the iOS clock interaction) in our dark palette, inside a bottom sheet
with a grab handle and Cancel/Done. 24-hour, visible separator.

### Cards

`surface` fill, 1 dp `outline` border, no elevation, 24 dp radius.

### Navigation bar

3 destinations, 68 dp, amber indicator at 14% opacity, label always shown.

---

## 7. Information architecture

```
[ Alarms ]   [ Sleep ]   [ You ]
```

| Tab | Answers | Primary action |
|---|---|---|
| **Alarms** | What will wake me, and when? | The next-alarm card |
| **Sleep** | How did I sleep? | Start/stop tracking |
| **You** | How am I doing over time? | The score card |

No drawer. No hamburger. Settings is reachable from the app bar.

### Personas are presets, not branches

```
PersonaPreset
  id, displayName, tagline, icon
  defaults            Map<SettingKey, Value>   // written once, on selection
  missionWeights      Map<MissionType, double>
  friction            low | normal | high
```

The five presets ship: student, 9-to-6 worker, heavy sleeper, shift worker, biohacker.

**Friction is a dial, not a persona.** It is how ADHD support works without a sixth preset —
`friction: low` applied to any persona. Never write `if (persona == ...)` anywhere in the app.

Selecting a persona writes its defaults into the normal settings store **once**. Afterwards the
user's own settings win.

---

## 8. Build order

| # | Screen | Notes |
|---|---|---|
| 1 | Three-tab shell + next-alarm card | The spine |
| 2 | Alarm editor | Collapsing toolbar, hero time, Advanced collapsed |
| 3 | Sleep tab + hypnogram | Staircase graph, four phases |
| 4 | Night clock | Bedside clock, dim mode, live graph |
| 5 | You tab | Score ring, streak, averages |
| 6 | Settings | Grouped by question, searchable |

---

## 9. Do not

- Do not copy any artwork, layout, icon or animation from Sleep as Android. Its **behaviour** is
  fair to match; its **expression** is not. Ship original assets.
- Do not add a light theme.
- Do not add drop shadows.
- Do not put teal on a button or amber on the hypnogram.
- Do not add a dependency without saying why.
- Do not create a settings screen with more than one level of nesting.
- Do not invent durations outside the five tiers.
- Do not gate a feature behind a persona.
- Do not use `print` — use a logger.

---

## 10. Where the truth lives

| Question | Answer |
|---|---|
| What are the exact tokens? | `lib/theme/app_theme.dart` — the code wins over this document |
| Why is it like this? | `docs/design/00-foundations.md` |
| What are the personas? | `docs/product-design.md` |
| Does it build? | `flutter analyze` (0 errors) and `flutter test` (55 tests) |