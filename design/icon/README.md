# Launcher icon

Source: `rise-icon.json` — a Pixelbolt recipe (24×24, 7 colours).

## Why 24×24

Every Android launcher density is an exact integer multiple, so the pixels stay
crisp with no resampling:

| Density | Scale | Size |
|---|---|---|
| mdpi | 2× | 48 |
| hdpi | 3× | 72 |
| xhdpi | 4× | 96 |
| xxhdpi | 6× | 144 |
| xxxhdpi | 8× | 192 |

The adaptive icon foreground is the same design at 3× (72×72) centred in the
108×108 canvas, which sits exactly inside the 72dp safe zone.

## Regenerating

```bash
npx -y pixelbolt@0.15.0 render design/icon/rise-icon.json --out /tmp/rise-icon
```

Then upscale `rise-icon.png` to each density with nearest-neighbour, and place
the 108×108 foreground/background in `mipmap-xxxhdpi/`.

## Design

A sun rising over a horizon. Palette:

| Key | Hex | Use |
|---|---|---|
| `b` | `#12122A` | background navy (matches the app scaffold) |
| `h` | `#1E1E3C` | ground |
| `s` | `#2A2A50` | horizon edge |
| `r` | `#FFB347` | rays |
| `l` | `#FFE29A` | sun highlight |
| `m` | `#FFC15E` | sun mid |
| `d` | `#FF8C42` | sun deep |

The warm sun against the cool navy is what makes it readable at 48dp; the dark
background keeps the silhouette clear on both light and dark launchers.
