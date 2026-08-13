---
name: ds-doc-build
description: "Autonomously builds component documentation in Figma on the ds-* engine (the «Component Spec Kit» library). Input — a link to the component itself (COMPONENT_SET or COMPONENT); nothing else is required. The skill takes an inventory of variants, properties and anatomy and assembles a section of three pages: changelog, specification, components. It asks almost no questions — built for documenting many components in a row. Use when given a Figma component link and asked to «document this component in Figma», «build component docs», «generate ds-doc section», or in Russian: «собери документацию», «задокументируй компонент», «сделай страницы доки», «оформи по шаблону документации», «построй ds-doc». Requires Figma MCP with write access."
---

# Building component documentation in Figma

Input — a link to a product component. Output — a SECTION of three pages assembled from `ds-*` engine components. Nothing is drawn from scratch: patterns are instantiated and filled.

**Three pages, always the same three:** `changelog`, `specification`, `components`. Documentation does not exist without them; the skill builds nothing else. No page selection, no plan confirmation — from link to finished section without stopping.

**Distribution model.** The engine is a Figma file the user duplicates or attaches as a library. The skill is portable: it finds `ds-*` by name or by key, never by id. All documentation visuals come from the `decoration` variable collection — the user changes typography, colours, radii and spacing there, and the documentation restyles wholesale. The skill never interferes with that mechanism.

## Required context

**Version 4.0.** `SKILL.md` and `references/` ship as one archive and are versioned together — a folder from another generation is a broken install, not a variant.

| File | When to read |
|---|---|
| `references/ds-engine-map.md` | before the first action — every `ds-*`, node-ids, keys, properties |
| `references/build-recipes.md` | before the first action — Plugin API snippets |
| `references/annotations.md` | before building Specification |
| `references/locales/<lang>.md` | after the language is determined — exactly one file |
| `references/contract-template.md` | only when explicitly asked to export markdown |

## How to run it

The skill needs three capabilities: execute JS in the Figma file, capture an image of a node, and write access. Any one missing — stop and say which.

| Harness | Execute | Capture |
|---|---|---|
| Claude Code + Figma MCP | `use_figma`, with `figma-use` in `skillNames` — mandatory before **every** call | `get_screenshot` |
| Any model with Figma MCP | the MCP tool that runs JS | the MCP tool returning a node image |
| An agent inside Figma | Plugin API directly | by its own means |

Call contract:

- one call — one logical step; a page is never built whole in one call;
- `return` instead of `console.log`: only the returned value is visible;
- `setCurrentPageAsync` — exactly once per call, and pages do not load without it;
- return the IDs of every node created or mutated;
- a failed call is never blindly retried: read the error, fix, retry. A failed script does not execute partially.

## Language

**Documentation language = the language the user wrote the request in.** Russian request → Russian texts, `ru.md`; English request → English texts, `en.md`. Read exactly one locale file; reading both wastes context.

Safeguard: after the engine is resolved, read the value of the specification header title variable and compare its language with the chosen one. A mismatch is **not an error and not a question** — name it in the report («headings come from the file in English, generated texts are Russian») and continue. The file may be intentionally mixed.

## Inviolable rules

1. **The library is mandatory.** The engine is recognised by its `decoration` variable collection — in an attached library (named «Component Spec Kit» by default) or locally in the file. Neither present → stop and ask to attach it (step 0). It cannot be attached from code.
2. **Input is the component itself.** `COMPONENT_SET` or `COMPONENT`. An instance, frame, section or group → stop.
3. **Never touch the source component.** Properties, layers, name, description — read only. The single exception is moving the set itself into `Slot Component` (6.3), and it is the only question in the whole build: **stop** before the move; without explicit permission do not move it.
4. **Never touch the header.** `Title` is the section name, `Description` its subtitle; both are bound to `ds-title-description/<pattern>/*` variables. Never put the component name there. Any `setProps` on them severs the variable binding.
5. **No numbers in text.** Sizes, spacing, radii, colours, typography → annotations with `properties` and measurements.
6. **Never set visuals by value.** No `fills`, `fontSize`, `fontName`, `cornerRadius`, `strokeWeight` as literals: everything comes from the engine through `decoration` variables; a hand-set value overrides the theme. Copy geometry from neighbouring engine nodes. Never write into `decoration`. Exception — the SECTION (5.1), and even that by binding only.
7. **Write only inside your own SECTION.**
8. **Facts from the component, wording from templates.** Variants, states, anatomy and property order come only from the inventory; inventing them is forbidden. Headings and descriptions the skill writes itself using the templates in the locale file — and lists everything generated in the report. What must never be written even from a template — see «Texts».
9. **Incrementally.** One page per call; after each, capture an image and check.
10. **Return the IDs** of every node created.

## Pipeline

```
0 Readiness → 1 Input and inventory → 2 Staging → 3 Three pages → 4 Handover
```

Each step reports its facts before acting — what was read, what was found, what is about to be written. A report is not a question: state the facts and continue. Stops happen only where «stop» is written, and nothing is written to the file before step 2 closes.

### 0. Readiness

**Completeness.** Read the five files from the table (the locale counts once the language is known). If any cannot be read — name it, diagnose the install, and finish. Do not reconstruct content by reading the Figma file and do not work «from memory»: without the engine map the keys and node-ids have nowhere to come from, the result differs from run to run, and the finished section in Figma looks the same either way.

**Diagnose before blaming the unpack.** List what `references/` actually holds — a stale folder names its own generation:

| What you see | What it means |
|---|---|
| `interview.md` or `designers.md` present | the folder predates 3.0 |
| `execution.md` present | the folder predates 4.0, where it was folded into `SKILL.md` |
| `locales/` missing | the folder predates 3.1 |
| no `references/` at all, or a table file missing with none of the markers above | an incomplete unpack |

The stop message states: the version from `SKILL.md`, the files found, the files missing, the stale markers, and the verdict — **«reinstall the whole folder from `dist/ds-doc-build.skill`, do not unpack over the old one»** when markers are present, **«add the missing files»** when they are not.

**Never edit the required-context table to fit a broken folder.** Making the error disappear that way silently rolls the skill back a generation: the pipeline then references steps that no longer exist.

**Library.** `figma.teamLibrary.getAvailableLibraryVariableCollectionsAsync()`:

The engine is recognised **by the `decoration` collection, not by library name**: the owner may rename the file, a user may publish their own copy under their own name. «Component Spec Kit» is the default name and a hint for humans, not a condition.

| Found | Action |
|---|---|
| a `decoration` collection in one attached library | proceed; resolve the engine **by `key`**; name the `libraryName` in the report |
| several such libraries | **stop**: list the names, ask which one is the engine |
| no library, but the file has a local `decoration` collection and `ds-*` components | proceed on the local copy; resolve **by name**; note it in the report |
| neither | **stop**: ask to attach the engine via `Assets` → `Libraries` (named «Component Spec Kit» by default) |

A library cannot be attached from code — only a human through the UI. So the check ends with a request, not an attempted fix.

### 1. Input and inventory

`fileKey` and `node-id` from the URL (hyphen between numbers → colon). No `node-id` — ask for it.

| Input | Action |
|---|---|
| `COMPONENT_SET` | work with it |
| `COMPONENT` with no set parent | work with it; the `components` page gets no axis labels |
| `COMPONENT` inside a set | climb to the parent, no questions |
| `INSTANCE`, `FRAME`, `SECTION`, `GROUP`, anything else | **stop** |

Stop = create nothing, do not descend into the node, do not guess. Name the type and name of what arrived, say a component link is needed, finish. Reason: the same node later goes into `Slot Component` (6.3) — an instance or frame cannot go there.

**Inventory (read-only, recipe 1).** Capture: name, `key`, `description`, `documentationLinks`; `componentPropertyDefinitions`; the actual variant combinations (not the cartesian product); the `defaultVariant` layer tree to depth 3; nested instances; tokens via `get_variable_defs`.

**Preserve property order verbatim** — specification blocks follow it. Do not sort.

**Names verbatim, typos included.** Search and verification run on names; a mismatch is worse than a typo. List noticed typos in the report as a separate item — a find for the owner, not a reason to edit the documentation text.

Report before moving on: name, variant count, axes with values, properties in declaration order, where the lead comes from.

### 2. Staging (recipes 2, 2a)

Engine resolution: by key for a library (`importComponentByKeyAsync` / `importComponentSetByKeyAsync`), by name over pages for a local copy. **Components of an attached library cannot be found by name** — the Plugin API does not enumerate them; only key import works.

Keys in `ds-engine-map.md` are the owner's library keys. If the user published **their own** copy, the keys differ. Then: ask them to drag any `ds-doc/*` from `Assets` onto the canvas once, read `instance.mainComponent.key`, and proceed from it, keeping harvested keys in build memory.

Name matching is **exact**, engine typos included. Do not pick similar names. Nothing found — stop and return three lists: expected, found, missing, plus the probable cause.

**Rebuild.** Before creating the section, look for a SECTION named after the component on the current page. Found — this is a rebuild: take the changelog version base from the top `ds-log` entry of its `changelog` page, build the new section to the right of the old one, and **do not touch or delete the old one** — offer its removal in the report; the owner decides. Not found — first build, version `1.0.0`.

Then one call: `setCurrentPageAsync` (exactly once) → load fonts harvested from engine nodes, never hardcoded → a `SECTION` named after the component to the right of the rightmost node → style it (5.1).

#### 5.1 Styling the SECTION

| Property | Variable | Engine constant |
|---|---|---|
| radius, all four corners | `space/global/radius/ds-radius-section` | — |
| bottom fill | `color/section/ds-section-02` | opacity 1 |
| top fill | `color/section/ds-section-01` | opacity 0.01 |
| stroke | `color/ds-tertiary` | opacity 0.4, weight 1, align `INSIDE` |

Colours and radius — **only `setBoundVariable` and `setBoundVariableForPaint`**. Opacities, stroke weight and alignment are not covered by variables — they are engine constants. A variable missing from the collection — stop and name it, never substitute a hand-picked colour. If the file already has a finished documentation section, copy the settings from it: the owner's edits carry over by themselves.

Layout: 100 padding from the section edge on all sides, pages left to right with a 200 step.

### 3. Three pages — one per call

Pattern instance → `detachInstance()` → fill `Content`. Detach is mandatory: patterns have no public properties and the number of blocks is unknown in advance. After detach `Header` remains a `ds-doc-header` instance — do not touch it.

**The frame name comes from the header `Title` of that same page.** After detach, read `Title` from the `ds-doc-header` instance and assign it to `frame.name`. Do not invent names and do not hardcode a list: `Title` is bound to `decoration`, so frame names follow the library's theme and language. `Title` empty — use the pattern name without the `ds-doc/` prefix. The name is a snapshot at build time; a rebuild picks up the new value.

After each page — capture an image and check; fix layout immediately.

#### 6.1 `ds-doc/changelog`

Only `ds-log` entries, one entry = one change, newest first on top (`insertChild(0, …)`).

A first build writes one entry:

| Field | Source |
|---|---|
| version | `1.0.0` |
| `Type` | `New` |
| date | today, leading zeros required (`01`, not `1`), two-digit year |
| description | the `changelog.first-entry` template from the locale |
| `Designers` | **do not touch the slot** — the component default stays |
| `Show File` | `false`; do not fill the `File` slot; do not change `✱ Image` |
| `Show Description` | `true` |

On a rebuild over existing documentation, the version counts from the top entry:

| `Type` | Meaning | Version |
|---|---|---|
| `New` | new component version | `Major+1`, `Minor=0`, `Patch=0` |
| `Changed` | rework | `Minor+1`, `Patch=0` |
| `Fixed` | fix | `Patch+1` |

The type comes from what the user said. Nothing said — `Changed`. Backdate only on explicit request.

#### 6.2 `ds-doc/specification`

**Lead** — a `ds-paragraph` directly in `Content`, not in a `Group`. `Show Title = false`, `Description` only. Source: a non-empty component `description` — **verbatim**. Empty — generate from the locale lead template.

**Anatomy** — a `Group`: `ds-paragraph H1` (`Title` and `Description` from the locale `anatomy.*` keys) + one `ds-doc-component Type=Structure` per configuration, `Title` = configuration name, `Show Desciption = false`, a variant instance in `Slot Structure`.

Details go on layers inside the instance as annotations: purpose in `labelMarkdown`, values in `properties`. Every layout annotated. With several configurations do **not duplicate** annotations: the first carries the shared architecture, each next one only its differences.

**Then — one block per VARIANT axis, in `componentPropertyDefinitions` order.** Properties of other types do not become blocks: TEXT and INSTANCE_SWAP have no enumerable values to tabulate — list them in the report as properties without a block. BOOLEAN gets a block only with display logic of its own (see exceptions). A block = a `Group` of two nodes:

1. `ds-paragraph Type=H1` — `Title` from the locale glossary, `Description` from the locale template;
2. `ds-doc-component Type=State`, `Show Title = false`, `Show Desciption = false`; in `Slot State` — one `ds-doc-component-state` per value.

Row descriptions: **on** for configuration, style and size axes, **off** for states — a state name speaks for itself.

Exceptions: `Selected` is a row inside the States block, not a separate block. A boolean property becomes a block if it has display logic of its own.

Sizes — with an `addMeasurement` ruler. Styles — a `properties: ["fills"]` annotation on the preview.

#### 6.3 `ds-doc/components`

**One `Name Component` block per component.** Splitting into blocks per axis pair is an error. A family of several sets is named with a slash, one block each, still one frame inside a block.

| Node | Content |
|---|---|
| `Name` | `Name Component#10010:1` = component name; `ds-log-changelog-version` = current version |
| `Slot Component` | **one node** — the component itself, all variants, in its native layout |
| `Horizontal Props` | `Line[0]` = axis name (`Large=True`), `Line[1]` = values |
| `Vertical Props` | one `Line` per nesting level; the innermost level is a frame with a `Line` per row block |

The columns axis is the first **VARIANT axis** in property declaration order (other property types are not axes); the remaining VARIANT axes go into `Vertical Props` levels in the same order. Levels: `Vertical=True` on all; major level `Large=True`, auxiliary `Large=False`. Labels are verbatim VARIANT values.

**The move needs permission.** The set itself is the only thing the skill touches outside its own section: its parent and position in the file change. So before building this page — **stop**: name the component and ask permission to move it inside the section. Refused — build the page without `Slot Component`: the `Name` block and axis labels in place, the slot empty, the reason in the report.

### 4. Handover

**Fit the section last**, when all heights are final: size = content bounds plus 100 on each side, via `resizeWithoutConstraints`. `SECTION` has no auto-layout and never hugs by itself.

Report: link to the section, the three pages, block and variant counts, **the list of generated texts**, source typos noticed, what remains unfilled. Labels — from the locale `report` section.

Markdown contract per `contract-template.md` — only if asked.

## Texts

The skill writes wording itself. Tone — dry, descriptive, no judgements or recommendations. Language — per the «Language» section; the templates, glossary and fixed strings live in `references/locales/<lang>.md`.

**Never generate** — leave empty and put in the report:

- when to use which configuration;
- how styles differ in meaning rather than looks;
- text and microcopy rules;
- do / don't recommendations;
- an anatomy layer's purpose when it does not follow from the layer name.

An empty block beats a plausible fabrication: generated text must be a verifiable restatement of the inventory, not a guess at the author's intent.

An anatomy layer whose purpose cannot be derived still gets annotated — the checklist requires a mark on every layout. `labelMarkdown` — the layer name in bold, no explanation; fill `properties` as usual. The layer itself goes into the report as a gap: the owner supplies the meaning.

## Checklist

1. The source `componentPropertyDefinitions` match before and after.
2. Exactly three pages built, everything inside one SECTION.
3. Headers untouched, `decoration` bindings intact, no component name in them. Every frame name equals its header `Title`.
4. No created node has hand-set visuals; nothing written into `decoration`.
5. No numbers in text.
6. Annotations on every anatomy layout, `properties` and category filled, none duplicated across configurations.
7. Specification blocks follow component property order.
8. `ds-doc/components` — one block, one node in `Slot Component`; axis labels verbatim.
9. Changelog: version and type by rule, date with leading zeros, `Designers` untouched, `Show File = false`.
10. Every page screenshot reviewed; no overflows or overlaps.
11. SECTION styled with variable bindings and fitted to content with 100 padding.
12. The report lists: generated texts, source typos, the unfilled.
