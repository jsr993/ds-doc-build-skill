# What drives what

Taken by traversing the bindings in the `pattern` and `components` sections of file
`7K3kJmoSm6VyrUwsrqCMwX`, 27.08.2026. Answers the question «I change this token — what moves».
Component names below follow the current `ds-doc/*` scheme; the traversal predates the rename,
the bindings do not depend on it.

---

## The point: primitives never look at the canvas

The traversal was taken on a 157-variable collection — before the reconciliation with the main
file, where there are 164. 106 of them were bound to nodes. Not a single variable of the groups
`global/space`, `global/radius`, `global/gap`, `global/border` **is bound directly anywhere**.

That is not an omission but the design. The canvas sees only the semantics — `doc/header/*`,
`doc/content/*`, `layer-02/*`, `layer-03/*` — and those alias onto `global/*`.

Two consequences follow, both of which matter for a theme:

- **An edit to `global` reaches everything** hanging off it, in one move. That is what the tier
  exists for.
- **A flattened alias muffles the edit.** In `enterprise` three header variables are flattened
  into values — an edit to `global/space` will not reach them. Do not repeat this.

---

## Three levels of nesting

The documentation is built as three nested levels, each with its own token set.

| Level | What it is on the page | Background | Padding | Radius | Border |
|---|---|---|---|---|---|
| **page** | the `ds-doc/*` frame itself | `colors/layer/ds-layer-01` | `doc/header/*`, `doc/content/*` | `doc/radius/*` | `doc/ds-doc-border` + `colors/border/ds-border-01` |
| **card** | `ds-doc/specification/component`, `ds-doc/changelog/log` | `colors/layer/ds-layer-02` | `layer-02/layer/ds-layer-content-*` | `layer-02/radius/*` | `ds-layer-content-border` + `ds-border-02` |
| **chip** | `ds-doc/specification/component/state`, `ds-doc/components/label`, the avatar | — | `layer-03/layer/*` | `layer-03/radius/*` | `layer-03` border + `ds-border-03` |

The documentation section that the pages go into is a fourth level, and it sits on
`colors/section/*` plus `layers/section/*` — three radii, three border widths, three border
colours. The patterns do not contain it: the section is created by the documentation build
skill, which is why `colors/section/*` never shows up in the traversal.

---

## Typography: where each step lives

The twelve size steps are not an abstract scale — each has its place.

| Step | Where it is applied |
|---|---|
| `size-title` | **only** the page header title: `Changelog`, `Specification`, … |
| `size-subtitle-01` | block headings inside a page — `ds-doc/specification/paragraph` H1 |
| `size-subtitle-04` | the axis labels of `ds-doc/components/label`, headings in the specification |
| `size-body-01` | **the body text**: descriptions under headings, the header subtitle |
| `size-body-02` | secondary text: state rows, the `ds-doc/components/name` block |
| `size-mono-02 2` | version and date in `ds-doc/changelog/log`, mono rows in the name block |
| `size-subtitle-02`, `-03`, `size-body-03` | spare steps, not met in the patterns |
| `size-body-04`, `paragraphy-spacing-body-*` | bound nowhere |

Size, line height, tracking and weight of one step always travel together: a text node has
`fontSize`, `lineHeight`, `letterSpacing`, `fontWeight`, `fontFamily` bound at once. Changing
the size without the line height is not allowed — the lines would collapse into each other.

Families by role: `font-title` — the page header title. `font-subtitle` — block headings.
`font-body` — all body text. `font-mono` — version, date, utility rows.

---

## Colour: which token is visible where

| Token | Where |
|---|---|
| `base-primary` | body text and icons |
| `base-secondary` | secondary text, captions |
| `base-tertiary` | tertiary: the header subtitle, auxiliary text |
| `accent-primary` | the `ds-doc/components/name` block, the axis labels and their stroke, the `ds-icon-components` icon |
| `accent-secondary`, `-tertiary` | not bound in the patterns; `-tertiary` is available to the shape |
| `layer-01` | the page background |
| `layer-02` | the card background |
| `layer-03` | not met in the patterns — the level is set by padding, not by background |
| `border-01` / `-02` / `-03` | the border of the page / card / chip |
| `cover/ds-gradient-01`, `-02` | the gradient of the header and of `ds-doc/header/cover` |
| `section/*` | the documentation section, outside the patterns |

**The accent is visible in three places.** In `lite` it aliases onto `base-primary`, that is,
the accent does not exist as a phenomenon. Setting an accent in a new theme, you paint the
component name, the axis labels and one icon — and nothing else. That is more modest than it
sounds.

---

## Texts

`text/ds-name` is bound to the **property default** `Chapter#814:13` of the `ds-doc/header`
component — which is why the design-system name shows up in the header of every page by itself.

`text/docs-header/*/title` and `/description` are bound at the property level of the header
**instance** inside each pattern, not on nodes. A traversal over `node.boundVariables` does not
see them — a peculiarity of the traversal, not a sign of disuse.

---

## Shape

`shape/*` drives the `Background Pattern` node inside cards. `ds-shape` switches it on,
`-size` and `-scale` set the geometry, the colours are aliases onto `accent-tertiary` and
`layer-02`.

---

## How to use this when generating a theme

Reverse order: from what is visible on the reference to what to write.

| Seen on the picture | You write |
|---|---|
| the page background | `layer-01`; the section background around it — `section-01/02` |
| cards separated by fill | `layer-02`, the step from `layer-01` set by `contrast` |
| cards separated by stroke | `global/border/ds-border-02` + `colors/border/ds-border-02` |
| rounded cards | `global/radius/ds-doc-global-radius-02` (through `layer-02/radius/*`) |
| a rounded page | `ds-doc-global-radius-01` (through `doc/radius/*`) |
| air between blocks | `global/gap/ds-doc-global-gap-01` (through `doc/content/gap`) |
| page margins | `global/space/ds-doc-global-space-01` (through `doc/header` and `doc/content`) |
| density inside a card | `global/space/ds-doc-global-space-04` (through `layer-02/layer/*`) |
| a large title | `size-title` + `line-height-title` + `weight-title` + `font-title` |
| paragraph text | `size-body-01` and its whole quartet |
| captions and small print | `size-body-02`, `size-subtitle-04` |
| monospaced labels | `size-mono-02 2`, `font-mono` |
| a coloured accent spot | `accent-primary` — but remember: that is only the name, the axis labels and the icon |
| a decorative pattern in a card | `shape/ds-shape` = true, `-size`, `-scale` |

**The rule.** Always write into `global/*`, never into the semantics. The semantics are
aliases; writing into them severs the link and muffles the theme on one node.
