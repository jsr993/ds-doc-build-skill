# Solution architecture

A document for those who develop the engine and the skill. Users do not need it — users need the [README](README.md).

This describes only the construction: what the solution consists of, which contracts bind the parts, and by what rules it changes. There are no plans, roadmaps or task queues here — those live in the project's working documents, outside this repository.

---

## 1. What this solution is

Three layers that evolve separately and are bound by narrow contracts.

| Layer | Where it lives | Who changes it | Contract with its neighbour |
|---|---|---|---|
| **The engine** | a Figma file: twenty `ds-doc/*` components, the `theme` collection | the library designer | component, property and variable names |
| **The skills** | `skills/<name>/SKILL.md` + `references/` | the maintainer | find the engine by name, read strings from locales |
| **Distribution** | the repository, `dist/*.skill`, README | the maintainer | engine and per-skill versions |

The key property: **the skill is not tied to any particular file.** It finds the engine by exact component name, not by node-id. So the same skill works in the source file, in someone's copy, and in a file where the engine is attached as a library.

From this follows the main architectural constraint: **`ds-doc/*` names, component property names and `theme` variable names are a technical contract, not text for humans.** They are never translated, normalised or corrected — typos included (`ds-doc/interation`, `Show Desciption#757:0`, `paragraphy-spacing`, `size-mono-02 2`). Renaming any engine node breaks the skills in every copy at once.

### Two skills, one engine

The repository ships two skills that never meet inside a file. `spec-kit-docs` writes pages and never touches the `theme` collection; `spec-kit-theme` writes variables and never touches a page. They share no code — the whole coupling is the engine they both read.

That coupling is the reason they share a repository. Rename a `ds-doc/*` component and the docs skill stops. Restructure `theme` and **both** stop: the docs skill loses the tokens it styles the section with, the theme skill loses its map of the collection. Engine 3.0 did exactly that, and with separate histories the same finding would have had to be carried across twice by hand.

The cost is a repository where a reader must notice which skill a change belongs to. That is paid once in the folder layout — `skills/<name>/` — and in `CHANGELOG.md`, which keeps a section per skill. **There is no repository-wide version:** a single number would claim a release for the skill that did not change. Each skill's version is read from its own `## <name>` section, and the pack scripts walk `skills/` rather than being told what exists.

### The harness lives in `SKILL.md`

The rules, the engine map and the page specs are pure Figma Plugin API. The only thing that differs is **what** the agent executes code with and captures images with — an adapter table plus the call contract, both in `SKILL.md` under «How to run it».

That material spent three versions as a separate `references/execution.md` and moved back in 4.0. Two reasons, and neither is about the content, which survived intact. The file was the smallest of the references and the one most often missing from a partial install — twice in one week a run stopped because it alone had not arrived. And the gate ceremony it carried was cut in the same version: five named gates with a closing protocol turned out to be a heavier frame than the thing it framed.

**What the gates protected is kept as plain rules:** each step reports its facts before acting, nothing is written before the staging step closes, and doubt is a stop. The numbered steps 0–4 remain — as a pipeline, not a ceremony.

The completeness check is not part of that cut and never should be. It is the only thing standing between a partial install and a build that invents engine keys — a failure invisible in the finished Figma section.

### Autonomy as a design decision

Version 3.0 removed plan confirmation and the interview entirely. That is a trade, and a deliberate one.

What was gained: the skill suits batch work — documenting dozens of components in a row in one sitting. Previously every component cost five or six rounds of questions, and by the twentieth a human gave up.

What it cost: part of the documentation text is now written by the skill, not by the component's author. To keep that from becoming a quiet substitution, the boundary is drawn hard. **Facts** — variants, states, anatomy, property order — still come only from the component. **Wording** is generated from a closed set of templates and must be a verifiable restatement of the inventory. **Meaning** — when to use which configuration, how styles differ in purpose, text rules, recommendations — is never generated; the block stays empty. Everything generated is listed in the report.

Weakening the last two rules would produce documentation that looks written and is not. That is worse than an empty block, because an empty block is visible.

---

## 2. What is localised and what is not

The split runs along one line: **everything the machine reads is English and shared by all languages; everything a human reads is localised.**

### Never localised

- Engine component names, all twenty under the `ds-doc/` path: the patterns `ds-doc/changelog`, `ds-doc/specification`, `ds-doc/components` (built by the skill) and `ds-doc/interation` (manual only); the atoms `ds-doc/header`, `ds-doc/header/cover`, `ds-doc/specification/paragraph`, `ds-doc/specification/component`, `ds-doc/specification/component/state`, `ds-doc/components/name`, `ds-doc/components/label`, `ds-doc/components/component-type`, `ds-doc/changelog/log`, `ds-doc/changelog/log/type`, `ds-doc/changelog/log/version`, `ds-doc/changelog/log/date`, `ds-doc/changelog/log/designers`, `ds-doc/changelog/log/designers/avatar`, `ds-doc/interaction/device`, `ds-doc/interaction/container`.
- Component property names and suffixes: `Title#814:6`, `Show Desciption#757:0`, `Slot Component`, `Type`, `Large`, `Vertical`, `Position`.
- `theme` variable names: `text/docs-header/changelog/title`, `colors/ds-primary`, `layers/doc/content/*`. Their **values** are translated, their names never.
- The skills' internal text: pipeline, rules, Plugin API recipes, checklist. The model reads it, not the user.

### Localised

| What | Where it lives | Who translates |
|---|---|---|
| Documentation section headings (`Changelog`, `Specification`, …) | values of the STRING variables `text/docs-header/*/title` and `*/description` | the designer, in Figma |
| The `get started` page, the cover, engine component descriptions | the Figma file | the designer, in Figma |
| Strings the skill **writes** into documentation | `references/locales/<lang>.md` | the maintainer |
| Wording templates, the heading glossary, the report | `references/locales/<lang>.md` | the maintainer |
| README | `README.md` (EN) + `README.ru.md` | the maintainer |

Page frame names the skill **never takes from the locale** — it reads the header `Title` of that same page and assigns it to the frame. Names therefore follow the file's variables automatically; duplicating them in the locale is forbidden: they would drift apart.

---

## 3. One skill per language, not one per language

The decision: **one `spec-kit-docs` for all languages.** (`spec-kit-theme` is a different job, not a different language — see «Two skills, one engine» above.)

The difference between a Russian and an English build is three lists of strings. Everything else matches: the same pipeline, the same Plugin API recipes, the same checklist, the same traps. Two skills would mean duplicating ~100 KB of references and fixing every discovered trap twice. They would drift — exactly the drift that forced the first Chips build to be redone.

A second skill would be justified only if the **structure** of the documentation differed between the EN and RU versions: a different page set, different patterns, a different block order. It does not differ and must not — otherwise the shared engine loses its point.

### The language of the skill itself

`spec-kit-docs` — `SKILL.md` and `references/*` — is **in English**. Reasons:

1. The model reads this text, not the user. Plugin API terms (`detachInstance`, `layoutSizingHorizontal`, `setBoundVariable`) are English anyway — mixed text adds noise on every line.
2. The repository is open to outside contributors, and the skill is its main artefact.
3. Everything the user sees comes from the locales, so the instruction language does not affect the user.

A Russian `SKILL.md` is not maintained: two parallel instruction texts would drift apart faster than two skills.

**`spec-kit-theme` follows the same rule** — English `SKILL.md` and references, bilingual triggers in the `description`. What it deliberately does not have is a `locales/` folder: the skill writes no prose into Figma — variable values and a mode name only — so the one human-facing text is its report, and the report follows the language of the request, worded by the model rather than read from a file. Should the theme skill ever start writing strings into the file, the locale contract of section 5 applies to it from that moment.

### A bilingual `description`

Trigger phrases are listed in both languages in the one field: «собери документацию», «задокументируй компонент», «оформи по шаблону документации» alongside `document this component in Figma`, `build component docs`, `generate ds-doc section`. Otherwise the skill would not fire on an English request.

---

## 4. How the language is chosen

**The rule: documentation language = the language the user phrased the request in.** Written in Russian — the documentation, generated texts and report are Russian. Written in English — everything is English.

This adds no extra questions anywhere.

### The safeguard

The rule has one failure scenario: a Russian-speaking designer building documentation in an English file (or vice versa). Section headings then arrive from the file's variables in one language, while the skill writes block content in the other.

So at step 2, once the engine is resolved, the skill reads the value of `text/docs-header/specification/title` and compares it with the chosen language. A mismatch is **not an error and not a stop**: the skill adds a line to the step report

```
Language:  English (the file's headings are Russian — page headings will stay Russian)
```

and continues. It can be overridden with a single phrase at any moment. Stopping the build over this is forbidden: a file may be deliberately kept mixed.

### What was not chosen, and why

A marker variable `ds-doc/locale` in the `theme` collection was discussed and rejected: it requires everyone who copies the file to know about the variable and remember to update it. A forgotten marker is worse than no marker — it lies with confidence. It can be revisited if the mixed-language scenario turns out to be common.

---

## 5. The locale contract

```
references/
└── locales/
    ├── ru.md
    └── en.md
```

One flat file per language, no nesting. The skill reads **exactly one** of them — the one matching the chosen language. Reading both must never happen: it is wasted context on every build.

The file structure — four sections:

### `## formats`

Everything language-dependent that is not a phrase.

| Key | `ru` | `en` |
|---|---|---|
| `date` | `01.08.26` | the same: the format is dictated by the `ds-doc/changelog/log/date` component — three text slots joined with dots; the locale does not override it. This closed the open question about the `en` date format |
| `quotes` | `«…»` | `“…”` |
| `dash` | `—` with spaces | `—` without spaces |

### `## glossary`

The «property name → block heading» mapping: `Configuration` → Конфигурации / Configurations, `Style` → Стили / Styles, `Size` → Размеры / Sizes, `State` → Состояния / States. A name absent from the glossary transfers verbatim — that is a rule, not a translation gap.

Block order is set by **the component**, not the glossary: specification blocks follow `componentPropertyDefinitions` order. The glossary is responsible only for what to call things.

### `## write`

Strings and templates that go straight into Figma. This is the only place where the skill may write text not taken from the component: `anatomy.title` and `anatomy.description`, the lead template, the property-block description template, the first changelog entry template. A template is a string with substitutions, not an example: paraphrasing it in the pipeline is forbidden, otherwise the locale stops governing the text.

The closed list of what is never generated in any language (configuration purposes, style differences in meaning, text rules, recommendations) lives in `SKILL.md`, not in the locale: it is a rule, not text.

If a string exists neither in the component nor in a template — the block stays empty and goes into the report as a gap. A locale is no place for placeholders.

### `## report`

Labels for the step reports and the final report: «Component», «Pages», «Generated by the skill», «Source typos», «Left unfilled».

### The rule for adding a language

A new language = one new file in `locales/` + a line in the skill's `description` + translated variable values in a copy of the Figma file. Not a line in the pipeline. If adding a language required editing `SKILL.md` — the locale contract has leaked and must be fixed, not worked around.

---

## 6. Two Figma files

| File | Language | What differs from its sibling |
|---|---|---|
| Component Spec Kit | `en` | — ships first |
| Component Spec Kit | `ru` | values of `text/docs-header/*/title` and `*/description`; the `get started` page; the cover; component descriptions |

Everything else — structure, node names, the component set, the composition of the `theme` collection, numeric token values — **must match**. The EN file is made as a Duplicate of the RU file, never rebuilt from scratch: the Russian file remains the structural source of truth even though the English one ships first. Any structural change is made in RU and carried into EN as a separate step; a structural divergence between the files is a bug.

**Both files are named identically — `Component Spec Kit`.** The file name here is not a caption but part of what a user sees when attaching the engine, so the versions must not be told apart by name: the Russian copy would stop being found by default. Distinguish the versions in Community by the publication title and description, not the file name.

Why not one file with language modes: the modes of `theme` are taken — they are the themes, and `spec-kit-theme` adds to them. Even if they were free, modes would switch only the headers. Documentation content is authored text inside a section — modes do not switch it. The file would need two sections per component and would bloat twice as fast.

---

## 7. Versioning

Four independent counters, never to be confused.

| What | Where it counts | How it grows |
|---|---|---|
| **Component version** | the `ds-doc/changelog/log` entry on the Changelog page | `New` → major+1, `Changed` → minor+1, `Fixed` → patch+1. The skill computes it, never asks |
| **`spec-kit-docs`** | `CHANGELOG.md`, its own `## spec-kit-docs` section | SemVer. Major — when the contract with the engine or with the locales changes |
| **`spec-kit-theme`** | `CHANGELOG.md`, its own `## spec-kit-theme` section | SemVer. Major — when the shape of what it writes into `theme` changes |
| **Engine version** | `CHANGELOG.md`, the «Engine» section | grows when the `ds-doc/*` roster, their properties or the collection structure changes |

The two skills version separately on purpose: they change for different reasons and at different rates, and a shared number would announce a release for whichever one stood still. The pack scripts read each skill's version from its own section, so a release is a `### x.y.z` line plus a run of `pack`.

**The compatibility rule:** the skill's major version declares which engine major version it works with. The check is already built into the pipeline — if an expected component is missing, the skill stops and returns three lists: expected, found, missing. That is the compatibility check; no separate mechanism is needed.

Optional — a `ds-system/version` variable in `theme`, so a skill can name the engine version in its report. Not a blocking decision; deferred. Engine 3.0 is an argument for it: both skills had to be re-read against the file to find out what had moved.
