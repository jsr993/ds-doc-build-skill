# The `ds-*` engine — map, keys, build rules

The engine ships as a Figma file: the user duplicates it and builds documentation in their copy, or publishes it as a library and attaches it to another file. **The skill is not tied to any particular file.**

File pages as of 2026-08-12: `component kit` (the engine: section `pattern` — page templates, section `components` — atoms with subsections `paragraph`, `component`, `logs`), `information` (the guide inside the file: frames `Information` and `Claude Code`), `example ` (generation 1.0 demo components — note the trailing space in the page name).

**Page and section names are informative, not contractual.** The skill finds components by name over the whole document (`findAllWithCriteria`), not by location, so reordering or renaming pages breaks nothing. The contract is only the `ds-*` component names and their properties. The list above exists so a human knows where things are, nothing more.

## Library

The default published name of the engine library is **«Component Spec Kit»**. Without its components no documentation gets built.

**The engine is recognised by its `decoration` variable collection, not by library name.** The name is a hint: the owner may rename the file, a user may publish their own copy under their own name. Tying the check to a name string would turn both legitimate scenarios into breakage.

Check before everything else: `figma.teamLibrary.getAvailableLibraryVariableCollectionsAsync()` returns collections of attached libraries with `name` and `libraryName` fields. A `decoration` collection present — proceed, and name the `libraryName` in the report. Several — stop and ask which one is the engine. None, but the file holds local `ds-*` and a local `decoration` — that is a duplicate of the template file: proceed, but warn. Neither — stop and ask the human to attach the library via `Assets` → `Libraries`.

**A library cannot be attached from code** — the Plugin API cannot do it.

**Publishing note:** components and variables publish separately. A library that ships components but whose `decoration` collection is hidden from publishing imports components fine and then stops the build at section styling — nothing to bind to.

## How to find the engine

| Engine | Method |
|---|---|
| local in the file | by **exact name**, walking pages: `findAllWithCriteria({ types: ["COMPONENT", "COMPONENT_SET"] })` |
| attached as a library | **only by `key`** via `importComponentByKeyAsync` / `importComponentSetByKeyAsync` |
| the source file itself | node-id as a fast path |

**Attached-library components cannot be found by name.** The Plugin API does not enumerate them: they are not physically in the file, a page walk returns nothing. Key import is the only way.

The keys below are from the owner's library. A user who published **their own** copy gets different ones: ask them once to drag any `ds-doc/*` from `Assets` onto the canvas, read `instance.mainComponent.key`, and proceed from that, keeping harvested keys in build memory.

### Names are the contract

Name matching is **exact** — no prefix matching, no case folding, no trimming. The engine typo `ds-doc/interation` is part of the contract; write it verbatim.

The canonical search list:

```
ds-doc/changelog          ds-doc/specification      ds-doc/interation
ds-doc/tips-practices     ds-doc/microcopy          ds-doc/components
ds-doc-header             ds-paragraph              ds-doc-component
ds-doc-component-state    ds-doc-component-label    Name
ds-log                    ds-log-designers          ds-log-changelog-version
ds-log-changelog-date     ds-log-label
```

**Renaming an engine component breaks the build.** That is a deliberate choice in favour of predictability: matching on the `ds-` prefix would catch the user's own components. A node not found — do not look for similar names and do not substitute a stand-in. Stop and return: which names were expected, which were found, which are missing, and that the probable cause is a rename or a missing engine.

The engine file itself must carry a warning about this (see «Warning inside the file» below).

Node-ids and keys in the tables below are from the source file. **Keys differ in a copy**: publishing from a new file makes Figma issue new ones. Node-ids survive duplication, but must never be the only path. Cache resolved nodes within a build; never hardcode them.

Property suffixes (`#814:6`) may also differ in a copy — resolve by prefix (`build-recipes.md`, recipe 0).

### Warning inside the file

The engine file must carry a note for whoever duplicates it. Text for the cover:

> **Do not rename the `ds-*` components.** The documentation build skill finds them by exact name. Renaming breaks the automated build — documentation will stop assembling.
>
> What you can and should change is different: the values of the `decoration` collection variables — typography, colours, accents, radii, spacing. All documentation visuals redraw from them.

The library owner's job, not the skill's: the skill never edits the engine file.

## Visual customisation

All engine visuals — typography, colours, accents, radii, spacing — live in the `decoration` variable collection. The user changes values there and the documentation redraws wholesale. That is the library's core mechanism.

Hence two prohibitions for the skill:

- **Never set visuals on documentation nodes.** No `fills`, `fontSize`, `fontName`, `cornerRadius`, `strokeWeight` on created nodes. Everything arrives from the engine through variable bindings; a hand-set value overrides the theme and stops following it.
- **Never write into `decoration`.** Variable values are the user's territory. The skill only reads, and only the variables needed to read header text.

Find the collection by the name `decoration` (`figma.variables.getLocalVariableCollectionsAsync()`), never hardcode its id. The collection is multi-mode (`theme v1|v2|v3`) — same variable names, different values; the skill binds the variable and Figma resolves the value for the active mode.

Geometry that must be set anyway (container padding, block spacing) — **copy from neighbouring engine nodes**, never write as a number: `slot.paddingLeft = hp.paddingLeft`, `group.itemSpacing = existingGroup.itemSpacing`. Then layout travels with the theme.

---

## 1. Page patterns (section `pattern`)

The documentation frame name comes from that page's header `Title`, never from a fixed list. The column below shows `Title` values in the source file; a copy has different ones if the user changed the `ds-title-description/*/title` variables.

| Pattern | node | key | Header `Title` |
|---|---|---|---|
| `ds-doc/changelog` | `7:454` | `8e1ca46510f8740291001b88c72178bf521b40ad` | `Changelog` |
| `ds-doc/specification` | `7:456` | `5160fc2ef46a7483a054a5b52fc42977a9653e0d` | `Specification` |
| `ds-doc/interation` ¹ | `905:3416` | `02a5afce1a1c9fc3cb6917f56739ac1738fcb2f2` | `Animated` |
| `ds-doc/tips-practices` ² | `7:466` | `6688d10673b2f0679fb966d0e3eba80b12158019` | `Tips and practices` |
| `ds-doc/microcopy` ² | `7:467` | `b3cfefd67fd64339295aff67f912da7e14befc82` | `Microcopy` |
| `ds-doc/components` | `7:468` | `d7928d8e2aea2f725047487958f42e819269fb72` | `Components` |
| `ds-doc-header` | `814:2666` | `b8bdac5b67d2df799fd2b2c1e2acf1126afabf19` | every page's header |
| `ds-doc-header-cover` | `1026:2423` | `3a434300661b9230d1addd25a23d9e9568c2861a` | decor, do not touch |

¹ a typo in the original's name — when searching, write `ds-doc/interation` verbatim.
² `interation`, `tips-practices` and `microcopy` are **not part of the automated build** (their content cannot be derived from a component — only written by an author). The patterns stay in the engine and are assembled by hand; their absence from the build is by design, not an omission.

All patterns except `ds-doc/components` **have no public properties**. The single public slot is `Content#10010:6` on `ds-doc/components`. Hence the detach rule (section 6).

Each page: `Header` (a `ds-doc-header` instance) + `Content` (auto-layout).
Width 640 for text pages; `ds-doc/components` sizes to content.

### `ds-doc-header`

**Never touch the header.** All three properties in the patterns are pre-filled and bound to string variables in the `decoration` collection. Edit the variable value, never override the instance.

| Property | Type | Value in the pattern | Variable |
|---|---|---|---|
| `Chapter#814:13` | TEXT | `/ Brand Design System` | `ds-system` |
| `Title#814:6` | TEXT | the **section** name: `Changelog`, `Specification`, `Animated`, `Tips and practices`, `Microcopy`, `Components` | `ds-title-description/<pattern>/title` |
| `Description#10010:16` | TEXT | the section subtitle | `ds-title-description/<pattern>/description` |

The component name is **never substituted** into the header: `Title` is the documentation section name, identical for every component. The component name lives in the Specification lead and in the `Name` block on the `Components` page.

A constraint verified experimentally: a variable bound to a component property **does not survive `detachInstance()`** of the header itself — the text bakes to static. Only a binding on a text layer's `characters` survives. Property-level binding is the accepted state; a full header detach loses the link.

---

## 2. Text atoms

| Component | node | key | Properties |
|---|---|---|---|
| `ds-paragraph` (set) | `3:1246` | `79e003706a90e4138c5f524e66a8f109d414497b` | `Type`: `H1\|H2\|H3\|H4`; `Title#25618:5`, `Description#25618:0`, `Show Title#25618:15`, `Show Description#25618:10` |

Inside patterns `ds-paragraph` appears under the instance name `ds-doc-paragraph` — same component.

Practice from the demo content: the first Specification block is a `ds-paragraph` with `Show Title=false` and description only. That is the page lead. Blocks with headings follow.

---

## 3. `ds-doc-component` — the illustration container

`3:1240`, key `68105279d106fe791d4dc3d46568980b628c7f49`.

| Property | Type | Default |
|---|---|---|
| `Type` | VARIANT | `Structure` \| `State` \| `Device` |
| `Title#120:0` / `Show Title#120:3` | TEXT / BOOL | `Title` / true |
| `Description#757:3` / `Show Desciption#757:0` ¹ | TEXT / BOOL | `Description` / true |
| `Slot Structure#8012:6` | SLOT | — |
| `Slot State#10006:0` | SLOT | — |
| `Slot Device#10006:7` | SLOT | — |
| `Show Background Pattern#10006:3` | BOOL | true |
| `Show iPhone 16 Graphite#10006:11` | BOOL | true |

¹ a typo in the property name.

| Type | Live slot | Purpose | What goes in |
|---|---|---|---|
| `Structure` | `Slot Structure` | anatomy, example, configuration | a component instance or a group with callouts; `Title` = block name, `Description` = caption |
| `State` | `Slot State` | states table | N `ds-doc-component-state` instances; hide `Title`/`Description` |
| `Device` | `Slot Device` | scenario in a phone frame | an instance/composition; the `iPhone 16 Graphite` frame is decor |

### `ds-doc-component-state`

`3:1259`, key `c15f42829046ab814e93e806e67320a695fe9e24`.

| Property | Type | Default |
|---|---|---|
| `Type#29447:1` | TEXT | `State name` → the value name |
| `Description#422:0` | TEXT | `Description` |
| `Show Description#422:3` | BOOL | **false** |
| `Slot#8012:3` | SLOT | the value preview |
| `Position` | VARIANT | `Horizontal` \| `Vertical` |

The description is off by default. Turn it on only for real text.

---

## 4. The component page — `ds-doc/components`

Public slot `Content#10010:6`. One block's structure:

```
Name Component                        ← frame
├── Name                              ← instance: Name Component#10010:1 = component name
│                                        + ds-log-changelog-version = current version
└── Component                         ← layoutMode GRID, 2×2
    ├── Horizontal Props
    │   ├── Line[0] → 1 × ds-doc-component-label (Large=True)   = the X axis NAME
    │   └── Line[1] → N × ds-doc-component-label                = the X axis VALUES
    ├── Vertical Props                                          ← HORIZONTAL, one Line per level
    │   ├── Line   → level 1 (Vertical=True)
    │   ├── Line   → level 2
    │   ├── Line   → level 3
    │   └── Frame  → the innermost level: one Line per row block
    └── Slot Component                                          = ONE node — the component itself
```

`Component` is a canvas grid (`layoutMode: "GRID"`), so never build it from scratch: detach the page and reuse the ready-made block.

| Component | node | key | Properties |
|---|---|---|---|
| `Name` | `10010:10004` | `c386cdaba450f37d5125b5c8fa99157a1f101e3e` | `Name Component#10010:1` |
| `ds-doc-component-label` (set) | `3:1318` | `9382174b65c42d4812ca813248629a29ade63ed1` | `Label#29891:0`; `Large`: `False\|True`; `Vertical`: `False\|True` |

Build rules:

1. **One `Name Component` block per component.** Never split into blocks per axis pair. If the entity spans several component sets — name them with a slash (`<Entity> / <Role>`), one block each, still one frame per block.
2. `Slot Component` receives **one node** — the component itself with all variants in its native layout. Never a spread of N instances the skill laid out. The page is called `Source component` for exactly this reason.
3. `Horizontal Props` is the horizontal axis: `Line[0]` = the axis name (`Large=True`), `Line[1]` = its values.
4. `Vertical Props` — **several `Line`s, one per nesting level.** Each next level subdivides the previous; the hierarchy reads from bracket height: a label spanning two others is their parent. All labels `Vertical=True`; the major level `Large=True`, auxiliary `Large=False`. The innermost level is a nested frame with label groups, one per row block.
5. The top level may not be a component axis at all — a theme mode (`Light` / `Dark`), for example.
6. Label captions are verbatim VARIANT values. Never translate, never rename.
7. The level column order is the library owner's. The skill mirrors the component's actual layout rather than imposing its own.

Written shape: horizontal — one axis with its values; vertical — N levels, each subdividing the previous; the slot holds the single component node.

---

## 4a. The documentation SECTION

The section is part of the visual system, not a bare container. The skill must style it — by `decoration` bindings only.

| Property | Value | Variable |
|---|---|---|
| radius, all four corners | 64 | `space/global/radius/ds-radius-section` |
| fill 1 (bottom) | opacity 1 | `color/section/ds-section-02` |
| fill 2 (top) | opacity 0.01 | `color/section/ds-section-01` |
| stroke | opacity 0.4, weight 1, align `INSIDE` | `color/ds-tertiary` |

Numbers in the «value» column are what the variable currently resolves to; **never set them directly**, binding only. The opacities (`1`, `0.01`, `0.4`), stroke weight and alignment are not variable-covered — they are structural engine constants, set by value.

### Layout inside the section

- 100 padding from the section edge to content on all four sides;
- pages go **left to right in build order**, 200 between them;
- when the build completes, the section **fits to content**: size = child bounds plus the padding on each side.

`SECTION` has no auto-layout and never hugs — fit it explicitly with `resizeWithoutConstraints` as the last step, once every page is built and heights are final.

If the file already holds a finished documentation section, copy these settings from it instead of the table: the owner's edits then carry over automatically.

---

## 5. `ds-log` — the change history

| Component | node | key | Properties |
|---|---|---|---|
| `ds-log` | `3:1197` | `65f3f839c5cdf8b8daed1cc04bd33de7e4edda0c` | `Description#12479:2`, `Show Description#29:1` (true), `Designers#10010:0` (SLOT), `File#10010:7` (SLOT), `Show File#10010:8` (false) |
| `ds-log-changelog-version` | `3:1222` | `e798cdef2dfda2967007f36c74f96b7a65723f4e` | `Major#30279:0`, `Minor#30279:1`, `Patch#30279:2` — default `0.0.0` |
| `ds-log-changelog-date` | `10010:9403` | `e629f33c644136be9e7defcbbe67d3835042620f` | `Day#1521:0`, `Month#1521:1`, `Year#1521:2` — default `15.08.26`, two-digit year |
| `ds-log-label` (set) | `3:1189` | `30806cc479bb6bf49590399fea3717be15d58aae` | `Type`: `New` \| `Changed` \| `Fixed` |
| `ds-log-designers` | `10010:9177` | `8bc09f0b16c91483e6fb2b728fdcbafec8980933` | `Designer#1823:10` — default `Zhasur Eshmirzaev` |

```
ds-log
├── Version                                   ← HORIZONTAL
│   ├── Version → ds-log-changelog-version     = Major.Minor.Patch
│   └── Date    → ds-log-changelog-date        = Day.Month.Year
├── Text Container
│   ├── Label → ds-log-label                   = change type
│   ├── Description                            = the entry text
│   └── File   (SLOT)                          = artefacts for the entry
└── Designers  (SLOT)                          = participants, HORIZONTAL
```

Set version and date through properties, never by editing text layers. The «type → version» rule lives in `SKILL.md`, 6.1.

`Designers`: `slotSettings.displayEmptyByDefault = false`, no `minChildren`/`maxChildren` → participant count unlimited. The slot ships with one demo instance; clear with a `remove()` loop — `resetSlot()` brings the demo content back. The `✱ Image` 24×24 layer inside `ds-log-designers` is the avatar; do not change it.

`File`: sits inside `Text Container` under the description, HORIZONTAL, empty. Never fill it; `Show File` stays `false`.

---

## 6. The detach rule

`ds-doc/specification`, `changelog`, `interation`, `tips-practices` and `microcopy` have no slots and no properties. New children cannot go inside an instance, and the number of documentation blocks is unknown in advance.

Order:

1. `createInstance()` from the pattern.
2. `detachInstance()` → a `FrameNode` with tokens, spacing and radii preserved.
3. Rename the frame to the header `Title` value (see `SKILL.md`, G3).
4. `Header` inside stays a `ds-doc-header` instance — edit through `setProperties` only, and per rule 4 do not edit it at all.
5. Clear `Content` of demo blocks and fill it with your own atom instances.

The atoms (`ds-paragraph`, `ds-doc-component`, `ds-log`, `ds-doc-component-label`, `Name`) **stay instances**. Only the page wrapper detaches.

`ds-doc/components` needs no detach — it has the public `Content#10010:6`. But slot content is set by **adding children** to the slot node, never through `setProperties` (see `build-recipes.md`).

---

## 7. Auxiliary nodes

| Node | node | key | Status |
|---|---|---|---|
| `ds-row` | `756:986` | `0ae4951b5ecdfdec85cd21c15f49e19eabb5ae90` | 16×16, grid helper |
| `ds-icon-components` (set) | `3:1470` | `47948be66d44d8f9aa7eba23229e55558a60a8a8` | `Type`: `Component` \| `Fix` — a marker |
| `ds-doc-interaction` (set) | `10006:17399` | `7587f680e04f7fc403452dd116b1278c73a1f2e8` | `Type`: `Device` \| `Container`, slots `Slot Interaction#10006:25`, `Slot Device Interaction#10006:28`. **Not used by `ds-doc`** — the `interation` page is built on `ds-doc-component Type=Device`. Do not use without the owner's decision. |
| `ds-format-component-head` / `-footer` | — | — | generation 1.0, found only on `example `. Do not use. |

---

## 8. Tokens and fonts

Engine tokens in the source file: `space/doc/header/*`, `space/doc/content/*`, `space/container-01…03/{container,radius}/*`, `color/ds-{primary,secondary,tertiary,layer-01,layer-02,brand-primary}`, `typography/*`, styles `ds-title`, `ds-body-01…03`. Names may differ in a copy — the skill neither sets nor validates them.

These are **documentation** tokens. They never enter the component contract; component tokens are read only from instances inside slots.

Load fonts before any text edit. In the source file that is `Inter` (`Medium`, `Semi Bold`) and `Onest` (`Regular`), but a copy's theme may use others. Harvest actual fonts from engine nodes via `getStyledTextSegments(["fontName"])` and load those — never a hardcoded list. Font loads live within a single call: reload the list at the start of **every** writing call.

---

## 9. Naming defects

Search verbatim; correct only in report text:

| In Figma | Correct |
|---|---|
| `ds-doc/interation` | interaction |
| `Show Desciption#757:0` | Description |
