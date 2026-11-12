# Foundations

Rise's design tokens. Everything here is already implemented in
`lib/theme/app_theme.dart`; this document is the reference, not the source of
truth. If the two disagree, the code wins and this file is stale.

## Colour

### Surfaces — darkest first

| Token | Hex | Use |
|---|---|---|
| `background` | `#070A0E` | Scaffold, app bar, nav bar |
| `surface` | `#0E1319` | Cards, sheets, dialogs |
| `surfaceHigh` | `#161D25` | Inputs, switches, chips |
| `surfaceHighest` | `#1E262E` | Raised controls |
| `outline` | `#232C36` | Hairlines, borders |

The reference implementation's dark window is `#263238` — a blue-grey, not a
black. These keep its faint blue-grey cast but go far deeper, as the brief asked.

### Accent

| Token | Hex | Use |
|---|---|---|
| `primary` | `#FFB347` | Actions, switches, selection |
| `onPrimary` | `#1A1206` | Text on amber |
| `primaryContainer` | `#3A2A12` | Selected chips |
| `teal` | `#4DB6AC` | Sleep data only |
| `error` | `#FF5C5C` | Destructive actions |

**One warm accent for actions, one cool accent for data.** Amber comes from the
launcher icon, so app and icon read as one object. Teal never appears on a
button and amber never appears on the hypnogram. That separation is the whole
reason the interface stays legible with this much on screen.

### Text ramp

Exactly four alphas of white, matching the reference's
`white` / `white_secondary` / `white_tertiary` / `white_quaternary`:

| Token | Value | Use |
|---|---|---|
| `onSurface` | `#FFFFFF` | Titles, values |
| `onSurfaceVariant` | `#B2FFFFFF` (70%) | Subtitles, labels |
| `onSurfaceFaint` | `#54FFFFFF` (33%) | Hints, captions |
| `onSurfaceGhost` | `#1EFFFFFF` (12%) | Disabled |

### Sleep phases

| Phase | Token | Hex |
|---|---|---|
| Deep | `phaseDeep` | `#E5E5E5` |
| Light | `phaseLight` | `#80CBC4` |
| REM | `phaseRem` | `#4DB6AC` |
| Awake | `phaseAwake` | `#B2DFDB` |

These are measured from the reference implementation's main palette. An
alternate olive/lime variant (`altPhaseDeep` `#5A713C`, `altPhaseLight`
`#799B33`, `altPhaseAwake` `#A6D725`) is recorded but unused — it needs a
contrast check against these surfaces before it could be an option.

## Shape

| Token | Value | Use |
|---|---|---|
| `radiusCard` | 24dp | Cards |
| `radiusButton` | 8dp | Buttons |
| `radiusSheet` | 28dp | Bottom sheets, dialogs |
| `gutter` | 16dp | Screen padding |

Cards at 24dp and buttons at 8dp is deliberate: a card is a container you look
at, a button is a control you press. Different jobs, different shapes.

## Typography

**Inter**, bundled at `assets/fonts/Inter.ttf` (variable, `opsz` 14–32,
`wght` 100–900). Not fetched at runtime — the previous `google_fonts` setup
downloaded it on first launch and swapped it in, causing a visible reflow.

Weights are set with an explicit `wght` axis per text style. With a variable
font, `fontWeight` alone does not move the axis, so text would render flat
without it.

Scale (Material 3 defaults, Inter applied):

| Style | Weight | Use |
|---|---|---|
| `displayMedium` | 600 | The alarm time |
| `displaySmall` | 600 | Big numbers |
| `headlineSmall` | 600 | Card headlines |
| `titleMedium` | 600 | Section titles |
| `bodyMedium` | 400 | Body |
| `bodySmall` | 400 | Captions |
| `labelSmall` | 600 | Section headers (uppercase, +1.1 tracking) |

## Motion

Five tiers, extracted from the reference implementation's ~110 named
animations. Durations in ms.

| Tier | Duration | Use | Examples |
|---|---|---|---|
| **Micro** | 60–100 | Press feedback | button scale, ripple |
| **Small** | 100–300 | Show / hide | dialogs, Advanced expand, chevron |
| **Medium** | 200–600 | Move / rotate | cards, page content |
| **Large** | 300 + 50/66 stagger | Screen transitions | route pushes |
| **Ambient** | 600–3000 | Decorative loops | empty states, loading |

Rules:

- Press feedback is a **100ms scale to 0.97**, not only a ripple.
- The Advanced section uses a **200ms cross-fade**.
- The chevron rotates over **200ms**.
- Never animate a value the user is directly manipulating.

## Components

### Buttons — `RiseButton`

Capsule, 52dp tall. Three weights, because a screen should never offer two
equally loud choices:

| Weight | Style | Use |
|---|---|---|
| `primary` | filled amber | the one thing to do |
| `secondary` | outlined | a real alternative |
| `ghost` | text only | cancel, skip, back |

### Time picker — `showRiseTimePicker`

Flutter's Cupertino wheel (the iOS clock interaction) in our dark palette,
inside a bottom sheet with a grab handle and Cancel/Done. 24-hour, with a
visible separator.

### Cards

`surface` fill, 1px `outline` border, no elevation, 24dp radius. No shadows —
on a near-black background a shadow is invisible anyway, and the border does the
separating.

### Navigation bar

3 destinations, 68dp, amber indicator at 14% opacity, label always shown.

## Layout

- 3 tabs: Alarms / Sleep / You. No drawer, no hamburger.
- One primary action per screen.
- Secondary controls go behind "Advanced" or into a sheet.
- Settings is searchable — the reference has 403 preference keys, and search is
   the difference between feature-heavy and unusable.

## Deliberately absent

- **No light theme.** A half-built one would look worse than none, and the
   deep-black palette is the product.
- **No drop shadows.** Invisible on near-black; the border separates instead.
- **No pure black `#000000` surfaces**, except the night-clock dim mode, where
   it is the point.

## Provenance

Surfaces, text ramp, shape scale, motion tiers and sleep-phase colours are
measured from `com.urbandroid.sleep` 20261016. The amber accent, the component
shapes, and the deep-black push are ours. No layout, artwork or copy is
reproduced. See `../reference-interactions.md` for the boundary.