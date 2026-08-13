# Component Spec Kit

[Русская версия →](README.ru.md)

A design-system documentation engine in Figma, and the `ds-doc-build` skill that assembles that documentation for you in Claude Code.

Component documentation is a Figma section of three pages: `Changelog`, `Specification`, `Components`. Documentation does not exist without them, and exactly these the skill builds. Pages are never drawn from scratch: they assemble from ready-made `ds-doc/*` patterns, and every visual comes from the `decoration` variable collection. Change a token — all documentation redraws at once.

The engine carries three more patterns — `Animated`, `Tips and practices`, `Microcopy`. The skill does not create them: what goes there cannot be derived from a component. Assemble them by hand from the library when you have something to say.

You can build a section manually. The skill does the same thing, only faster, and it never forgets the rules.

**This is a design representation of a component, not an implementation spec for developers.**

- **Start here:** [OVERVIEW.md](OVERVIEW.md) — what works with what, which file goes with which repository
- **Repository:** [github.com/jsr993/ds-doc-build-skill](https://github.com/jsr993/ds-doc-build-skill)
- **The engine Figma file:** [Component Spec Kit in Figma Community](https://www.figma.com/community/file/1666170620013431022/component-spec-kit) — duplicate it
- **Ready-made skill archive:** [`dist/ds-doc-build.skill`](dist/ds-doc-build.skill)
- **How it all works inside:** [ARCHITECTURE.md](ARCHITECTURE.md) — for those who develop the engine and the skill

> One skill serves both languages: **the documentation language follows the language of your request**. Write in English — block content comes out English; write in Russian — Russian. Section headings, meanwhile, come from the Figma file's variables and follow its language.

---

## Part 1. Working with the documentation in Figma

### Preparing the file

1. Duplicate the engine file into your project.
2. Change the tokens in **Local Variables → `decoration`** to match your design system: colours, spacing, radii, typography.
3. Publish the file and attach it as a library — or build documentation right in the copy.

**When publishing, check that the variables shipped along with the components.** The `decoration` collection must make it into the publication: if it is hidden (`Hide from publishing`) or your Figma plan does not publish variables, components will import fine and the build will stop at section styling — nothing for the skill to bind to. The symptom is exactly that: pages assemble, the section does not. You can check before building: in the consuming file open `Libraries` — the engine library must list both components and variables.

The skill finds engine components **by name**, not by id, so it works in any copy of the file. Engine names are part of the contract: never rename `ds-*`, typos included (`ds-doc/interation`, `Show Desciption#757:0`).

### How a section is built

The skill neither invents page names nor keeps a list of them — it reads them from the header `Title`, which is bound to a `decoration` variable. Names therefore follow the file's theme and language; below is what the source file produces.

| Page | Pattern | About |
|---|---|---|
| `Changelog` | `ds-doc/changelog` | version, change type, date, authors |
| `Specification` | `ds-doc/specification` | lead, anatomy, one block per axis |
| `Components` | `ds-doc/components` | the component set itself with axis labels |
| `Animated` | `ds-doc/interation` | trigger → reaction, motion tokens — **by hand** |
| `Tips and practices` | `ds-doc/tips-practices` | do / don't pairs — **by hand** |
| `Microcopy` | `ds-doc/microcopy` | text rules per slot — **by hand** |

Page assembly order: pattern instance → `Detach` → fill `Content` with `ds-paragraph` and `ds-doc-component` atoms. Detach is needed because the number of blocks is unknown in advance and patterns expose no public properties. **The header inside a page stays a `ds-doc-header` instance** — leave it alone.

All pages of one component go into one section, left to right, 100 from the edge, 200 between pages. A section has no auto-layout — fit it manually as the last step.

### Formatting rules

1. **Never touch the header.** `Title` is the section name (`Changelog`, `Specification`, `Components`), not the component name. All three header texts are bound to `decoration` variables; any overwrite severs the link.
2. **No numbers in text.** Show sizes, spacing, radii, colours and typography with Figma annotations (with `properties` filled) and `addMeasurement` rulers. Values then update with the component, and documentation is never rewritten — blocks are only added or removed.
3. **Never set visuals by value.** No literal `fills`, `fontSize`, `cornerRadius`. Bind to `decoration` variables only — otherwise the block falls out of the theme. The skill never writes into the `decoration` collection itself.
4. **Specification block order = component property order.** No sorting, no regrouping.
5. **Anatomy is about architecture, not the picture.** One block per configuration, annotations only on the differences. Duplicating identical annotations on every block is an error.
6. **The Components page is one block per component.** `Slot Component` holds the component set itself, whole — not a spread of instances. A family of several sets is named with a slash: `Chips / Item`.
7. **Facts are never invented.** Variants, states, anatomy and property order come from the component. Headings and descriptions the skill words itself from templates — and lists everything generated in the report so you know what to re-read. Meaning that cannot be derived from the component — when to use which configuration, how styles differ in purpose, text rules, recommendations — stays empty: an empty block beats a plausible fabrication.
8. **Names transfer verbatim**, source typos included: search and verification run on names. Noticed typos go into the report, never corrected in documentation text.

### Annotation categories

Annotation presets in the file: **Development** (green), **Interaction** (blue), **Accessibility** (pink), **Content** (orange).

---

## Part 2. The `ds-doc-build` skill for Claude Code

The skill reads the component, takes an inventory of variants and properties, and builds a section from the three `ds-doc` patterns. The source component it only reads.

**It runs autonomously.** From link to finished section — no plan to confirm, no interview. Built for the batch job: documenting dozens of components in a row, not one. Questions arise exactly where the skill stops: no library, input is not a component, an engine variable is missing — and once before moving your component into the slot on the `Components` page.

### What you need

- **Claude Code** — the Claude client that lives in the terminal.
- **Figma MCP** with write access to the file (write to canvas).
- A file where the `ds-*` engine is available: your copy, or an attached library.

The skill checks the library as step zero and recognises it **by the `decoration` variable collection**, not by name. Your own copy published under your own name works the same as the original; «Component Spec Kit» is just the default. Neither a library nor local `ds-*` in the file — the build stops and asks to attach one: a library cannot be attached from code, the Plugin API cannot do it.

### Installing the skill

1. Download the archive. `dist/` holds the same build in two shapes — pick by how you install:

   | File | Inside | Use when |
   |---|---|---|
   | [`ds-doc-build.skill`](dist/ds-doc-build.skill) | `SKILL.md` + `references/` at the root | unpacking by hand **into** `~/.claude/skills/ds-doc-build/` |
   | [`ds-doc-build.zip`](dist/ds-doc-build.zip) | everything wrapped in a `ds-doc-build/` folder | uploading to a skill form, or unpacking anywhere — the folder comes with the archive |

   Each also exists under a versioned name (`ds-doc-build-4.0.0.skill`, `ds-doc-build-4.0.0.zip`) so a build on disk identifies itself without being opened. The unversioned names are permanent addresses and always carry the current version.
2. **Delete the old folder first** — never unpack over it. The reference set changes between generations, and a leftover file makes the new `SKILL.md` read the folder as stale:

   ```bash
   rm -rf ~/.claude/skills/ds-doc-build
   ```

3. Unpack it into your skills folder:

   ```
   macOS / Linux   ~/.claude/skills/ds-doc-build/
   Windows         %USERPROFILE%\.claude\skills\ds-doc-build\
   ```

4. Check the structure — it must look like this:

   ```
   ds-doc-build/
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
git clone https://github.com/jsr993/ds-doc-build-skill.git ~/src/ds-doc-build-skill
ln -s ~/src/ds-doc-build-skill ~/.claude/skills/ds-doc-build
```

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

From there you barely intervene. The skill reports the inventory — how many variants, which axes, in what order the specification blocks will go — and builds the three pages, showing a snapshot after each. The single question in the whole build is permission to move your component set inside the documentation section.

You can also invoke the skill directly: `/ds-doc-build`.

### Where it will still stop

Exactly five stops, all about it being pointless or impermissible to continue:

- the `references/` files are unreadable — the skill was unpacked incompletely;
- the file has neither a library nor local `ds-*`;
- the input is not a component but an instance, frame, section or group;
- an engine component or a `decoration` variable was not found;
- moving your component set into `Slot Component` — the only action outside the documentation section, never done without permission.

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
| the columns axis on `Components` | the first VARIANT axis in property declaration order |

Everything the skill wrote itself it lists in the report as a separate list. That is the place worth reading — the rest is verifiable against the component.

### What the skill does not do

- It never changes the source component — properties, layers, name and description are read-only. Moving the set into `Slot Component` happens only with your permission.
- It writes nothing outside its own section.
- It never sets visuals by value and never writes into the `decoration` collection.
- It never invents meaning: configuration purposes, style differences, text rules and recommendations it leaves empty and lists in the report rather than masking with a placeholder.
- It does not build `Animated`, `Tips and practices` or `Microcopy` — those pages are made by hand.

### What you get

A section in Figma and a report: a link to the section, the three pages, block and variant counts, the list of generated texts, typos noticed in source names, the list of gaps. On separate request the skill exports a markdown contract — a reverse pass over the pages already built, which doubles as a check that what was assembled reads unambiguously.

---

## Repository structure

```
.
├── SKILL.md                      # the skill itself: pipeline, rules, checklist
├── references/
│   ├── ds-engine-map.md          # engine map: names, node-ids, keys, properties
│   ├── build-recipes.md          # Figma Plugin API snippets
│   ├── annotations.md            # annotations and measurements
│   ├── contract-template.md      # markdown contract template
│   └── locales/                  # the strings the skill writes into documentation
│       ├── en.md
│       └── ru.md
├── dist/
│   ├── ds-doc-build.skill        # flat: SKILL.md at the archive root
│   ├── ds-doc-build-4.0.0.skill  # same, version in the name
│   ├── ds-doc-build.zip          # wrapped in a ds-doc-build/ folder
│   └── ds-doc-build-4.0.0.zip    # same, version in the name
├── scripts/
│   ├── pack.sh                   # rebuild the archive (macOS / Linux)
│   └── pack.ps1                  # rebuild the archive (Windows)
├── OVERVIEW.md                   # the cross-cutting doc: two halves and how they pair
├── ARCHITECTURE.md               # solution layers, localisation, versioning
├── CHANGELOG.md
├── README.md
└── README.ru.md                  # the Russian version of this file
```

### Rebuilding the archive after edits

```bash
./scripts/pack.sh          # macOS / Linux
powershell -File scripts/pack.ps1   # Windows
```

---

## Feedback

Telegram [@jsr_i](https://t.me/jsr_i), email [ishmirzaev.jasur@gmail.com](mailto:ishmirzaev.jasur@gmail.com).

## License

[MIT](LICENSE).
