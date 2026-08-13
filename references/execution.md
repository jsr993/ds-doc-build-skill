# Execution and gates

The skill is not tied to a model or a harness. The rules, the engine map and the page specs are pure Figma Plugin API. The only thing that differs is **what** the agent executes code with and takes snapshots with.

## What the agent must have

| Capability | Why |
|---|---|
| execute JS in the Figma file context | all reading and all writing |
| capture an image of a node | layout check after every page |
| write access to the file | no build without it |

Any one missing — stop and say what is lacking. Do not look for workarounds.

## Call contract

Identical for any harness:

- one call — one logical step; a page is never built whole in one call;
- `return` instead of `console.log`: the agent sees only the returned value;
- `setCurrentPageAsync` — exactly once per call;
- return the IDs of every node created or mutated;
- a failed call is never blindly retried: read the error, fix, then retry. A failed script does not execute partially.

## Adapters

| Harness | Code execution | Snapshot |
|---|---|---|
| Any model with Figma MCP | the MCP tool that runs JS in the file | the MCP tool that returns a node image |
| Claude Code + Figma MCP | `use_figma`, with `figma-use` in `skillNames` — mandatory before **every** call | `get_screenshot` |
| An agent inside Figma | Plugin API directly | by the agent's own means |

Tool names never appear in the rules: the text says «execute», «capture an image». The adapter supplies the concrete tool.

## Gates

Five points where the agent **must state facts before acting**. A gate closes with a list of facts, never with «checked» or «all good».

A gate is not a question to the user. State the facts and move on. Stops happen only where «stop» is written: references unreadable, no library, input is not a component, a `ds-*` or a variable not found, moving the source set into `Slot Component` (the single question of the build).

| Gate | Report before moving on |
|---|---|
| **G0 Readiness** | list the files read by name and the skill version; on any gap, add the install diagnosis (stale markers, verdict); say how the library was found and how the engine will be resolved |
| **G1 Input and inventory** | type and name of the node received; variant count, axes with values, property order verbatim; where the lead comes from (`description` or generation) |
| **G2 Staging** | section id, list of resolved `ds-*`, fonts loaded |
| **G3 Page** | before: which page, from which pattern. After: what the snapshot shows, any overflows. Three times — changelog, specification, components |
| **G4 Handover** | walk the checklist item by item, each with a fact; list generated texts, source typos and gaps |

Gate rules:

1. **Not passed — no writing.** Any write to the file before G2 closes is an error.
2. **A gate cannot close without named facts.** «Inventory taken» is not a report. «112 variants, five axes: Configuration=Only Label|…» is a report.
3. **Doubt — stop.** A skill rule contradicts what the file shows → stop and ask, never pick for yourself.
4. **Mark the generated.** Any text written by the skill rather than taken from the component goes into the G4 report as a list.

Gates are not for ceremony. They close the three places where agents most often break a build: writing to the file before taking the inventory; declaring a check passed without doing it; improvising on Plugin API traps instead of stopping.
