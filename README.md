# Component Spec Kit

[Русская версия →](README.ru.md)

A design-system documentation engine in Figma, and two Claude Code skills that work on it: **`spec-kit-docs`** assembles the documentation, **`spec-kit-theme`** restyles it.

Component documentation is a Figma section of three pages: `Changelog`, `Specification`, `Components`. Documentation does not exist without them, and exactly these the skill builds. Pages are never drawn from scratch: they assemble from ready-made `ds-doc/*` patterns, and every visual comes from the `theme` variable collection. Change a token — all documentation redraws at once.

The engine carries one more pattern — `Interaction`. The skill does not create it: what goes there cannot be derived from a component. Assemble it by hand from the library when you have something to say.

You can build a section manually. The skill does the same thing, only faster, and it never forgets the rules.

The second skill works one level down. Every visual in the documentation comes from the `theme` variable collection, and a mode of that collection is a theme. `spec-kit-theme` reads a reference image, expands it into all 164 variables and writes them as a new mode — so the same documentation can be shown in a different skin without a single page being touched.

**This is a design representation of a component, not an implementation spec for developers.**

- **Start here:** [OVERVIEW.md](OVERVIEW.md) — what works with what, which file goes with which repository
- **Repository:** [github.com/jsr993/component-spec-kit](https://github.com/jsr993/component-spec-kit)
- **The engine Figma file:** [Component Spec Kit in Figma Community](https://www.figma.com/community/file/1666170620013431022/component-spec-kit) — duplicate it
- **Ready-made skill archives:** [`dist/spec-kit-docs.skill`](dist/spec-kit-docs.skill), [`dist/spec-kit-theme.skill`](dist/spec-kit-theme.skill)
- **How it all works inside:** [ARCHITECTURE.md](ARCHITECTURE.md) — for those who develop the engine and the skill

> `spec-kit-docs` serves both languages: **the documentation language follows the language of your request**. Write in English — block content comes out English; write in Russian — Russian. Section headings, meanwhile, come from the Figma file's variables and follow its language.

---

## Part 1. Working with the documentation in Figma

### Preparing the file

1. Duplicate the engine file into your project.
2. Change the tokens in **Local Variables → `theme`** to match your design system: colours, spacing, radii, typography.
3. Publish the file and attach it as a library — or build documentation right in the copy.

**When publishing, check that the variables shipped along with the components.** The `theme` collection must make it into the publication: if it is hidden (`Hide from publishing`) or your Figma plan does not publish variables, components will import fine and the build will stop at section styling — nothing for the skill to bind to. The symptom is exactly that: pages assemble, the section does not. You can check before building: in the consuming file open `Libraries` — the engine library must list both components and variables.

The skill finds engine components **by name**, not by id, so it works in any copy of the file. Engine names are part of the contract: never rename `ds-*`, typos included (`ds-doc/interation`, `Show Desciption#757:0`).

### How a section is built

The skill neither invents page names nor keeps a list of them — it reads them from the header `Title`, which is bound to a `theme` variable. Names therefore follow the file's theme and language; below is what the source file produces.

| Page | Pattern | About |
|---|---|---|
| `Changelog` | `ds-doc/changelog` | version, change type, date, authors |
| `Specification` | `ds-doc/specification` | lead, anatomy, one block per axis |
| `Components` | `ds-doc/components` | the component set itself with axis labels |
| `Interaction` | `ds-doc/interation` | trigger → reaction, motion tokens — **by hand** |

Page assembly order: pattern instance → `Detach` → fill `Content` with `ds-doc/specification/paragraph` and `ds-doc/specification/component` atoms. Detach is needed because the number of blocks is unknown in advance and patterns expose no public properties. **The header inside a page stays a `ds-doc/header` instance** — leave it alone.

All pages of one component go into one section, left to right, 100 from the edge, 200 between pages. A section has no auto-layout — fit it manually as the last step.

### Formatting rules

1. **Never touch the header.** `Title` is the section name (`Changelog`, `Specification`, `Components`), not the component name. All three header texts are bound to `theme` variables; any overwrite severs the link.
2. **No numbers in text.** Show sizes, spacing, radii, colours and typography with Figma annotations (with `properties` filled) and `addMeasurement` rulers. Values then update with the component, and documentation is never rewritten — blocks are only added or removed.
3. **Never set visuals by value.** No literal `fills`, `fontSize`, `cornerRadius`. Bind to `theme` variables only — otherwise the block falls out of the theme. The skill never writes into the `theme` collection itself.
4. **Specification block order = component property order.** No sorting, no regrouping.
5. **Anatomy is about architecture, not the picture.** One block per configuration, annotations only on the differences. Duplicating identical annotations on every block is an error.
6. **The Components page is one block per component.** `Slot Component` holds the component set itself, whole — not a spread of instances. A family of several sets is named with a slash: `Chips / Item`.
7. **Facts are never invented.** Variants, states, anatomy and property order come from the component. Headings and descriptions the skill words itself from templates — and lists everything generated in the report so you know what to re-read. Meaning that cannot be derived from the component — when to use which configuration, how styles differ in purpose, text rules, recommendations — stays empty: an empty block beats a plausible fabrication.
8. **Names transfer verbatim**, source typos included: search and verification run on names. Noticed typos go into the report, never corrected in documentation text.

### Annotation categories

Annotation presets in the file: **Development** (green), **Interaction** (blue), **Accessibility** (pink), **Content** (orange).

---

## Part 2. The `spec-kit-docs` skill — building the documentation

The skill reads the component, takes an inventory of variants and properties, and builds a section from the three `ds-doc` patterns. The source component it only reads.

**It runs autonomously.** From link to finished section — **no confirmations of any kind**: no plan, no interview, no question before writing. Built for the batch job: documenting dozens of components in a row, not one. The skill stops only where there is nowhere to go: no library, input is not a component, a missing engine variable, unreadable references. A stop is a dead end, not a checkpoint.

### What you need

- **Claude Code** — the Claude client that lives in the terminal.
- **Figma MCP** with write access to the file (write to canvas).
- A file where the `ds-*` engine is available: your copy, or an attached library.

The skill checks the library as step zero and recognises it **by the `theme` variable collection**, not by name. Your own copy published under your own name works the same as the original; «Component Spec Kit» is just the default. Neither a library nor local `ds-*` in the file — the build stops and asks to attach one: a library cannot be attached from code, the Plugin API cannot do it.

### Installing the skill

1. Download the archive. `dist/` holds the same build in two shapes — pick by how you install:

   | File | Inside | Use when |
   |---|---|---|
   | [`spec-kit-docs.skill`](dist/spec-kit-docs.skill) | `SKILL.md` + `references/` at the root | unpacking by hand **into** `~/.claude/skills/spec-kit-docs/` |
   | [`spec-kit-docs.zip`](dist/spec-kit-docs.zip) | everything wrapped in a `spec-kit-docs/` folder | uploading to a skill form, or unpacking anywhere — the folder comes with the archive |

   Each also exists under a versioned name (`spec-kit-docs-6.0.0.skill`, `spec-kit-docs-6.0.0.zip`) so a build on disk identifies itself without being opened. **`dist/` holds the current version only** — the build deletes older ones; git keeps the history. `spec-kit-theme` ships in the same four shapes under its own name.
2. **Delete the old folder first** — never unpack over it. The reference set changes between generations, and a leftover file makes the new `SKILL.md` read the folder as stale:

   ```bash
   rm -rf ~/.claude/skills/spec-kit-docs
   ```

   Coming from version 5 or earlier, the installed folder still carries the skill's previous name. Delete that one too — otherwise Claude Code lists both and fires whichever it matches first:

   ```bash
   rm -rf ~/.claude/skills/ds-doc-build
   ```

3. Unpack it into your skills folder:

   ```
   macOS / Linux   ~/.claude/skills/spec-kit-docs/
   Windows         %USERPROFILE%\.claude\skills\spec-kit-docs\
   ```

   The path matters: Claude Code lists a skill only when `SKILL.md` with its frontmatter sits **directly inside** the folder. An empty folder, or files one level deeper, means the skill never appears in the picker — and no error is raised either.

4. Check the structure — it must look like this:

   ```
   spec-kit-docs/
   ├── SKILL.md
   └── references/
       ├── ds-engine-map.md
       ├── build-recipes.md
       ├── annotations.md
       ├── contract-template.md
       └── locales/
           ├── en.md
           └── ru.md
   ```

   **Without the `references` folder the skill refuses to run.** It verifies its own completeness as step zero and stops if a single file is unreadable: without the engine map and the recipes the output would differ from run to run, and you would not notice.

5. Claude Code picks up skill folder changes on the fly. A restart is needed only if the `skills` folder did not exist before.

An alternative to the archive — clone the repository and symlink it:

```bash
git clone https://github.com/jsr993/component-spec-kit.git ~/src/component-spec-kit
ln -s ~/src/component-spec-kit/skills/spec-kit-docs  ~/.claude/skills/spec-kit-docs
ln -s ~/src/component-spec-kit/skills/spec-kit-theme ~/.claude/skills/spec-kit-theme
```

Both skills live side by side under `skills/`, so one clone covers the pair and `git pull` updates them together.

### First-time setup

1. Install Claude Code and sign in to your Claude account.
2. Attach the Figma MCP:

   ```bash
   claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp
   ```

3. In Claude Code type `/mcp`, pick `figma`, authorise. Figma will ask for permission to write to files — grant it, otherwise the skill can only read.
4. Then install the skill as above.

### How to run it

Send a link to **the component itself** — a `COMPONENT` or `COMPONENT_SET`:

```
Document this component
https://www.figma.com/design/<fileKey>/<file>?node-id=3014-2258
```

A link to an instance, frame, section or group will not do: the skill names the type of what arrived, says it needs a component link, and stops. Not pedantry — that same node later goes into `Slot Component` on the Components page, and an instance cannot go there.

From there you do not intervene at all. The skill reports the inventory — how many variants, which axes, in what order the specification blocks will go — and builds the three pages, showing a snapshot after each, to the end.

You can also invoke the skill directly: `/spec-kit-docs`.

### Where it will still stop

Exactly four stops, each a dead end rather than a checkpoint:

- the `references/` files are unreadable — the skill was unpacked incompletely;
- the file has neither a library nor local `ds-*`;
- the input is not a component but an instance, frame, section or group;
- an engine component or a `theme` variable was not found.

Everything else the skill decides itself and reports what it decided. A deliberate trade: across a stream of fifty components, a question per component is not care — it is a full stop.

### What it decides for you

| Decision | Rule |
|---|---|
| changelog version and type | first build — `1.0.0 / New`; rebuild — `New` → major+1, `Changed` → minor+1, `Fixed` → patch+1, default `Changed` |
| date | today |
| authors | the `Designers` slot is untouched — the component default stays |
| specification lead | a non-empty component `description` verbatim; empty — from the template |
| block headings | from the locale glossary: `Configuration` → Configurations, `Style` → Styles, `Size` → Sizes, `State` → States; the rest as in the component |
| row descriptions | on for configurations, styles and sizes; off for states |
| the axes on `Components` | read from the set's actual layout — columns from the `x` clusters, vertical levels from the `y` clusters, outermost first |

Everything the skill wrote itself it lists in the report as a separate list. That is the place worth reading — the rest is verifiable against the component.

### What the skill does not do

- It never changes the source component — properties, layers, name and description are read-only. It does move the set into `Slot Component`, which changes its parent and position on the canvas and nothing else; the move is named in the report.
- It writes nothing outside its own section.
- It never sets visuals by value and never writes into the `theme` collection.
- It never invents meaning: configuration purposes, style differences, text rules and recommendations it leaves empty and lists in the report rather than masking with a placeholder.
- It does not build `Interaction` — that page is made by hand.

### What you get

A section in Figma and a report: a link to the section, the three pages, block and variant counts, the list of generated texts, typos noticed in source names, the list of gaps. On separate request the skill exports a markdown contract — a reverse pass over the pages already built, which doubles as a check that what was assembled reads unambiguously.

---

## Part 3. The `spec-kit-theme` skill — restyling it

Everything you see in the documentation is a `theme` variable, and a **mode** of that collection is a theme. `lite`, `enterprise` and `engineering` ship with the file; switch the mode and every page ever built redraws.

`spec-kit-theme` adds a mode. You send a picture of a design you like — a screenshot of a site, a page from a style guide, a shot of someone else's documentation — and the skill writes a new column into `theme`.

> The skill is currently written in Russian. It answers English requests, but its own text and reports are Russian.

### How it works

The skill does **not** read 164 values off the picture. A model asked to name 164 numbers will name 164 plausible ones, and plausible is not consistent — the scale stops being a scale.

Instead the picture yields **fourteen decisions**: how light the background is, how cards are separated, how round the corners are, how dense the layout is, which families carry headings and body text, where the accent sits. Those fourteen are expanded into the full collection by fixed tables. What cannot be read off the picture is inherited from the sample mode and named as inherited in the report — never guessed.

Before the brief comes a coarser choice: one of **six territories** of style, described in `references/style-space.md`. It is the frame that keeps a theme from drifting into a look the structure cannot carry.

### Running it

Attach an image and ask for a theme:

```
Сделай тему по этому референсу
https://www.figma.com/design/<fileKey>/<file>
```

The skill reports the territory and the whole brief — each decision marked *read from the picture*, *from the territory*, or *inherited* — then expands, checks, and writes. That report is the thing worth reading: it is the only place where what the reference gave is separated from what the expansion decided.

### What it will not do

- **It never touches an existing mode.** Any write into `lite` or `enterprise` is a bug. A theme that does not work costs one mode deletion.
- **It never breaks an alias.** The semantic tier stays aliased onto the primitives, exactly as in the sample mode; flatten an alias and the theme stops responding when a primitive is edited.
- **It never invents a font.** Families come from Google Fonts available in Figma, and only after `listAvailableFontsAsync` confirms them; substitutions are named in the report.
- **It never restyles the structure.** Section texts, document width and the small `layer-03` details are copied from the sample verbatim — they are not part of a theme.

Checks run before anything is written: contrast (`primary` ≥ 7:1, `secondary` ≥ 4.5:1), monotone scales, fonts that exist. A failed check means a corrected brief and a second expansion, not a written mode.

### Installing it

Same as `spec-kit-docs`, under its own name:

```
macOS / Linux   ~/.claude/skills/spec-kit-theme/
Windows         %USERPROFILE%\.claude\skills\spec-kit-theme\
```

```
spec-kit-theme/
├── SKILL.md
└── references/
    ├── theme-map.md        # the collection: 164 variables, the two tiers, what is not a theme
    ├── token-usage.md      # which token drives what on canvas
    ├── style-space.md      # the six territories and what the structure cannot carry
    ├── expansion-rules.md  # the fourteen decisions and their expansion tables
    └── recipes.md          # Plugin API: addMode, setValueForMode, aliases
```

This skill checks its own completeness too, and stops the same way if a reference is unreadable.

---

## Repository structure

```
.
├── skills/
│   ├── spec-kit-docs/                # builds the documentation
│   │   ├── SKILL.md                  # pipeline, rules, checklist
│   │   └── references/
│   │       ├── ds-engine-map.md      # engine map: names, node-ids, keys, properties
│   │       ├── build-recipes.md      # Figma Plugin API snippets
│   │       ├── annotations.md        # annotations and measurements
│   │       ├── contract-template.md  # markdown contract template
│   │       └── locales/              # the strings the skill writes into documentation
│   │           ├── en.md
│   │           └── ru.md
│   └── spec-kit-theme/               # restyles it
│       ├── SKILL.md
│       └── references/
│           ├── theme-map.md          # the collection: 164 variables, the two tiers
│           ├── token-usage.md        # which token drives what on canvas
│           ├── style-space.md        # the six territories, and what is unreachable
│           ├── expansion-rules.md    # the fourteen decisions and their expansion
│           └── recipes.md            # Plugin API: addMode, setValueForMode, aliases
├── dist/                             # four archives per skill, current version only
│   ├── spec-kit-docs.skill           # flat: SKILL.md at the archive root
│   ├── spec-kit-docs-6.0.0.skill     # same, version in the name
│   ├── spec-kit-docs.zip             # wrapped in a spec-kit-docs/ folder
│   ├── spec-kit-docs-6.0.0.zip       # same, version in the name
│   └── spec-kit-theme.*              # the same four, under its own name
├── scripts/
│   ├── pack.sh                       # rebuild every archive (macOS / Linux)
│   └── pack.ps1                      # rebuild every archive (Windows)
├── OVERVIEW.md                       # the cross-cutting doc: the halves and how they pair
├── ARCHITECTURE.md                   # solution layers, localisation, versioning
├── CHANGELOG.md
├── README.md
└── README.ru.md                      # the Russian version of this file
```

Adding a skill is adding a folder under `skills/` with a `SKILL.md` and a `references/` beside it — the pack scripts walk the directory and need no editing.

### Rebuilding the archives after edits

One run rebuilds every skill in `skills/`:

```bash
./scripts/pack.sh          # macOS / Linux
powershell -File scripts/pack.ps1   # Windows
```

---

## Feedback

Telegram [@jsr_i](https://t.me/jsr_i), email [ishmirzaev.jasur@gmail.com](mailto:ishmirzaev.jasur@gmail.com).

## License

[MIT](LICENSE).
