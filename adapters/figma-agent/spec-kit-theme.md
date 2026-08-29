---
name: spec-kit-theme
description: "Builds a new theme for the Component Spec Kit library — the free engine file from Figma Community — from a reference image with the Figma agent: reads the palette, radii, density and typography off the picture, expands them into the 164 variables of the theme collection and adds the result as a separate mode. Use on «build a theme from this reference», «generate a palette», «сделай тему по референсу», «сгенери палитру», «добавь тему в theme»."
---

# A Component Spec Kit theme from a reference — Figma agent build

**This one file is the whole skill.** Derived from the `spec-kit-theme` Claude Code build; the
contract with the `theme` collection is identical, the mechanics are the editor's own.

**The kit and the skills are separate pieces — take what you need.** The `theme` collection
ships with the free Component Spec Kit file from Figma Community
(figma.com/community/file/1666170620013431022/component-spec-kit); themes can also be made by
hand, one mode at a time. This skill automates that and runs right inside Figma. The full
Claude Code version — the collection map, the token-usage map, the six territories, the
expansion tables — lives at github.com/jsr993/component-spec-kit, alongside the companion
`spec-kit-docs`, which assembles the documentation itself.

Input — a reference image and a file with the library. Output — a new mode in the `theme`
variable collection with all 164 variables set.

**A theme is a mode, not a file.** Existing modes (`lite`, `enterprise`, `engineering`) are
never touched: the theme is added alongside, switched with the mode switcher, deleted in one
move. A failed theme costs nothing.

**The report follows the language of the request** — asked in Russian, answer in Russian.

## Inviolable rules

1. **Never touch an existing mode.** Only add a mode and write into it. If a mode cannot be
   created (the plan's mode limit) or a variable value cannot be written — stop and say so;
   never simulate a theme by editing existing modes or nodes.
2. **Variable names are a contract.** Match verbatim, typos included: `size-mono-02 2`,
   `letter-spacing-mono-01 2`, `paragraphy-spacing`, the group `layers`.
3. **What is not a theme is copied from the sample** (`lite`, or the first mode): the
   `text/docs-header/*` strings, `ds-doc-min-width`/`-max-width`, everything under `layer-03`.
4. **Aliases are preserved.** 41 of the 164 variables are aliases in `lite`; the new mode
   repeats that scheme exactly. Flattening an alias into a value kills the theme's response
   to primitive edits.
5. **Fourteen decisions, not 164.** The picture yields a brief; the tables yield the values.
   A model asked for 164 numbers names 164 plausible ones — and the scale falls apart.
6. **What cannot be read is inherited** from the sample and named in the report. Never invented.
7. **Fonts — only Google Fonts available in Figma**, with the style name verified: `Inter` has
   `Semi Bold` with a space, `Geist` has `SemiBold` without. Missing style — nearest one, named.
8. **Write primitives, never semantics.** The canvas sees only the semantic aliases
   (`doc/*`, `layer-02/*`, `layer-03/*`); they point at `global/*`. Values go into `global/*`.

## What the tokens drive

The accent (`colors/accent/*`) paints exactly three things: the component name block, the axis
labels, one icon — a theme that should read «violet» is made through layers and section, not
accent. `layer-01` is the page, `layer-02` the card, `layer-03` the chip. `colors/section/*`
and `layers/section/*` style the documentation section around the pages. There are **no
shadows** — no effect variables exist; levels separate by fill and stroke only.

## Pipeline

```
0 Readiness → 1 Reference and brief → 2 Expansion → 3 Writing the mode → 4 Handover
```

Steps report facts and continue; a report is not a question. Stops: no `theme` collection, no
image, a missing font, a mode that cannot be created.

**0.** Find the `theme` collection; the sample mode is `lite` (or the first). Name the variable
count and the existing modes. No collection — stop: the file carries no library.

**1.** Pick a territory by three questions (below), take its values as the base, refine against
the picture, fill the fourteen decisions. Close with the territory and the whole brief, each
decision marked: off the picture, from the territory, or inherited.

**2.** Expand by the tables below. Run the four checks. A failed check — fix the brief and
expand again; never write a failing expansion.

**3.** Add the mode named after the theme. First carry over from the sample: every alias
(as an alias to the same target) and every «not a theme» value. Then write the theme's
primitives on top — this order, or the carry-over clobbers the computed values. Values of a
new mode do not inherit predictably: set all 164 explicitly.

**4.** Verify all 164 variables have a value in the new mode — an unset one silently renders
with the first mode's value. Report: mode name, the brief with source marks, inherited traits,
font substitutions, how to switch the mode.

## The brief — fourteen decisions

| # | Decision | Values | Read from |
|---|---|---|---|
| 1 | `name` | the mode name and `text/ds-name` | the user, or derive from the reference |
| 2 | `scheme` | `light` \| `dark` | background lightness |
| 3 | `accent` | hex or `none` (then aliases onto base) | the most saturated colour under 10 % of the area |
| 4 | `neutral` | hex of the darkest neutral (lightest in dark) | body text colour |
| 5 | `contrast` | `soft` \| `normal` \| `high` | is a card edge visible without a stroke |
| 6 | `radius` | `sharp` (≤8) \| `soft` (8–24) \| `round` (>24) | card corners |
| 7 | `density` | `airy` \| `normal` \| `compact` | padding-to-size ratio: >2 / ~1.5 / less |
| 8 | `borders` | `none` \| `hairline` \| `visible` | card strokes |
| 9–11 | `fontTitle`, `fontBody`, `fontMono` | Google Fonts | serifs, width, stroke contrast — nearest match, never a guess |
| 12 | `weights` | `low` \| `medium` \| `high` | how much heavier the title is |
| 13 | `typeScale` | `compact` \| `normal` \| `display` | title size relative to body |
| 14 | `shape` | `off` or `{size, scale}` | decorative pattern inside cards |

Plus the cover gradient — two stops, taken from the reference directly.

## Six territories

Pick by three questions: light or dark (dark → 4.2); cards separated by fill (4.1/4.3/4.5) or
frame (4.4/4.6); corners round (4.1/4.5), moderate (4.3), sharp (4.4/4.6). The reference fits
none — take the nearest and name the divergence. A seventh territory is never invented.

- **4.1 Swiss** — light · normal · round · airy · none · high · display · no accent · shape off.
  Inter / Inter / IBM Plex Mono (or Work Sans, Archivo, Public Sans). This is `lite`.
- **4.2 Dark console** — dark · soft · soft · compact · visible · low · normal · accent ·
  shape on. Merriweather / Geist / Geist Mono. This is `enterprise`.
- **4.3 Editorial** — light warm · soft · soft · airy · none · medium · display · no accent ·
  off. Source Serif 4 ×2 / IBM Plex Mono (or Newsreader, Literata, Spectral, Crimson Pro).
- **4.4 Technical** — light or dark · soft · sharp · compact · hairline · low · compact ·
  no accent · off. IBM Plex Mono / IBM Plex Sans / IBM Plex Mono (or JetBrains Mono, Roboto
  Mono). `engineering` sits here, with soft corners and a blue accent as named divergences.
- **4.5 Product soft** — light · soft · round · normal · none · medium · normal · saturated
  accent · shape on. Plus Jakarta Sans ×2 / DM Mono (or Figtree, Outfit, Manrope, Onest).
- **4.6 Hard contrast** — light · high · sharp · normal · visible · high · display ·
  no accent · off. Archivo ×2 / Space Mono (or Sora, Space Grotesk).

## Expansion tables

**Geometry.** `density` → `layers/global/space` and `/gap`, seven steps each:
`airy` space 64 48 32 24 16 8 4, gap 64 32 24 16 12 8 4 · `normal` space 48 40 32 24 16 8 4,
gap 48 32 24 16 12 8 4 · `compact` space 40 40 32 24 16 8 4, gap 40 32 24 16 8 4 2.
Paragraph gaps h1…h4: `airy` 12 8 4 2 · `normal` 10 8 4 2 · `compact` 8 6 2 0.
Header min-height: 248 / 224 / 200.

`radius` → `global/radius` and the three section radii (all three take one value):
`sharp` section 8, radius-01…03 = 8 4 2 · `soft` section 24, 32 16 8 · `round` section 64,
48 24 8.

`borders` → `global/border` 01/02/03 and border colour; `layers/section/border` repeats
`global/border`, `colors/section/ds-section-border-*` repeats `colors/border`:
`none` 0/0/0, transparent · `hairline` 1/1/0.5, neutral at 12 % · `visible` 2/1/0.5,
neutral at 20 %.

**Colour, light scheme.** `base-primary` = neutral; `-secondary` at 60 %; `-tertiary` at 40 %.
`layer-01` = white; `-02`, `-03` darkened per `contrast` step: soft 3 %, normal 5 %, high 8 %.
`section-02` = `layer-01`; `section-01` half a step darker; `section-03` a step and a half.
`section-accent` = accent at 1 %; `accent-tertiary` = accent at 10 %; `layer-inverse` = neutral
lightened to 80 %. **Dark scheme** mirrors: `layer-01` darkest, steps lighten, `section-01`
darker than `layer-01`. **`accent` = none** → `accent-primary`/`-secondary` alias onto
`base-primary`/`-secondary`, as in `lite` — legal.

**Typography.** `typeScale` → sizes (title · subtitle-01…04 · body-01…04 · mono-01/-02 2/-03):
`compact` 32 · 26 22 18 16 · 13 12 11 9 · 13 12 11
`normal` 40 · 32 24 20 18 · 14 12 11 9 · 14 12 11
`display` 48 · 32 26 22 18 · 16 14 12 10 · 16 14 12
**Line height is computed, not a ladder:** titles ×1.3–1.35, body and mono ×1.45–1.55,
round up to even. `weights`: `low` 400 ×4 · `medium` 500 500 450 450 · `high` 600 550 500 500.
Letter-spacing zero everywhere unless the reference shows spacing. `paragraphy-spacing`
repeats `size-body`/`size-mono`. One family for all three roles → alias onto `global-font`
as `lite` does; different families → set by name, `global-font` unused, as `enterprise`.

**Shape.** `off` → `ds-shape` false, size and scale untouched. `on` → true, size 16–24,
scale 0.15–0.25. Shape colours are aliases — never set.

## Checks before writing

1. Every family exists in Figma with the style for its weight (400 Regular, 500 Medium,
   550/600 Semi Bold or SemiBold, 700 Bold). Missing family — stop with its name.
2. Contrast: `base-primary` on `layer-01` ≥ 7:1, `base-secondary` ≥ 4.5:1. Failing — shift
   the neutral and recompute.
3. `space`, `gap`, `radius`, `size` scales decrease strictly.
4. After writing: all 164 variables valued in the new mode; fewer — name which.

## Checklist

1. Existing modes byte-identical — no value of theirs changed.
2. The new mode's name matches `text/ds-name`.
3. All 164 variables valued; the semantic tier is aliases repeating the sample.
4. Section texts, document width, `layer-03` copied verbatim.
5. Families verified, substitutions named.
6. Contrast and monotone scales pass.
7. The report names the territory and marks every decision's source, in the request's language.
