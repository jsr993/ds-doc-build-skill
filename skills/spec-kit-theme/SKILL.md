---
name: spec-kit-theme
description: "Builds a new theme for the Component Spec Kit library from a reference image: reads the palette, radii, density and typography off the picture, expands them into the 164 variables of the theme collection and adds the result as a separate mode. Use when given a design reference image and asked to build a theme from this reference, generate a palette, add a theme to the theme collection, restyle the documentation like this — or in Russian: «сделай тему по референсу», «сгенери палитру», «добавь тему в theme», «раскрась документацию как здесь». Requires Figma MCP with write access."
---

# A Component Spec Kit theme from a reference

Input — a picture of a design and a file with the library. Output — a new mode in the
`theme` collection with all 164 variables set.

**A theme is a mode, not a file.** Existing modes are never touched: the theme is added
alongside, switched with the standard mode switcher, deleted in one move. A failed theme
therefore costs nothing.

**The language of the report follows the language of the request.** Asked in Russian —
the brief, the step reports and the handover are Russian; asked in English — English.
The skill writes no prose into Figma, so there is nothing else to localise.

## Required context

**Version 0.3.0.** `SKILL.md` and `references/` ship as one archive and are versioned together.

| File | When to read |
|---|---|
| `references/theme-map.md` | before the first action — all 164 variables, the tiers, what is not a theme |
| `references/token-usage.md` | before the first action — which token paints and moves what |
| `references/style-space.md` | before reading the reference — what is achievable, the six territories |
| `references/expansion-rules.md` | before reading the reference — the brief and the expansion |
| `references/recipes.md` | before the first write — Plugin API |

## What to work with

Three capabilities are needed: executing JS in the Figma file, viewing the reference image,
write access. One missing — stop, naming what is missing.

| Harness | Execution | Image |
|---|---|---|
| Claude Code + Figma MCP | `use_figma`, with `figma-use` in `skillNames` before **every** call | attachment in the message |

Call contract: one call — one step; `return` instead of `console.log`; return the ids of what
changed; never blindly retry a failed call.

## Inviolable rules

1. **Never touch an existing mode.** The skill only adds a mode and writes into it. Any write
   into `lite`, `enterprise` or another existing mode is an error.
2. **Variable names are a contract.** Transfer verbatim, typos included (`size-mono-02 2`,
   `paragraphy-spacing`, `interation`), along with the `layers` group name.
3. **What is not a theme is copied.** Section texts, document width and the small `layer-03`
   details are taken from the sample mode as they are. The list is in `theme-map.md`, section 3.
4. **Aliases are preserved.** The semantic tier repeats the `lite` scheme. Flattening an alias
   into a value is forbidden: the theme would stop responding to a primitive edit.
5. **Fourteen decisions, not 164.** The reference yields a brief; the expansion yields the
   values. Numbers named «by eye» past the tables are an error.
6. **What cannot be read is inherited.** A trait absent from the picture is taken from the
   sample and named in the report. Inventing is forbidden.
7. **Font families — only Google Fonts available in Figma**, and only after a
   `listAvailableFontsAsync` check.
8. **Return ids** — the mode id and the list of what was written.

## Pipeline

```
0 Readiness → 1 Reference and brief → 2 Expansion → 3 Writing the mode → 4 Handover
```

Each step reports its facts before acting. A report is not a question. Stops only where
«stop» is written: unreadable references, no `theme` collection, no image, a missing font,
a mode that cannot be created.

### 0. Readiness

Read the files from the table. Find the `theme` collection (recipe 1) and the sample mode —
`lite`, or the first mode if it is absent. Name: the variable count, the names of the existing
modes, the sample's name.

No collection — **stop**: the file carries no library.

### 1. Reference and brief

Look at the picture. **Pick a territory first**, by the three questions of `style-space.md`,
section 5 — lightness, what separates the cards, what the corners are. Take its values as the
base and refine them against the reference. Inventing a character outside the six territories
is forbidden.

Then fill the fourteen-decision brief by the «How to read the brief» table
in `expansion-rules.md`.

The report closes with **the named territory and the whole brief**, each decision marked:
read off the picture or inherited from the sample. This is the only place where what the skill
took from the reference is separated from what the expansion decided.

No image — **stop**: a theme cannot be derived without a reference.

### 2. Expansion

Expand the brief into 164 values by the tables of `expansion-rules.md`, section 3.
Run the checks of section 4: the fonts exist, the contrast passes, the scales are monotone.

A check failed — **do not write**. Fix the brief and expand again.

Report: the palette, the sizes, the spacing scale, the radii, the families with their styles.

### 3. Writing the mode

One call for everything, in the order of recipes 2–4:

1. `addMode(<theme name>)`;
2. carry the aliases and the «not a theme» values over from the sample;
3. write the theme's primitives on top.

The order is mandatory: carrying over after the write would clobber the computed values.

### 4. Handover

Completeness check (recipe 6): all 164 got a value. Not all — name which.

Report: the mode's name and id, the brief with its source marks, what was inherited, font
substitutions, how to switch the mode in the file.

## Checklist

1. Existing modes unchanged — not a single `setValueForMode` against their mode ids.
2. The new mode exists, its name matches `text/ds-name`.
3. All 164 variables have a value in the new mode.
4. The semantic tier is aliases, repeating the sample's scheme.
5. Section texts, document width and `layer-03` copied verbatim.
6. Families verified through `listAvailableFontsAsync`, substitutions named.
7. Text-to-surface contrast: `primary` ≥ 7:1, `secondary` ≥ 4.5:1.
8. The `space`, `gap`, `radius`, `size` scales are monotone.
9. The report names the territory, and every brief decision says: off the picture, from the
   territory, or inherited.
10. The character stays within the six territories of `style-space.md`; divergence from the
    reference is named.
11. The report is written in the language of the request.
