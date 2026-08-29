# Component Spec Kit — overview

This page is the entry point for both halves of the project. Read it if you arrived from the Figma Community file and need the skills, or from this repository and need the Figma file.

The same story is told in two other places — the `information` page inside the Figma file, and the Figma Community description. If they ever disagree, **this page wins**.

---

## What this is

A way to document design-system components **inside Figma**, with an AI agent doing the mechanical part.

The result is a section of three pages next to your component: Changelog, Specification, Components. Without those three there is no documentation, and those three are exactly what the skill builds. Nothing is drawn from scratch — every page is assembled from prepared patterns, and all visual styling comes from a variable collection you control.

The engine carries a fourth pattern, `Interaction`. The skill does not build it: what goes there — trigger, reaction, motion tokens — cannot be derived from a component. Assemble it by hand when you have something to say.

## What this is not

**This is a design representation of a component, not an implementation spec for developers.**

It describes what the component is, which configurations exist, what each property means and how it behaves — structured the way a designer thinks about it. It is not a handoff document, not an API reference, and not a substitute for talking to the people who will build it.

Keep that in mind when reading the optional markdown export: it is a readback of what was assembled, useful for handing context to someone else. It is not a build contract.

---

## The pieces

| Piece | What it holds | Where it lives |
|---|---|---|
| **The engine** | Figma file: twenty `ds-doc/*` components and the `theme` variable collection — 164 variables, three modes | Figma Community |
| **`spec-kit-docs`** | the build pipeline, the engine map, the Plugin API recipes, the locales | this repository, `skills/spec-kit-docs/` |
| **`spec-kit-theme`** | the collection map, the token-usage map, the six territories, the expansion tables | this repository, `skills/spec-kit-theme/` |

Neither skill works without the engine. The engine works without both — you can build every page by hand.

The two skills work at different levels and never meet in a file: `spec-kit-docs` writes pages and never touches the `theme` collection; `spec-kit-theme` writes variables and never touches a page. That is the whole division, and it is why they can share a repository without sharing a line of code.

### One repository, two skills

They ship together because they break together. Both are pinned to the same engine: rename a `ds-doc/*` component and the docs skill stops; restructure the `theme` collection and both stop — the docs skill loses its section styling, the theme skill loses its map. A finding about the engine has to land in one place, not be carried across two histories by hand.

Adding a third skill means adding a folder under `skills/`. The pack scripts walk the directory; each skill's version is read from its own section of [CHANGELOG.md](CHANGELOG.md). There is deliberately no repository-wide version — it would lie about whichever skill did not change.

---

## Names are a contract

`spec-kit-docs` finds the engine **by component name, not by node id**. That is what makes it portable: the same skill works in the original file, in your copy of it, and in a file where the engine is attached as a library.

The direct consequence: **`ds-doc/*` names, component property names and `theme` variable names are a technical contract, not text for humans.** They are never translated, normalised or corrected — including the typos in them (`ds-doc/interation`, `Show Desciption#757:0`, `paragraphy-spacing`, `size-mono-02 2`). Renaming any engine node breaks the skills in every copy at once.

The library itself is recognised **by the `theme` collection, not by the library's name**. Rename the file, publish your own copy under your own name — both skills still find it.

---

## Languages

One repository serves every language. The language of the documentation follows the language you write your request in; the section headings come from the Figma file you are working in.

| Language | Figma file | Skills |
|---|---|---|
| English | [Component Spec Kit](https://www.figma.com/community/file/1666170620013431022/component-spec-kit) — duplicate it from Community | [github.com/jsr993/component-spec-kit](https://github.com/jsr993/component-spec-kit) |
| Russian | *not published yet* | the same repository |

There is no repository per language and there should never be one. For `spec-kit-docs` the pipeline, the engine map, the recipes and the traps are identical; only three lists of strings differ, and those live in `references/locales/`. Two repositories would mean fixing every discovered trap twice, and they would drift.

**How the languages combine:** the documentation language follows your request; the section headings come from the file's variables and follow its language. Mixing them — an English file with a Russian request — is legal: the skill names the mix in its report and continues.

### Current status

Honest state as of 29 August 2026:

| Piece | State |
|---|---|
| English Figma file | **published** in Figma Community |
| Russian Figma file | not published yet |
| Repository | **published**, in English |
| `spec-kit-docs` | 6.0.0, English, one skill serving both request languages |
| `spec-kit-theme` | 0.1.0, **written in Russian** — it answers an English request, but in its own language |
| Locale files | `spec-kit-docs/references/locales/en.md` + `ru.md` |

Two things are worth knowing before you rely on them. `spec-kit-docs` 6.0.0 was brought in line with the rebuilt engine by reading, not by a run — there has been no end-to-end build on the new names yet. And `spec-kit-theme` has no locales at all; giving it some is the obvious next step, not a decision anyone has taken.

---

## How it works

### Building documentation

1. **Prepare the file.** Duplicate the Figma file into your project, or attach it as a library. Change the values in the `theme` collection — colours, spacing, radii, typography — so the documentation looks like your design system. You are editing values only; never rename anything. If you publish your copy as a library, make sure the `theme` collection is published along with the components: a library that ships components but hides its variables lets every page build fine and then stops the skill at section styling, with nothing to bind to.
2. **Pick a component** and send its link. It must be the component itself — a `COMPONENT` or `COMPONENT_SET`. A link to an instance, frame, section or group is refused, because that same node is later placed into the `Slot Component` field on the Components page, and an instance cannot go there.
3. **The skill reads the component** — variants, properties, layer tree, tokens. It never writes to it; the one thing it changes is the set's parent, when it moves the set into the slot, and that is named in the report.
4. **It reports the inventory** — how many variants, which axes, the order the specification blocks will follow — and keeps going. There is no plan to confirm and no interview: the skill is built for documenting dozens of components in one pass, where a question per component means the work stops.
5. **It assembles the section**, one page per call, checking a screenshot after each.
6. **You take over.** The skill does the mechanical bulk; the meaning is yours to refine.

Facts — variants, states, anatomy, property order — come only from the component. Wording is generated from a closed set of templates and must be a checkable restatement of the inventory; everything generated is listed in the final report. Meaning that cannot be derived — when to use which configuration, how styles differ in purpose, text rules, recommendations — is never invented: the block stays empty and is listed as a gap.

### Building a theme

A **mode** of the `theme` collection is a theme. Three ship with the file: `lite`, `enterprise`, `engineering`.

1. **Send a reference image** and a link to the file.
2. **The skill picks a territory** — one of six characters the structure can actually carry — then fills in a brief of fourteen decisions: background lightness, how cards are separated, corner radius, density, the families for headings and body, where the accent sits.
3. **It expands the brief** into all 164 variables by fixed tables. It does not read 164 values off the picture: a model asked for 164 numbers produces 164 plausible ones, and plausible is not consistent — the scale stops being a scale.
4. **It checks before writing** — contrast, monotone scales, fonts that exist in Figma — and only then adds the mode.

Existing modes are never touched, and aliases are never flattened. A theme that does not work costs one mode deletion.

---

## Setup

You need **Claude Code** and the **Figma MCP server with write access** — without write permission the skills can only read.

```bash
claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp
```

Then run `/mcp` in Claude Code, pick `figma`, and authorise it.

Install a skill by unpacking its archive from `dist/` — an ordinary zip — into your skills folder, one folder per skill:

```
macOS / Linux   ~/.claude/skills/spec-kit-docs/
                ~/.claude/skills/spec-kit-theme/
Windows         %USERPROFILE%\.claude\skills\spec-kit-docs\
```

`SKILL.md` and the `references/` folder must both end up **directly inside** that folder — Claude Code lists a skill only when `SKILL.md` sits at its root, and a folder one level too deep produces no error, just a skill that never appears.

**Without `references/` a skill refuses to run.** Each verifies its own completeness before anything else and stops if a single file is missing: without the maps and the recipes the output would vary from run to run and you would not notice.

Full instructions: [README.md](README.md). How the parts fit together and why: [ARCHITECTURE.md](ARCHITECTURE.md).

---

## Versions and compatibility

Four counters that must not be confused:

| Counter | Where | Grows when |
|---|---|---|
| Component version | the `ds-doc/changelog/log` record on the Changelog page | the documented component changes |
| `spec-kit-docs` | [CHANGELOG.md](CHANGELOG.md) | the docs skill changes |
| `spec-kit-theme` | [CHANGELOG.md](CHANGELOG.md) | the theme skill changes |
| Engine version | [CHANGELOG.md](CHANGELOG.md), the Engine section | the `ds-doc/*` roster, their properties or the pattern structure changes |

**Compatibility rule:** a skill's major version declares which engine major version it works with. The check is built into the pipeline rather than bolted on — if an expected component is missing, the skill stops and returns three lists: what was expected, what was found, what is missing.

Any structural change is made in the Russian file first and carried into the English one as a separate step. The files must stay structurally identical — same nodes, same names, same tokens, translated values only. A structural difference between them is a bug.

---

## Feedback

Telegram [@jsr_i](https://t.me/jsr_i), email [ishmirzaev.jasur@gmail.com](mailto:ishmirzaev.jasur@gmail.com).
