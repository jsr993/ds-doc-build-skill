# Map of the `theme` collection

Taken from the main file `KNEAKDWElVE0JkNi9j0x8S` («Component Spec Kit», the one published
to Community) on 28.08.2026; tier counts re-verified against the file on 29.08.2026.
Collection `theme`, **164 variables**, modes: `lite`, `enterprise`, `engineering`.

Names are a contract. Transfer verbatim, typos included: `size-mono-02 2`,
`letter-spacing-mono-01 2`, `paragraphy-spacing` (not paragraph), `interation` (not interaction).
The geometry group is now named `layers` — it used to be called `space | radius | gap | border`.

---

## The two tiers

The collection splits into two tiers, and the skill treats them differently.

**Primitives** — set as a value in every mode. These are what the skill generates.
**Semantics** — set as an alias onto a primitive. The skill sets the same aliases as `lite`
and invents no new links.

The ratio: 123 primitives and 41 semantic aliases, counted in `lite` — the sample mode
whose scheme the skill copies. (`enterprise` aliases less: it names fonts directly and has
three flattened header variables — see section 2.)

---

## 1. Primitives

### 1.1 Colour — 22

| Variable | `lite` | `enterprise` |
|---|---|---|
| `colors/base/ds-base-primary` | `#030712` | `#f8f8fc` |
| `colors/base/ds-base-secondary` | `#03071299` | `#f8f8fca3` |
| `colors/base/ds-base-tertiary` | `#03071266` | `#f8f8fc52` |
| `colors/base/ds-layer-inverse` | `#d1d5db` | `#1e1b3a` |
| `colors/accent/ds-accent-primary` | → `ds-base-primary` | `#8c71ff` |
| `colors/accent/ds-accent-secondary` | → `ds-base-secondary` | `#8c71ff99` |
| `colors/accent/ds-accent-tertiary` | `#0307121a` | `#8c71ff1a` |
| `colors/layer/ds-layer-01` | `#ffffff` | `#121216` |
| `colors/layer/ds-layer-02` | `#f3f4f6` | `#1a1a1f` |
| `colors/layer/ds-layer-03` | `#e5e7eb` | `#23232b` |
| `colors/border/ds-border-01` | `#ffffff00` | `#2a2a35` |
| `colors/border/ds-border-02` | `#ffffff00` | `#2a2a35` |
| `colors/border/ds-border-03` | `#ffffff00` | `#2a2a35` |
| `colors/section/ds-section-accent` | `#03071203` | `#8c71ff03` |
| `colors/section/ds-section-01` | `#eff1f3` | `#050506` |
| `colors/section/ds-section-02` | `#e7e9eb` | `#0a0a0c` |
| `colors/section/ds-section-03` | `#e1e3e5` | `#252533` |
| `colors/section/ds-section-border-01…03` | `#ffffff00` — transparent | `#252533` |
| `colors/cover/ds-gradient-01` | `#ffffff` | `#8c71ff` |
| `colors/cover/ds-gradient-02` | → `ds-base-primary` | `#ffffff` |

**What this pair teaches.** `base` is the colour of text and icons — three opacity steps of
one tone (100 / 60 / 40 %). `layer` is three surfaces from light to dark. `section` is the
background of the documentation section, a scale separate from `layer`. `border` is transparent
in the light theme (`#ffffff00`) and visible in the dark one: **a border appears where shadows
and lightness separation stop working.** `accent` in `lite` aliases onto `base` — that is,
there is no accent as a separate colour; in `enterprise` it is the violet `#8c71ff`.

### 1.2 Typography — 52

| Group | Variables | Type |
|---|---|---|
| `typography/font-family` | `global-font`, `font-title`, `font-subtitle`, `font-body`, `font-mono` | STRING |
| `typography/weight` | `weight-title`, `-subtitle`, `-body`, `-mono` | FLOAT |
| `typography/size` | `size-title`, `size-subtitle-01…04`, `size-body-01…04`, `size-mono-01`, `size-mono-02 2`, `size-mono-03` | FLOAT |
| `typography/line-height` | the same 12 steps | FLOAT |
| `typography/letter-spacing` | the same 12 steps, `letter-spacing-mono-01 2` included | FLOAT |
| `typography/paragraphy-spacing` | `body-01…04`, `mono-01…03` — 7 | FLOAT |

`lite`: `Inter` throughout (`font-title/subtitle/body` → alias onto `global-font`), mono —
`IBM Plex Mono`, weights 600 / 550 / 500 / 500, `size-title` 48.
`enterprise`: `global-font` is empty, the families are named directly — `Merriweather` for
headings, `Geist` for text, `Geist Mono`; every weight 400, `size-title` 40.

**Conclusion for the skill:** both schemes are legal. One family for everything — alias onto
`global-font`; different families — set them by name, and `global-font` then goes unused.

### 1.3 Shape — 5

| Variable | Type | Both modes |
|---|---|---|
| `shape/ds-shape` | BOOLEAN | `true` |
| `shape/ds-shape-color` | COLOR | → `colors/accent/ds-accent-tertiary` |
| `shape/ds-shape-bg-color` | COLOR | → `colors/layer/ds-layer-02` |
| `shape/ds-shape-size` | FLOAT | `20` |
| `shape/ds-shape-scale` | FLOAT | `0.2` |

The decorative pattern inside cards. Its colours are always aliases, so the shape follows the
theme automatically. The skill touches only `ds-shape`, `-size`, `-scale`.

### 1.4 Geometry — 43 primitives

| Group | Variables | `lite` | `enterprise` |
|---|---|---|---|
| `layers/global/space` | `ds-doc-global-space-01…07` | 64 48 32 24 16 8 4 | 40 40 32 24 16 8 4 |
| `layers/global/radius` | `ds-doc-global-radius-01…03` | 48 24 8 | 32 16 8 |
| `layers/section/radius` | `ds-radius-section-01…03` | 48 48 48 | 24 24 24 |
| `layers/section/border` | `ds-section-border-01…03` | 0 0 0 | 2 1 0.5 |
| `layers/global/gap` | `ds-doc-global-gap-01…07` | 64 32 24 16 12 8 4 | 40 32 24 16 8 4 2 |
| `layers/global/border` | `ds-border-01…03` | 0 0 0 | 2 1 0.5 |
| `paragraph` | `ds-paragraph-gap-h1…h4` | 12 8 4 2 | 8 6 2 0 |
| `layer-03/layer` | `top/left/right/bottom/gap` | 2 4 4 2 4 | the same |
| `layer-03/avatar` | `ds-layer-avatar-size`, `-radius`, `-content-top-bottom`, `-content-right`, `-content-left` | 24 / 4 / … | the same |
| `doc` | `ds-doc-min-width`, `ds-doc-max-width` | 640 / 1024 | the same |
| `doc/header` | `ds-doc-header-min-height` | 248 | 200 |

**What this teaches.** `lite` is airy and round: step 64, no borders. `enterprise` is dense and
strict: step 40, radius down a level, borders from 0.5 to 2. The document width and the small
`layer-03` values are identical across modes — structural constants, not a theme.

The other 33 variables of the `layers` group are the semantic aliases of section 2.

### 1.5 Texts — 9 STRING

`text/ds-name` — the design-system name, **the only string that changes between modes**
(`Lite Design System` / `Enterprise Design System`).

`text/docs-header/<pattern>/title` and `/description` for `changelog`, `specification`,
`interation`, `components` — **identical in every mode**. These are the section names of the
documentation, not a theme. The skill copies them into the new mode verbatim and never
translates them.

---

## 2. Semantics — 41 aliases

The skill sets them exactly as `lite` does. Thirty-three live in `layers` and are listed
below; the other eight sit in their own sections — three typography families (1.2), three
colours (1.1: `accent-primary`, `accent-secondary`, `cover/ds-gradient-02`), two shape
colours (1.3).

| Group | Aliases onto |
|---|---|
| `doc/radius/ds-doc-radius-*` (4 corners) | `global/radius/ds-doc-global-radius-01` |
| `doc/ds-doc-border` | `global/border/ds-border-01` |
| `doc/header/top`, `left`, `right` | `global/space/ds-doc-global-space-01` |
| `doc/header/bottom` | `global/space/ds-doc-global-space-03` |
| `doc/header/gap` | `global/gap/ds-doc-global-gap-01` |
| `doc/header/text-gap` | `global/gap/ds-doc-global-gap-04` |
| `doc/content/top` | `global/space/ds-doc-global-space-03` |
| `doc/content/left`, `right`, `bottom` | `global/space/ds-doc-global-space-01` |
| `doc/content/gap` | `global/gap/ds-doc-global-gap-01` |
| `doc/content/logs-gap` | `global/gap/ds-doc-global-gap-04` |
| `layer-02/layer/top…bottom` | `global/space/ds-doc-global-space-04` |
| `layer-02/layer/gap` | `global/gap/ds-doc-global-gap-02` |
| `layer-02/layer/border` | `global/border/ds-border-02` |
| `layer-02/layer/logs-gap` | `global/gap/ds-doc-global-gap-04` |
| `layer-02/radius/*` (4 corners) | `global/radius/ds-doc-global-radius-02` |
| `layer-03/layer/border` | `global/border/ds-border-03` |
| `layer-03/radius/*` (4 corners) | `global/radius/ds-doc-global-radius-03` |

### The divergence worth knowing

In `enterprise` three semantic variables are **flattened into values**:
`doc/header/bottom` = 16, `doc/header/gap` = 32, `doc/header/text-gap` = 8,
against aliases in `lite`. Most likely a manual header adjustment.

The skill repeats the **`lite`** scheme — it is complete and consistent. A flattened alias
makes the theme deaf to a primitive edit, and there is no reason to repeat that.

---

## 3. What of this is a theme, and what is not

| Not a theme, copied verbatim | Why |
|---|---|
| `text/docs-header/*` (8 strings) | section names of the documentation |
| `ds-doc-min-width`, `ds-doc-max-width` | the page format |
| `layer-03/layer/*`, `layer-03/avatar/*` | small mechanics of the nested layer |
| the aliases `shape/ds-shape-color`, `-bg-color` | the shape follows the theme by itself |

Everything else is a theme, and the skill derives it from the reference.

---

## 4. What changed on 28.08.2026

The owner rebuilt the collection and took the kit apart. Recorded from the file, not from memory.

**The geometry group was renamed:** `space | radius | gap | border` → `layers`. The old path
resolves in no recipe.

**A section branch appeared** — the documentation section got its own tokens instead of one
shared radius:

| Was | Became |
|---|---|
| `global/radius/ds-radius-section` — one | `layers/section/radius/ds-radius-section-01…03` — three |
| — | `layers/section/border/ds-section-border-01…03` — three widths |
| — | `colors/section/ds-section-border-01…03` — three colours |

165 variables in that copy against the previous 157.

**Two patterns were removed from the kit:** `tips-practices` and `microcopy`. Four remain —
`changelog`, `specification`, `interation`, `components`.

**The components were renamed into the path scheme.** The old names do not resolve:

| Was | Became |
|---|---|
| `ds-paragraph` | `ds-doc/specification/paragraph` |
| `ds-doc-component` | `ds-doc/specification/component` |
| `ds-doc-component-state` | `ds-doc/specification/component/state` |
| `ds-log` | `ds-doc/changelog/log` |
| `ds-log-label` | `ds-doc/changelog/log/type` |
| `ds-log-changelog-version` | `ds-doc/changelog/log/version` |
| `ds-log-changelog-date` | `ds-doc/changelog/log/date` |
| `ds-log-designers` | `ds-doc/changelog/log/designers` |
| `ds-doc-interaction` | `ds-doc/interaction/device` and `.../container` — split in two |
| `ds-row` | removed |

Later renamed along with the rest: `ds-doc-header` → `ds-doc/header`, `ds-doc-header-cover` →
`ds-doc/header/cover`, `ds-doc-component-label` → `ds-doc/components/label`, `Name` →
`ds-doc/components/name`. Unchanged: `ds-icon-components` and the `ds-doc/*` patterns themselves.

---

## 5. Reconciliation with the main file, 28–29.08.2026

The sections above are taken from the main file — the one published to Community. Differences
from the copy the map was originally written against:

**164 variables, not 165.** `layers/layer-03/avatar` grew from two variables to five:
`ds-layer-avatar-content-top-bottom`, `-content-right`, `-content-left` were added.

**Two faults in `text/docs-header/`, both repaired on 29.08.2026.** Recorded here because both
are invisible on canvas and both reproduce in any copy of the file taken before that date:

- The header of the `ds-doc/components` pattern — a header instance, node-id `3:1639` — was
  bound to `VariableID:10038:5180` and `10038:5181`. By name they resolved
  (`text/docs-header/components/title` and `/description`), but the collection's `variableIds`
  did not contain them: the variables had been deleted, and the binding kept them alive by
  reference. There is no symptom — the node paints the last known value, and switching the
  mode does not change it. Repaired: the pair was recreated as STRING variables with the values
  `Components` / `Source component` in all three modes, the scopes copied from
  `text/docs-header/specification/title`, the binding reattached through `createVariableAlias`.
- The `text/docs-header/tips-practices/*` strings were orphaned along with the removed
  pattern — deleted by the owner.

Result: exactly four `text/docs-header/` groups for the four patterns — `changelog`,
`specification`, `interation`, `components`. The variable count did not change: minus two
orphans, plus two recreated.

**The components were renamed into the path scheme wholesale** — all twenty live under
`ds-doc/`. For the theme skill this does not matter (it writes into variables, not into
components); `token-usage.md` uses the new names. The token roles did not change: the page is
still `layer-01`, the card `layer-02`, the chip `layer-03`.

**Four patterns:** `changelog`, `specification`, `interation`, `components`.
