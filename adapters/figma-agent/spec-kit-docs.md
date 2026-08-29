---
name: spec-kit-docs
description: "Builds component documentation on the ds-* engine (the «Component Spec Kit» library) with the Figma agent. Input — the component itself, selected or linked (COMPONENT_SET or COMPONENT). The skill takes an inventory of variants, properties and anatomy and assembles a section of three pages: changelog, specification, components. Use on «document this component», «build component docs», «собери документацию», «задокументируй компонент», «оформи по шаблону документации»."
---

# Building component documentation — Figma agent build

**This one file is the whole skill.** The Figma agent takes no reference folders, so everything
lives here. Derived from `spec-kit-docs` 6.2.0 for Claude Code: the contract with the engine is
identical, the mechanics are the editor's own — no Plugin API code, no keys, no imports by hand.
Full version and history: github.com/jsr993/component-spec-kit.

Input — a product component. Output — a SECTION of three pages assembled from `ds-doc/*` engine
components. Nothing is drawn from scratch: patterns are instantiated and filled.

**Three pages, always the same three:** `changelog`, `specification`, `components`. Documentation
does not exist without them; the skill builds nothing else. No page selection, no plan
confirmation — from input to finished section without stopping. The fourth pattern,
`ds-doc/interation`, is assembled by hand — never by the skill.

## The engine — names are the contract

The engine is recognised by its **`theme` variable collection** — attached as a library (named
«Component Spec Kit» by default) or living locally in the file. The library name is a hint, not
a condition. Neither present — **stop** and ask the human to attach the library: that cannot be
done for them.

Twenty components, all under the `ds-doc/` path. Matching is **exact** — no case folding, no
trimming, and the typos are part of the contract (`ds-doc/interation`, the property
`Show Desciption`):

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

An expected component or `theme` variable not found — **stop** and return three lists: expected,
found, missing. Never pick similar names, never substitute home-made frames.

## Inviolable rules

1. **Input is the component itself** — `COMPONENT_SET`, or `COMPONENT` (climb to the parent set
   if it is a variant). An instance, frame, section or group — stop, name what arrived, ask for
   the component. Reason: that same node later goes into `Slot Component`, and an instance
   cannot go there.
2. **Never touch the source component.** Properties, layers, name, description — read only. The
   single exception is moving the set itself into `Slot Component` — that is part of the build
   and needs no confirmation; name the move in the report.
3. **Never touch the header.** Every page keeps its `ds-doc/header` instance untouched: `Title`
   and `Description` are bound to `theme` variables, and any overwrite severs the binding.
   Never put the component name there.
4. **No numbers in text.** Sizes, spacing, radii, colours, typography are never written into
   documentation text. Where a Dev Mode annotation or measurement can carry the value, use it;
   where it cannot, leave the value out and list it in the report as a manual step.
5. **Never set visuals by value.** No literal fills, font sizes, radii or stroke weights on
   anything the skill creates: bind to `theme` variables or copy from neighbouring engine nodes.
   Never write into the `theme` collection itself.
6. **Write only inside your own SECTION.**
7. **Facts from the component, wording from templates.** Variants, states, anatomy and property
   order come only from the component. Never generate: when to use which configuration, how
   styles differ in meaning, text rules, do/don't recommendations, a layer's purpose that does
   not follow from its name. An empty block beats a plausible fabrication; list every gap in
   the report.
8. **Names transfer verbatim**, source typos included. Noticed typos go into the report, never
   corrected in the documentation.
9. **Language:** documentation follows the language of the request — Russian request, Russian
   texts; English request, English texts. Section headings come from the file's variables and
   follow the file; a mixed result is named in the report, not treated as an error.
10. **Report what was built**: pages, counts, every generated text, every gap, every typo.

## Pipeline

```
0 Readiness → 1 Inventory → 2 Staging → 3 Three pages → 4 Handover
```

Each step reports its facts before acting; a report is not a question. Stops are dead ends, not
checkpoints: no engine, input that is not a component, a missing `ds-doc/*` or variable.

### 0. Readiness

Confirm the engine: the `theme` collection plus the `ds-doc/*` components, locally or via the
attached library. Name which in the report.

### 1. Inventory

Read from the component: name, description, the variant axes **in property declaration order**
with their values, the actual variant count, the non-variant properties, the default variant's
layer tree. Report the inventory, then continue — do not wait for approval.

### 2. Staging

**Rebuild check:** a SECTION named after the component already on the page means a rebuild —
take the version base from the top entry of its changelog page, build the new section beside
the old one, and never delete the old one unasked.

Create a SECTION named after the component, clear of everything else on the page.

**Section styling — one tier, whole.** A component's section carries tier `01` of the section
tokens in every property; a family section wrapping several component sections carries tier
`02` the same way. Everything binds to `theme` — never literal values:

| Property | Variable (tier 01) |
|---|---|
| radius, four corners | `layers/section/radius/ds-radius-section-01` |
| bottom fill, opacity 1 | `colors/section/ds-section-01` |
| top fill, ~1 % | `colors/section/ds-section-accent` — copy the exact opacity from a finished section |
| stroke colour, opacity 1 | `colors/section/ds-section-border-01` |
| stroke weight — bound, never a literal | `layers/section/border/ds-section-border-01` |

The theme decides whether a border exists: `lite` resolves the weight to 0. A hardcoded weight
paints a border in themes that have none. If the file has a documentation family section, place
the new component section inside it, matching its siblings' spacing.

Layout: 100 padding from the section edge, pages left to right with a 200 step, section fitted
to content as the very last step.

### 3. The three pages

Each page: instantiate the pattern → detach the page wrapper (the atoms inside stay
instances) → rename the frame to the header's `Title` value → clear the demo content →
fill. Clearing means removing demo children, never resetting a slot — reset restores the demo.

#### changelog

Entries of `ds-doc/changelog/log`, newest on top. A first build writes one entry:
version `1.0.0`, type `New`, today's date as `dd.mm.yy` with leading zeros, description from
the template. On a rebuild the version counts from the old section's top entry:
`New` → major+1, `Changed` → minor+1, `Fixed` → patch+1; type from what the user said,
`Changed` by default. **The `Designers` slot stays untouched** — the component default remains.
`Show File` stays off.

#### specification

- **Lead** — a `ds-doc/specification/paragraph`, description only. A non-empty component
  description goes in verbatim; an empty one gets the lead template.
- **Anatomy** — a heading («Anatomy» / «Анатомия», description: «See the component structure
  in Dev Mode (Shift+D)» / «Структуру компонента смотрите в Dev Mode (Shift+D)») plus one
  `ds-doc/specification/component` `Type=Structure` per configuration, its default variant in
  `Slot Structure`. Annotate layers where annotations are available — the first block carries
  the shared architecture, each next one only its differences, never duplicated; without
  annotation access, list the layers in the report as a manual step.
- **One block per VARIANT axis, in declaration order.** TEXT, INSTANCE_SWAP and plain BOOLEAN
  properties get no block — list them in the report. Each block: a
  `ds-doc/specification/paragraph` heading plus a `ds-doc/specification/component` `Type=State`
  with one `ds-doc/specification/component/state` row per value, the matching variant in each
  row's slot. Row descriptions: **on** for configuration, style and size axes — but only where
  the text is a verifiable restatement of the component (a configuration's composition, for
  instance); nothing verifiable to say — off, and into the report as a gap. **Off** for states.
  A `Selected`-style boolean is a row inside the States block, not a block of its own.

Heading glossary: `Configuration` → Configurations / Конфигурации, `Style` → Styles / Стили,
`Size` → Sizes / Размеры, `State` → States / Состояния; anything else keeps its name verbatim.
Block description template: «The \`<Name>\` property sets the <heading, lowercase>: <values,
comma-separated>.» / «Свойство \`<Имя>\` задаёт <заголовок в родительном падеже>: <значения>.»
Lead template: «<Name> — a component with <N> variants across <axes>.» / «<Имя> — компонент с
<N> вариантами по осям <оси>.» First changelog entry: «First version of the component.
Axes: <axes>.» / «Первая версия компонента. Оси: <перечень осей>.»

#### components

**One block per component.** Inside it:

- the name block: component name verbatim, current version;
- `Slot Component` — **one node: the component set itself, whole**, in its native layout.
  Never a spread of instances, never a rebuilt grid. The move is unconditional: the set's
  parent and position change, nothing else; on a rebuild it leaves the old section's slot
  empty — say so in the report and offer (not perform) the old section's deletion.
- axis labels around the set, **read from the set's actual geometry, not from declaration
  order**: columns from the horizontal clusters of variants, vertical levels from the vertical
  clusters, outermost level first; bracket heights match cluster heights. Labels are verbatim
  variant values. Keep every caption on one line — widen the label rather than let it wrap.

### 4. Handover

Fit the section to its content plus 100 on each side. Report: where the section is, the three
pages, block and variant counts, **the list of generated texts**, source typos noticed, gaps
and manual steps left, and the set's move (from where, to where).

## Checklist

1. The source component's properties identical before and after; only its parent changed.
2. Exactly three pages inside one SECTION, styled by bindings, one tier throughout.
3. Headers untouched; every frame named by its header `Title`.
4. Nothing hand-styled by value; nothing written into `theme`.
5. No numbers in documentation text.
6. Specification blocks follow property declaration order; axis labels follow set geometry.
7. Changelog: version by rule, date `dd.mm.yy` with leading zeros, `Designers` untouched.
8. The report lists generated texts, typos, gaps, and the move.
