# The `ds-*` engine — map, keys, build rules

The engine ships as a Figma file: the user duplicates it, or publishes it and attaches it as a
library. **The skill is not tied to any particular file.**

Read from the source file `KNEAKDWElVE0JkNi9j0x8S` on 2026-08-28. Pages: `information`,
`example `, `component kit`, `cover`, plus two `---` separators. Page and section names are
informative; the skill finds components by name over the whole document.

---

## Library

The engine is recognised by its **`theme`** variable collection — in an attached library
(named «Component Spec Kit» by default) or locally in the file. The library name is a hint,
not a condition: the owner may rename the file, a user may publish their own copy.

The collection ships three modes — `lite`, `enterprise`, `engineering`. **A mode is a theme.**
The skill never writes into the collection; it reads header strings from it and binds section
styling to it. Whichever mode is active is the theme the documentation appears in.

`figma.teamLibrary.getAvailableLibraryVariableCollectionsAsync()` returns collections with
`name` and `libraryName`. A `theme` collection present — proceed, and name the `libraryName`
in the report. Several — stop and ask which is the engine. None, but the file holds local
`ds-doc/*` components and a local `theme` collection — a duplicate of the template: proceed,
but warn. Neither — stop and ask the human to attach the library.

**A library cannot be attached from code.** Components and variables publish separately: a
library that ships components with its `theme` collection hidden imports components fine and
then stops the build at section styling.

## How to find the engine

| Engine | Method |
|---|---|
| local in the file | by **exact name**, `findAllWithCriteria({ types: ["COMPONENT","COMPONENT_SET"] })` |
| attached as a library | **only by `key`** via `importComponentByKeyAsync` / `importComponentSetByKeyAsync` |

**Attached-library components cannot be found by name** — the Plugin API does not enumerate
them. Key import is the only way.

### Names are the contract

Every engine component lives under the `ds-doc/` path. Matching is **exact** — no prefix
matching, no case folding, no trimming. The typo `ds-doc/interation` is part of the contract.

```
ds-doc/changelog          ds-doc/specification      ds-doc/interation
ds-doc/components         ds-doc/header             ds-doc/header/cover
ds-doc/specification/paragraph      ds-doc/specification/component
ds-doc/specification/component/state
ds-doc/components/name    ds-doc/components/label   ds-doc/components/component-type
ds-doc/changelog/log      ds-doc/changelog/log/type ds-doc/changelog/log/version
ds-doc/changelog/log/date ds-doc/changelog/log/designers
ds-doc/changelog/log/designers/avatar
ds-doc/interaction/device ds-doc/interaction/container
```

Twenty components. **Renaming any of them breaks the build in every copy at once.** A node not
found — stop and return three lists: expected, found, missing.

Property names and their suffixes (`Title#814:6`, `Show Desciption#757:0`) survived the
renaming and remain the contract, typo included. Resolve them by the prefix before `#`.

---

## 1. Page patterns — four

The skill builds three. `interation` is assembled by hand: its content cannot be derived from
a component.

| Pattern | key | Header `Title` in the source file |
|---|---|---|
| `ds-doc/changelog` | `8e1ca46510f8740291001b88c72178bf521b40ad` | `Changelog` |
| `ds-doc/specification` | `5160fc2ef46a7483a054a5b52fc42977a9653e0d` | `Specification` |
| `ds-doc/components` | `d7928d8e2aea2f725047487958f42e819269fb72` | `Components` |
| `ds-doc/interation` ¹ | `02a5afce1a1c9fc3cb6917f56739ac1738fcb2f2` | `Interaction` — **manual only** |

¹ typo in the original name; write it verbatim.

`tips-practices` and `microcopy` **no longer exist** — those patterns were removed from the kit.

Each page: `Header` (an instance of `ds-doc/header`) + `Content`. On `ds-doc/components`
`Content` is a public SLOT (`Content#10010:6`); on the other three it is a plain frame, which
is why they must be detached.

### `ds-doc/header`

key `b8bdac5b67d2df799fd2b2c1e2acf1126afabf19`. **Never touch it.**

| Property | Bound to |
|---|---|
| `Chapter#814:13` | `text/ds-name` — bound on the component default, so the design-system name appears by itself |
| `Title#814:6` | `text/docs-header/<pattern>/title` — bound per pattern, on the header **instance** |
| `Description#10010:16` | `text/docs-header/<pattern>/description` — likewise |

`ds-doc/header/cover`, key `3a434300661b9230d1addd25a23d9e9568c2861a` — decoration inside the
header, carries the two-stop gradient.

**Repaired in the source file, 2026-08-29.** `text/docs-header/` now holds exactly four groups
for the four patterns — `changelog`, `specification`, `interation`, `components`.

Worth knowing, because the fault reproduces in any copy taken before that date and shows no
symptom. The header instance of `ds-doc/components` (node `3:1639`) was bound to
`VariableID:10038:5180` and `10038:5181`: those resolve **by name** to
`text/docs-header/components/title` and `/description`, but were absent from the collection's
`variableIds` — deleted variables kept alive by the reference alone. The node keeps painting the
last known value and stops answering a mode switch, so nothing looks wrong. The fix is to
recreate the pair, copy the scopes from `text/docs-header/specification/title`, and rebind
through `createVariableAlias`.

In an old copy the frame-name rule still copes — an unresolved `Title` reads as the literal
`Components`, which is correct — so this is a report line, not a stop.

---

## 2. Atoms

| Component | key | Variants and properties |
|---|---|---|
| `ds-doc/specification/paragraph` | `79e003706a90e4138c5f524e66a8f109d414497b` | `Type`: `H1\|H2\|H3\|H4`; `Title#25618:5`, `Description#25618:0`, `Show Title#25618:15`, `Show Description#25618:10` |
| `ds-doc/specification/component` | `68105279d106fe791d4dc3d46568980b628c7f49` | `Type`: `Structure\|State\|Device`; `Title#120:0`, `Show Title#120:3`, `Description#757:3`, `Show Desciption#757:0` ¹, slots `Slot Structure#8012:6`, `Slot State#10006:0`, `Slot Device#10006:7`, `Show iPhone 16 Graphite#10006:11` |
| `ds-doc/specification/component/state` | `c15f42829046ab814e93e806e67320a695fe9e24` | `Position`: `Horizontal\|Vertical`; `Type#29447:1`, `Description#422:0`, `Show Description#422:3`, `Slot#8012:3` |
| `ds-doc/components/name` | `c386cdaba450f37d5125b5c8fa99157a1f101e3e` | `Name Component#10010:1` |
| `ds-doc/components/label` | `9382174b65c42d4812ca813248629a29ade63ed1` | `Label#29891:0`; `Large`: `False\|True`; `Vertical`: `False\|True` |
| `ds-doc/components/component-type` | `47948be66d44d8f9aa7eba23229e55558a60a8a8` | `Type`: `Component\|Fix` — marker icon |
| `ds-doc/interaction/device` | `391b134517ab4d0e7d068ac1abcd3d90b1ea5396` | phone frame, manual page only |
| `ds-doc/interaction/container` | `dfad1c8d70e98ad880a32d22886de1542326c748` | plain container, same page |

¹ typo in the property name.

`Type` on `ds-doc/specification/component`:

| Type | Live slot | What goes in | Demo child |
|---|---|---|---|
| `Structure` | `Slot Structure` | anatomy or one configuration | a plain frame |
| `State` | `Slot State` | N `.../component/state` rows | instances of that same component |
| `Device` | `Slot Device` | a scenario inside the phone frame | a plain frame |

The kind of demo child decides which slot-clearing recipe applies — see `build-recipes.md`,
recipe 5. Guessing wrong costs a failed call.

---

## 3. Changelog atoms

| Component | key | Properties |
|---|---|---|
| `ds-doc/changelog/log` | `65f3f839c5cdf8b8daed1cc04bd33de7e4edda0c` | `Description#12479:2`, `Show Description#29:1`, `Designers#10010:0` (SLOT), `File#10010:7` (SLOT), `Show File#10010:8` |
| `ds-doc/changelog/log/version` | `e798cdef2dfda2967007f36c74f96b7a65723f4e` | `Major#30279:0`, `Minor#30279:1`, `Patch#30279:2` |
| `ds-doc/changelog/log/date` | `e629f33c644136be9e7defcbbe67d3835042620f` | `Day#1521:0`, `Month#1521:1`, `Year#1521:2` — two-digit year |
| `ds-doc/changelog/log/type` | `30806cc479bb6bf49590399fea3717be15d58aae` | `Type`: `New \| Changed \| Fixed` |
| `ds-doc/changelog/log/designers` | `8bc09f0b16c91483e6fb2b728fdcbafec8980933` | `Designer#1823:10` |
| `ds-doc/changelog/log/designers/avatar` | `bf3e9600e95c76537cfa60982c3f776be79d24d7` | `designer`: `zhasur \| elena` — **new**: the avatar became a variant set |

The `Designers` slot takes any number of children, one per person. Clear it with a `remove()`
loop — `resetSlot()` restores the demo. In autonomous mode the skill **does not touch it**:
the component default stays, and the avatar set means a wrong name now also shows a wrong face.

---

## 4. The component page — `ds-doc/components`

```
Name Component                          ← frame
├── Background Pattern                  ← decoration, driven by shape/*
├── ds-doc/components/name              ← instance: name + version + type icon
└── Component                           ← layoutMode GRID
    ├── Horizontal Props                ← Line[0] axis name, Line[1] values
    ├── Slot Component                  ← ONE node: the component set itself
    └── Vertical Props                  ← one Line per nesting level
```

One block per component, one node in the slot, labels verbatim.
**Axis order comes from the set geometry**, not from property declaration order: cluster the
variants by `x` for columns and by `y` for the vertical levels, outermost first, and take
bracket heights from the cluster heights.

---

## 5. The documentation SECTION

The section grew its own tokens, three tiers of each. **Tier = nesting**: a component's
documentation section uses `-01` throughout, a family section wrapping several component
sections uses `-02` throughout. One section never mixes tiers.

| Property | Variable (tier 01) |
|---|---|
| radius, four corners | `layers/section/radius/ds-radius-section-01` |
| bottom fill | `colors/section/ds-section-01`, opacity 1 |
| top fill | `colors/section/ds-section-accent` — the accent film, ~1 % (3/255 in the source file) |
| stroke colour | `colors/section/ds-section-border-01`, opacity 1 |
| stroke weight | `layers/section/border/ds-section-border-01` — bound |

Border weight and colour are themed: in `lite` the weight resolves to `0` and the colour is
transparent, so the section reads as a plain fill; in `enterprise` and `engineering` a border
appears. **Bind, never set by value** — a hardcoded weight paints a border in themes that have
none. The fill opacities are the only structural constants left; copy the accent opacity from
a finished section when one exists.

Found in the field, 2026-08-29: the example sections in the source file bind the stroke
**colour** to the section fill (`ds-section-01`/`-02`) instead of
`colors/section/ds-section-border-*`. The owner's rule is the border token — against the fill
colour a border vanishes into its own background in `enterprise`. Report it, bind the border
token in your own section.

Layout: 100 padding on all sides, pages left to right with a 200 step, fitted with
`resizeWithoutConstraints` as the last step.

---

## 6. The detach rule

`ds-doc/changelog`, `ds-doc/specification` and `ds-doc/interation` expose no properties and no
slots — new children cannot go inside an instance. Order: `createInstance()` →
`detachInstance()` → rename the frame to the header `Title` → clear `Content` → fill.

Atoms stay instances. Only the page wrapper detaches.
`ds-doc/components` does not require a detach — its `Content` is a public slot — but
detaching it is equally legal and is what the reference build did: the name block, the axis
lines and the set move are deep subtree surgery, and on real nodes none of the live-instance
slot traps apply.

---

## 7. Tokens and fonts

All visuals come from the `theme` collection — 164 variables, two tiers. Primitives
(`colors/*`, `typography/*`, `layers/global/*`, `layers/section/*`, `shape/*`) carry values per
mode; the semantic tier (`layers/doc/*`, `layers/layer-02/*`, `layers/layer-03/*`) is aliases
onto them. **Nothing on the canvas binds to `layers/global/*` directly** — that tier reaches
the page only through the aliases, which is why editing a primitive restyles everything and
breaking an alias silences it.

The skill never writes into `theme`. It reads header strings and binds the section.

Fonts differ per mode: `lite` runs on Inter, `enterprise` on Merriweather and Geist. Harvest
the actual fonts from engine nodes with `getStyledTextSegments(["fontName"])` and load those —
never a hardcoded list, and reload them in every writing call. Style names differ between
families: `Inter` has `Semi Bold`, `Geist` has `SemiBold`.

---

## 8. Naming defects

Search verbatim; correct only in report text.

| In Figma | Correct |
|---|---|
| `ds-doc/interation` | interaction |
| `Show Desciption#757:0` | Description |
| `text/docs-header/components/*` | present since 2026-08-29; absent in older copies of the file |
