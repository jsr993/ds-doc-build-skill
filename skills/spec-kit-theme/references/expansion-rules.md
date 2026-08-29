# From reference to theme

The skill does **not read 164 values off the picture.** What is read off the picture is a
short brief of fourteen decisions; it is then expanded into values by the tables below.

The reason is simple. A model invited to name 164 numbers will name 164 plausible numbers —
and the scale falls apart: the spacing stops being multiples, the sizes stop forming a row,
the layers lose their even step. A fourteen-decision brief the model takes off the picture
honestly, and consistency is provided by the rules, not by attentiveness.

---

## 1. The brief

Exactly these fourteen. More cannot be read off one picture reliably.

| # | Decision | Values |
|---|---|---|
| 1 | `name` | the theme name: the mode name and `text/ds-name` |
| 2 | `scheme` | `light` \| `dark` |
| 3 | `accent` | a hex, or `none` — the accent then aliases onto the base colour |
| 4 | `neutral` | the hex of the darkest neutral (in a dark theme — the lightest) |
| 5 | `contrast` | `soft` \| `normal` \| `high` — the step between layers |
| 6 | `radius` | `sharp` \| `soft` \| `round` |
| 7 | `density` | `airy` \| `normal` \| `compact` |
| 8 | `borders` | `none` \| `hairline` \| `visible` |
| 9 | `fontTitle` | a Google Font |
| 10 | `fontBody` | a Google Font, may equal `fontTitle` |
| 11 | `fontMono` | a Google Font, monospaced |
| 12 | `weights` | `low` \| `medium` \| `high` — the weight contrast |
| 13 | `typeScale` | `compact` \| `normal` \| `display` |
| 14 | `shape` | `off`, or `{ size, scale }` |

Plus the cover gradient — two stops, taken from the reference directly.

**What is never taken off the picture:** the `text/docs-header/*` strings, the document width,
the small `layer-03` values. They are not a theme; they are copied from `lite` verbatim.

---

## 2. How to read the brief off the picture

| Decision | What to look at |
|---|---|
| `scheme` | whether the background of half the frame is light or dark |
| `accent` | the most saturated colour occupying under 10 % of the area |
| `neutral` | the colour of the body text; if it is not purely grey — the theme is warm or cold |
| `contrast` | whether a card's edge is visible against the background without a stroke |
| `radius` | card corners: up to 8 — `sharp`, 8–24 — `soft`, more — `round` |
| `density` | the padding-to-size ratio: over two — `airy`, around one and a half — `normal`, less — `compact` |
| `borders` | whether cards carry a stroke and how visible it is |
| `fontTitle`, `fontBody` | serifs, width, stroke contrast. The exact family is not guessed — the nearest Google Font is picked |
| `weights` | how much heavier the title is than the text |
| `typeScale` | the title size relative to the body |
| `shape` | whether there is a decorative pattern inside cards |

**The honesty rule.** If a trait does not read off the picture — the value is taken from
`lite`, and that is named in the report. An invented decision is worse than an inherited one:
the inherited one is at least consistent with the rest.

---

## 3. The expansion

### 3.1 Geometry

`density` → `global/space` and `global/gap`, seven steps each:

| `density` | space | gap |
|---|---|---|
| `airy` | 64 48 32 24 16 8 4 | 64 32 24 16 12 8 4 |
| `normal` | 48 40 32 24 16 8 4 | 48 32 24 16 12 8 4 |
| `compact` | 40 40 32 24 16 8 4 | 40 32 24 16 8 4 2 |

`radius` → `global/radius` and the section radii:

| `radius` | `ds-radius-section-01…03` | `radius-01` | `-02` | `-03` |
|---|---|---|---|---|
| `sharp` | 8 | 8 | 4 | 2 |
| `soft` | 24 | 32 | 16 | 8 |
| `round` | 64 | 48 | 24 | 8 |

The three section radii take the same value — that is how both shipped modes hold them.

`borders` → `global/border` and `colors/border`; `layers/section/border/ds-section-border-01…03`
repeats `global/border`, and `colors/section/ds-section-border-01…03` repeats `colors/border` —
verified against both shipped modes:

| `borders` | 01 / 02 / 03 | border colour |
|---|---|---|
| `none` | 0 / 0 / 0 | `#ffffff00` — transparent |
| `hairline` | 1 / 1 / 0.5 | the neutral at 12 % |
| `visible` | 2 / 1 / 0.5 | the neutral at 20 % |

`density` → `paragraph/ds-paragraph-gap-h1…h4`:
`airy` 12 8 4 2 · `normal` 10 8 4 2 · `compact` 8 6 2 0.

`ds-doc-header-min-height`: `airy` 248 · `normal` 224 · `compact` 200.

### 3.2 Colour

The neutral scale is built from `neutral`, the accent scale from `accent`.

**Light scheme.** `base-primary` = `neutral`; `-secondary` = the same at 60 %;
`-tertiary` at 40 %. `layer-01` = white, `layer-02` and `-03` — the same white darkened by
the `contrast` step: `soft` 3 %, `normal` 5 %, `high` 8 % per step.
`section-02` = `layer-01`, `section-01` half a step darker, `section-03` a step and a half.
`section-accent` = the accent at 1 %. `accent-tertiary` = the accent at 10 %.
`layer-inverse` = the neutral lightened to 80 %.

**Dark scheme.** Mirrored: `base-primary` = the light neutral, `layer-01` is the darkest, the
steps lighten. `section-01` is **darker** than `layer-01` — the section background sinks below
the surface.

**If `accent` = `none`** — `accent-primary` and `-secondary` are set as aliases onto
`base-primary` and `-secondary`, as in `lite`. The theme then has no separate accent, and that
is legal.

### 3.3 Typography

`typeScale` → the twelve sizes:

| step | `compact` | `normal` | `display` |
|---|---|---|---|
| `size-title` | 32 | 40 | 48 |
| `size-subtitle-01…04` | 26 22 18 16 | 32 24 20 18 | 32 26 22 18 |
| `size-body-01…04` | 13 12 11 9 | 14 12 11 9 | 16 14 12 10 |
| `size-mono-01`, `-02 2`, `-03` | 13 12 11 | 14 12 11 | 16 14 12 |

The line height is computed from the size, not taken as a ladder. Headings — a coefficient of
1.3–1.35, body and mono — 1.45–1.55, everything rounded up to even. An example for `compact`:
title 32 → 38, subtitle 26 22 18 16 → 34 30 26 24, body 13 12 11 9 → 20 18 16 14.

**Why not a fixed ladder.** The first edition of these rules declared the ladder `40 32 30 26 …`
shared by all themes — on the grounds that `lite` and `enterprise` share it. The very first
build on the `compact` scale disproved that: with a subtitle size of 26, a line height of 40
gives a ratio of 1.54, and the block headings fall apart. The ladder matched across the two
modes only because their sizes matched.

`weights`:

| `weights` | title | subtitle | body | mono |
|---|---|---|---|---|
| `low` | 400 | 400 | 400 | 400 |
| `medium` | 500 | 500 | 450 | 450 |
| `high` | 600 | 550 | 500 | 500 |

`letter-spacing` — zeros in all twelve, unless the reference shows explicit letterspacing.
`paragraphy-spacing` repeats `size-body` and `size-mono` one to one.

Families: if `fontTitle` = `fontBody` = `fontMono`, everything is set as an alias onto
`global-font`, as in `lite`. If they differ — `global-font` goes unused and the families are
set by name, as in `enterprise`.

### 3.4 Shape

`shape` = `off` → `ds-shape` = `false`, the size and scale are left alone.
`shape` = `on` → `ds-shape` = `true`, `size` 16–24, `scale` 0.15–0.25.
The shape colours are always aliases; the skill does not set them.

---

## 4. Checks before writing

1. **The families exist.** Each one — through `listAvailableFontsAsync()`, together with the
   style for the needed weight. A family missing — stop with its name; substituting silently
   is forbidden.
2. **Contrast.** `base-primary` on `layer-01` — no lower than 7:1, `base-secondary` — no lower
   than 4.5:1. Failing — shift the neutral's lightness and recompute.
3. **The scales are monotone.** `space`, `gap`, `radius`, `size` decrease strictly. A violation
   is an expansion error.
4. **Completeness.** Exactly 164 variables received a value in the new mode. Fewer — name which.
