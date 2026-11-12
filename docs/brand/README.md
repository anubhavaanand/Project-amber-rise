# Art

Every image in this README is generated, not drawn by hand. The recipes are
committed so any of it can be regenerated or tweaked.

| Asset | Size | Frames | What it is |
|---|---|---|---|
| `night.gif` | 128×72 (4×) | 6 | Night panorama: twinkling stars, a shooting star, three hill ridges, pines, a cabin with one amber-lit window |
| `dawn.gif` | 128×72 (4×) | 6 | The same landscape at dawn — warmed palette, no stars |
| `poster.gif` | 256×256 (3×) | 4 | The feature poster: RISE wordmark, tagline, four icon rows. Stars flare and the window glows. |
| `setup.gif` | 256×256 (3×) | 2 | A terminal window with a blinking cursor: `flutter pub get`, `flutter run`, `launch lib/main.dart`, `rising...` |
| `sunrise-bar.svg` | 720×6 | — | The gradient rule, used as the hero divider |

## Regenerating

```bash
npx -y pixelbolt@0.15.0 render docs/brand/night.json --out /tmp/night --gif --gif-scale 4
npx -y pixelbolt@0.15.0 render docs/brand/dawn.json  --out /tmp/dawn  --gif --gif-scale 4
npx -y pixelbolt@0.15.0 render docs/brand/poster-anim.json --out /tmp/poster --gif --gif-scale 3
npx -y pixelbolt@0.15.0 render docs/brand/setup.json --out /tmp/setup --gif --gif-scale 3
```

`validate <recipe>` first — it names every path that is wrong.

## The font

The poster and the terminal use a **5×7 bitmap font** defined in
`docs/brand/font.py` (A–Z, 0–9, and punctuation). pixelbolt's built-in `text`
op does not scale, so glyphs are stamped as grids at an integer scale: the
wordmark is scale 6, the tagline and feature rows scale 2, the terminal
scale 1.

To add a glyph, add its seven 5-character rows to `F` in that file and
re-run the generator.

## Palette

| Key | Hex | Use |
|---|---|---|
| `k` | `#0E1319` | Surface |
| `K` | `#0A0E14` | Terminal body |
| `o` | `#232C36` | Hairlines |
| `w` | `#F2F3F7` | Primary text |
| `v` | `#9AA0AE` | Secondary text |
| `a` | `#FFB347` | Accent |
| `A` | `#FF8C42` | Accent, deep |
| `t` | `#4DB6AC` | Data |
| `T` | `#80CBC4` | Data, light |

These match `lib/theme/app_theme.dart`. If you change one, change it in both.