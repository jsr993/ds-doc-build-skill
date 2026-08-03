# Component Spec Kit — overview

This page is the entry point for both halves of the project. Read it if you arrived from the Figma Community file and need the skill, or from this repository and need the Figma file.

Everything here is duplicated in two other places — the `Information` page inside the Figma file, and the Figma Community description. If they ever disagree, **this page wins**.

---

## What this is

A way to document design-system components **inside Figma**, with an AI agent doing the heavy part.

The result is a section of six pages next to your component: Changelog, Specification, Animated, Tips and practices, Microcopy, Components. Nothing is drawn from scratch — every page is assembled from prepared patterns, and all visual styling comes from a variable collection you control.

## What this is not

**This is a design representation of a component, not an implementation spec for developers.**

It describes what the component is, which configurations exist, what each property means, how it behaves and how its text should read — structured the way a designer thinks about it. It is not a handoff document, not an API reference, and not a substitute for talking to the people who will build it.

Keep that in mind when reading the optional markdown export (step 7): it is a readback of what was assembled, useful for handing context to someone else. It is not a build contract.

---

## The two halves

Neither half works alone.

| Half | What it holds | Where it lives |
|---|---|---|
| **The engine** | Figma file: the `ds-*` pattern components and the `decoration` variable collection | Figma Community |
| **The skill** | `ds-doc-build`: the pipeline, the engine map, the Plugin API recipes | this repository |

The skill finds the engine **by component name, not by node id**. That is what makes it portable: the same skill works in the original file, in your copy of it, and in a file where the engine is attached as a library.

The direct consequence: **`ds-*` names and component property names are a technical contract, not text for humans.** They are never translated, normalised or corrected — including the typos in them (`ds-doc/interation`, `Show Desciption#757:0`). Renaming any engine node breaks the skill in every copy at once.

## Which file goes with which repository

One repository serves every language. The language of the documentation follows the language you write your request in; the section headings come from the Figma file you are working in.

| Language | Figma file | Skill |
|---|---|---|
| English | *not published yet* | [github.com/jsr993/ds-doc-build-skill](https://github.com/jsr993/ds-doc-build-skill) |
| Russian | *not published yet* | the same repository |

There is no separate repository per language, and there should never be one. The pipeline, the engine map, the recipes and the traps are identical; only three lists of strings differ, and those live in `references/locales/`. Two repositories would mean fixing every discovered trap twice, and they would drift.

### Current status

Nothing is published yet. Honest state as of 3 August 2026:

| Piece | State |
|---|---|
| Russian Figma file | exists as `Component Spec Kit`, not yet in Community |
| English Figma file | not created — it will be a duplicate of the Russian one with translated variable values |
| Skill repository | created, empty, first push not made |
| Locale files | not extracted yet — user-facing strings still sit inside the pipeline |

The English half ships first, then the Russian one.

---

## How it works

1. **Prepare the file.** Copy the Figma file into your project, or attach it as a library. Change the variables in the `decoration` collection — colours, spacing, radii, typography — so the documentation looks like your design system. You are editing values only; never rename anything.
2. **Pick a component** and send its link to the agent. It must be the component itself — a `COMPONENT` or `COMPONENT_SET`. A link to an instance, frame, section or group is refused, because that same node is later placed into the `Slot Component` field on the Components page, and you cannot place an instance there.
3. **The skill reads the component** — variants, properties, layer tree, tokens — and never writes to it.
4. **It asks for what the component cannot tell it:** what the component is for, what each anatomy layer does, what each property means, do-and-don't pairs, microcopy rules, and who to credit in the changelog.
5. **It shows a plan** — which component, how many variants, which pages, which specification blocks, which changelog version. **Nothing is written to the file until you confirm.**
6. **It assembles the section**, one page per call, checking a screenshot after each.
7. **You take over.** The skill does the mechanical bulk; the meaning is yours to refine.

What it will never do: invent content. If something was not supplied, it stays empty and is listed as a gap in the final report.

---

## Setup

You need **Claude Code** and the **Figma MCP server with write access** — without write permission the skill can only read.

```bash
claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp
```

Then run `/mcp` in Claude Code, pick `figma`, and authorise it.

Install the skill by unpacking `dist/ds-doc-build.skill` — an ordinary zip — into your skills folder:

```
macOS / Linux   ~/.claude/skills/ds-doc-build/
Windows         %USERPROFILE%\.claude\skills\ds-doc-build\
```

`SKILL.md` and the `references/` folder must both end up there. **Without `references/` the skill refuses to run** — it verifies its own completeness before anything else and stops if a single file is missing, because without the engine map and the recipes the output would vary from run to run and you would not notice.

Full instructions: [README.md](README.md). How the parts fit together and why: [ARCHITECTURE.md](ARCHITECTURE.md).

---

## Versions and compatibility

Three counters that must not be confused:

| Counter | Where | Grows when |
|---|---|---|
| Component version | the `ds-log` record on the Changelog page | the documented component changes |
| Skill version | [CHANGELOG.md](CHANGELOG.md) | the skill changes |
| Engine version | [CHANGELOG.md](CHANGELOG.md), engine section | the set of `ds-*`, their properties or the pattern structure changes |

**Compatibility rule:** a skill major version declares which engine major version it works with. The check is built into the pipeline rather than bolted on — if an expected component is missing, the skill stops and returns three lists: what was expected, what was found, what is missing.

Any structural change is made in the Russian file first and carried into the English one as a separate step. The files must stay structurally identical — same nodes, same names, same tokens, translated values only. A structural difference between them is a bug.

---

## Short version, for the Figma Community description

> **Component Spec Kit** — a documentation engine for design-system components, plus an AI skill that fills it in for you.
>
> Six documentation pages per component — changelog, specification, motion, do-and-don't, microcopy, and the component set itself — assembled from prepared patterns. All styling comes from one variable collection: change the tokens, and every page you have ever built restyles at once.
>
> Duplicate this file, retheme it, and document components by hand. Or install the `ds-doc-build` skill for Claude Code, send it a link to a component, and let it assemble the section — reading the component, asking you for the meaning it cannot infer, and showing you a plan before it writes anything.
>
> This is a design representation of a component, not an implementation spec for developers.
>
> Skill and setup: github.com/jsr993/ds-doc-build-skill

---

## Feedback

Telegram [@jsr_i](https://t.me/jsr_i), email [ishmirzaev.jasur@gmail.com](mailto:ishmirzaev.jasur@gmail.com).
