# The style space

What the documentation **can** look like, and what it cannot. The boundaries are set by the
construction: a fixed header, three levels of nesting, one column and a set of 164 variables.

Read before taking a brief off a reference. A reference almost never fits the construction
wholesale — the task is not to copy it but to find the nearest reachable territory and tune
within it.

---

## 1. What is fixed and does not change

| What | How it always is |
|---|---|
| Header composition | three lines top to bottom: the system name, the section title, the subtitle |
| Layout | one column, blocks one under another |
| Page width | from 640 to 1024 |
| Nesting | exactly three levels: page → card → chip |
| Gradient | two stops in the header, nowhere else |
| Decoration | one pattern inside cards, on or off |
| Images | none — no photography, no illustration, no texture |

These are not theme limitations but the shape of the product. A theme lives inside it.

## 2. What can be driven

Six levers; everything else is their consequence.

1. **Lightness** — a light theme or a dark one.
2. **Level separation** — by fill or by stroke. Or both.
3. **Radius** — from zero to 64.
4. **Density** — a grid step from 40 to 64 and everything that depends on it.
5. **Typography** — four roles (title, subtitle, body, mono), weight contrast, the size of the scale.
6. **Accent** — present or not.

## 3. What cannot be achieved

Worth knowing in advance, so as not to promise the impossible.

**There are no shadows at all.** The collection has not a single effect variable. Levels are
separated only by fill and stroke. Unreachable from here: material cards with elevation, glass
surfaces with blur, neumorphism, anything «floating».

**The accent is barely visible.** It paints three places: the component name, the axis labels
and one icon. A theme you want to call «violet» or «green» is made through the layers and the
section, not through the accent.

**There is no colour coding of sections.** Every page is painted the same; there is nothing to
make «changelog green and specification blue» with.

**The size scale is shared.** You cannot give the specification small text and the changelog
large text.

**There are no multi-width layouts.** No two columns, no grids, no tiles.

## 4. Territories

Six reachable characters. The values are given in the brief vocabulary — they can be taken
as they are.

### 4.1 Swiss

A white sheet, no strokes, plenty of air, a large grotesque title. Separation by lightness
only. Closest to what `lite` already is.

`scheme` light · `contrast` normal · `radius` round · `density` airy · `borders` none ·
`weights` high · `typeScale` display · `accent` none · `shape` off

Families: Inter / Inter / IBM Plex Mono. Or Work Sans, Archivo, Public Sans.

### 4.2 Dark console

A dark background, hairline borders instead of lightness steps, a dense grid, even weights.
A serif title over grotesque text. This is `enterprise`.

`scheme` dark · `contrast` soft · `radius` soft · `density` compact · `borders` visible ·
`weights` low · `typeScale` normal · `accent` present · `shape` on

Families: Merriweather / Geist / Geist Mono.

### 4.3 Editorial

Warm paper, serifs, a spacious line height, no strokes, moderate rounding. Documentation that
is read, not scanned.

`scheme` light, neutral warm · `contrast` soft · `radius` soft · `density` airy ·
`borders` none · `weights` medium · `typeScale` display · `accent` none · `shape` off

Families: Source Serif 4 / Source Serif 4 / IBM Plex Mono.
Or Newsreader, Literata, Spectral, Crimson Pro, EB Garamond.

### 4.4 Technical

A monospaced character, sharp corners, hairline borders, dense. Looks like an API reference.

`scheme` light or dark · `contrast` soft · `radius` sharp · `density` compact ·
`borders` hairline · `weights` low · `typeScale` compact · `accent` none · `shape` off

Families: IBM Plex Mono / IBM Plex Sans / IBM Plex Mono.
Or JetBrains Mono, Roboto Mono, Martian Mono for headings.

### 4.5 Product soft

Light, round corners, soft layer steps, one lively accent, the pattern switched on. The
friendliest of the territories.

`scheme` light · `contrast` soft · `radius` round · `density` normal · `borders` none ·
`weights` medium · `typeScale` normal · `accent` present, saturated · `shape` on

Families: Plus Jakarta Sans / Plus Jakarta Sans / DM Mono.
Or Figtree, Outfit, Manrope, Onest.

### 4.6 Hard contrast

Pure black on pure white, zero rounding, thick borders, heavy weights. A poster manner.

`scheme` light · `contrast` high · `radius` sharp · `density` normal · `borders` visible ·
`weights` high · `typeScale` display · `accent` none · `shape` off

Families: Archivo / Archivo / Space Mono. Or Sora, Space Grotesk.

---

## 5. How to pick a territory from a reference

Three questions in order, each cutting the field in half.

1. **Light or dark?** Dark almost always leads to 4.2 — lightness steps do not work on a dark
   background, and borders become mandatory.
2. **What separates the cards — fill or frame?** Fill leads to 4.1, 4.3, 4.5. Frame — to 4.4, 4.6.
3. **What corners?** Round — 4.1 or 4.5. Moderate — 4.3. Sharp — 4.4 or 4.6.

Then typography refines: serifs → 4.3, mono → 4.4, heavy grotesque → 4.6, light → 4.5.

**If the reference fits none — take the nearest and name the divergence in the report.**
Inventing a seventh territory is forbidden: it would assemble from values nobody has checked.

---

## 6. Font families

Verified in Figma on 27.08.2026 — everything listed is available with the needed styles.

**Grotesques:** Inter, Geist, Manrope, Work Sans, IBM Plex Sans, DM Sans, Public Sans, Figtree,
Onest, Archivo, Roboto, Lato, Source Sans 3, Plus Jakarta Sans, Outfit, Karla, Rubik,
Nunito Sans, Mulish. No Medium weight: Space Grotesk, Sora, Open Sans.

**Serifs:** Merriweather, Source Serif 4, Lora, Playfair Display, Libre Baskerville,
IBM Plex Serif, Newsreader, Fraunces, Spectral, EB Garamond, Bitter, Crimson Pro, Literata.
Regular only: Instrument Serif — fine for a title, not for body text.

**Monospaced:** IBM Plex Mono, Geist Mono, Roboto Mono, Source Code Pro, Fira Code,
Inconsolata, Martian Mono. No SemiBold: JetBrains Mono. Regular and Bold only: Space Mono.
Regular and Medium only: DM Mono.

### The trap in style names

The weight name in Figma is written differently across families: for `Inter` it is
**`Semi Bold`** with a space, for `Geist` — **`SemiBold`** without one. The skill verifies the
style through `listAvailableFontsAsync` and never writes a name from memory.

Mapping the number in the variable to the style: 400 → Regular, 500 → Medium,
550 and 600 → Semi Bold (or SemiBold), 700 → Bold. If the needed style is missing — take the
nearest and name the substitution in the report.

---

## 7. Themes built so far

What has already been made on this construction — anchor points for the next ones.

| Mode | Territory | Brief |
|---|---|---|
| `lite` | 4.1 Swiss | light · normal · round · airy · borders none · high · display · no accent |
| `enterprise` | 4.2 Dark console | dark · soft · soft · compact · borders visible · low · normal · accent `#8c71ff` |
| `engineering` | 4.4 Technical | light · soft · **soft** · compact · borders hairline · **500/500/400/400** · compact · accent `#2563eb` |

`engineering` was built by interview on 28.08.2026; the departures from the territory are
highlighted: moderate corners instead of sharp, a blue accent instead of monochrome, the
pattern switched on. Families — JetBrains Mono in headings and IBM Plex Sans in text, the
«mono in headings» variant.
