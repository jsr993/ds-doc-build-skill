# Plugin API recipes

The code below is pure Plugin API, identical for any harness. What executes it and the call contract — in `SKILL.md`, section «How to run it».

---

## 0. Resolving property keys

The suffix (`#814:6`) is stable within a file but changes when the library is republished. Never hardcode — resolve by prefix.

```js
function propKey(node, name) {
  const defs = node.type === "INSTANCE"
    ? node.mainComponent.parent?.type === "COMPONENT_SET"
      ? node.mainComponent.parent.componentPropertyDefinitions
      : node.mainComponent.componentPropertyDefinitions
    : node.componentPropertyDefinitions;
  const hit = Object.keys(defs).find(k => k === name || k.split("#")[0] === name);
  if (!hit) throw new Error(`property "${name}" not found: ${Object.keys(defs).join(", ")}`);
  return hit;
}

function setProps(instance, map) {
  const out = {};
  for (const [name, value] of Object.entries(map)) out[propKey(instance, name)] = value;
  instance.setProperties(out);
}
```

VARIANT properties (`Type`, `Large`, `Vertical`, `Position`) carry no suffix — the same resolver catches them.

---

## 1. Source component inventory (read-only)

Input validation lives here, before any write.

```js
const node = await figma.getNodeByIdAsync("SRC_ID");

if (node.type !== "COMPONENT_SET" && node.type !== "COMPONENT") {
  return { stop: true, got: { type: node.type, name: node.name },
           reason: "a link to the component itself is required — COMPONENT_SET or COMPONENT" };
}
// a variant inside a set — climb to the set, it is the same component
const set = node.type === "COMPONENT" && node.parent?.type === "COMPONENT_SET" ? node.parent : node;

const defs = set.componentPropertyDefinitions;
const axes = Object.entries(defs)
  .filter(([, d]) => d.type === "VARIANT")
  .map(([k, d]) => ({ name: k, values: d.variantOptions }));

const variants = set.type === "COMPONENT_SET"
  ? set.children.map(c => ({ id: c.id, name: c.name, props: c.variantProperties }))
  : [{ id: set.id, name: set.name, props: null }];

const sample = set.type === "COMPONENT_SET" ? set.defaultVariant : set;
function tree(n, d) {
  return {
    name: n.name, type: n.type,
    main: n.type === "INSTANCE" ? n.mainComponent?.name : undefined,
    kids: n.children && d < 3 && n.type !== "INSTANCE" ? n.children.map(c => tree(c, d + 1)) : undefined
  };
}

return {
  name: set.name, key: set.key, description: set.description,
  docs: set.documentationLinks,
  axes, variantCount: variants.length,
  props: Object.fromEntries(Object.entries(defs).map(([k, d]) => [k, { type: d.type, def: d.defaultValue }])),
  anatomy: tree(sample, 0),
  variants: variants.slice(0, 200)
};
```

Tokens — a separate `get_variable_defs` call on `defaultVariant`.

---

## 2. Resolving the engine

The skill is portable: the engine is found by name, not by id. Node-ids and keys from `ds-engine-map.md` are only a fast path in the source file.

```js
// one read-only call: collect ds-* across every page of the file
const wanted = ["ds-doc/changelog", "ds-doc/specification", "ds-doc/interation",
                "ds-doc/tips-practices", "ds-doc/microcopy", "ds-doc/components",
                "ds-doc-header", "ds-paragraph", "ds-doc-component", "ds-doc-component-state",
                "ds-doc-component-label", "Name", "ds-log", "ds-log-designers",
                "ds-log-changelog-version", "ds-log-changelog-date", "ds-log-label"];

const found = {};
for (const page of figma.root.children) {
  if (Object.keys(found).length === wanted.length) break;
  await page.loadAsync();
  for (const n of page.findAllWithCriteria({ types: ["COMPONENT", "COMPONENT_SET"] })) {
    if (wanted.includes(n.name) && !found[n.name]) found[n.name] = n.id;
  }
}
const missing = wanted.filter(w => !found[w]);
return { found, missing };
```

Name matching is exact: `wanted.includes(n.name)` — no `startsWith`, `toLowerCase` or `trim`. A `ds-` prefix match would catch the user's own components.

Empty → try `importComponentByKeyAsync` with the map's keys (the engine is attached as a library; sets go through `importComponentSetByKeyAsync`). Still empty → return `{ stop: true, expected, found, missing }` and stop. Never pick similar names, never substitute home-made frames: the cause is almost always renamed engine components.

Keep the collected `name → id` map in build memory and pass it into subsequent calls as string literals.

Fonts — harvest from engine nodes, never hardcode:

```js
const fonts = new Map();
for (const t of headerInstance.findAllWithCriteria({ types: ["TEXT"] }))
  for (const seg of t.getStyledTextSegments(["fontName"]))
    fonts.set(seg.fontName.family + "|" + seg.fontName.style, seg.fontName);
await Promise.all([...fonts.values()].map(f => figma.loadFontAsync(f)));
```

---

## 2a. Staging: the section and its styling

Section visuals ride on `decoration` variables. Set colours and radius **by binding only**, never by value. `setBoundVariableForPaint` returns a **new** paint — always capture the result.

```js
const col = (await figma.variables.getLocalVariableCollectionsAsync())
  .find(c => c.name === "decoration");
const vars = {};
for (const id of col.variableIds) {
  const v = await figma.variables.getVariableByIdAsync(id);
  if (v) vars[v.name] = v;
}
const need = ["space/global/radius/ds-radius-section", "color/section/ds-section-01",
              "color/section/ds-section-02", "color/ds-tertiary"];
const missing = need.filter(n => !vars[n]);
if (missing.length) return { stop: true, missing };   // never substitute hand-picked colours

const solid = (opacity) => ({ type: "SOLID", color: { r: 0, g: 0, b: 0 }, opacity });

// two fills: a base and a near-transparent one on top
const f2 = figma.variables.setBoundVariableForPaint(solid(1),    "color", vars["color/section/ds-section-02"]);
const f1 = figma.variables.setBoundVariableForPaint(solid(0.01), "color", vars["color/section/ds-section-01"]);
section.fills = [f2, f1];

const st = figma.variables.setBoundVariableForPaint(solid(0.4), "color", vars["color/ds-tertiary"]);
section.strokes = [st];
section.strokeWeight = 1;
section.strokeAlign = "INSIDE";

for (const corner of ["topLeftRadius", "topRightRadius", "bottomLeftRadius", "bottomRightRadius"])
  section.setBoundVariable(corner, vars["space/global/radius/ds-radius-section"]);
```

With the engine attached as a library, local collections are empty — import the variables by key instead: `figma.variables.importVariableByKeyAsync(key)`. Keys come from `teamLibrary.getVariablesInLibraryCollectionAsync(collection.key)`, or from the engine file's variables directly.

The `decoration` collection is multi-mode (`theme v1|v2|v3`) — same names, different values. The skill binds the variable; Figma resolves the value for the active mode.

If the file already has a finished documentation section — copy its settings (`fills`, `strokes`, `strokeWeight`, `strokeAlign`, `boundVariables`) onto yours: the owner's edits carry over by themselves.

Page layout: `PAD = 100` from the section edge, `GAP = 200` between pages, left to right in build order.

```js
const PAD = 100, GAP = 200;
const right = section.children.reduce((m, c) => Math.max(m, c.x + c.width), PAD - GAP);
frame.x = right + GAP;      // the first page lands at PAD
frame.y = PAD;
```

Fitting — **the last step**, once every page is built and heights are final:

```js
let maxR = 0, maxB = 0;
for (const c of section.children) { maxR = Math.max(maxR, c.x + c.width); maxB = Math.max(maxB, c.y + c.height); }
section.resizeWithoutConstraints(Math.ceil(maxR + PAD), Math.ceil(maxB + PAD));
```

`SECTION` has no auto-layout and never hugs — only an explicit `resizeWithoutConstraints`.

---

## 2b. Creating the section

```js
const page = await figma.getNodeByIdAsync("TARGET_PAGE_ID");
await figma.setCurrentPageAsync(page);           // exactly once per call

// fonts are already loaded at the engine-resolution step

const right = page.children.reduce((m, n) => Math.max(m, n.x + n.width), 0);

const section = figma.createSection();
section.name = "COMPONENT_NAME";
section.x = right + 400;
section.y = 0;
section.resizeWithoutConstraints(8000, 8000);   // temporary size, fitted at the end

return { sectionId: section.id };
```

Take engine nodes from the map collected in recipe 2: `await figma.getNodeByIdAsync(found["ds-doc/changelog"])`.

---

## 3. A page: instance → detach → fill

```js
const pattern = await figma.getNodeByIdAsync(found["ds-doc/specification"]);
const page = pattern.createInstance();
const frame = page.detachInstance();                          // → FrameNode

const section = await figma.getNodeByIdAsync("SECTION_ID");
section.appendChild(frame);
frame.x = 0; frame.y = 0;

// the header stays a ds-doc-header instance — DO NOT touch its values.
// Title/Description come from the pattern and are bound to decoration variables.
// Any setProps on them severs the binding and replaces the section name.
const header = frame.findAllWithCriteria({ types: ["INSTANCE"] })
  .find(n => n.mainComponent?.name === "ds-doc-header");

// frame name = the header Title, never a list of your own
const title = Object.entries(header.componentProperties)
  .find(([k]) => k.split("#")[0] === "Title")?.[1].value;
frame.name = (title && String(title).trim())
  || pattern.name.replace(/^ds-doc\//, "");                    // fallback: the pattern name

// clear Content of demo blocks
const content = frame.children.find(c => c.name === "Content");
for (const c of [...content.children]) c.remove();
```

`detachInstance()` preserves variable bindings and spacing. Only the page wrapper detaches; atoms stay instances.

---

## 4. A «heading + content» block for Specification

```js
const pSet = await figma.getNodeByIdAsync("3:1246");           // ds-paragraph
const dcSet = await figma.getNodeByIdAsync("3:1240");          // ds-doc-component

function variantOf(set, props) {
  return set.children.find(c =>
    Object.entries(props).every(([k, v]) => c.variantProperties[k] === v));
}

// the page lead: description only
const lead = variantOf(pSet, { Type: "H1" }).createInstance();
content.appendChild(lead);
setProps(lead, { "Show Title": false, "Description": "<lead: from the component description or the locale template>" });

// a block
const group = figma.createFrame();
group.layoutMode = "VERTICAL";
group.itemSpacing = refGroup.itemSpacing;      // copy spacing from a pattern group, never a number
group.fills = [];
content.appendChild(group);                                    // into the auto-layout first…
group.layoutSizingHorizontal = "FILL";                         // …FILL only after
group.layoutSizingVertical = "HUG";
group.name = "Group";

const h = variantOf(pSet, { Type: "H1" }).createInstance();
group.appendChild(h);
setProps(h, { "Title": "<glossary heading>", "Description": "<locale template>" });

const illo = variantOf(dcSet, { Type: "Structure" }).createInstance();
group.appendChild(illo);
setProps(illo, { "Title": "<configuration name>", "Show Desciption": false });
```

`variantOf(...).createInstance()` — instancing the needed variant directly matters: `setProperties` with a variant swap recreates the instance subtree and turns slot children into phantoms (see Traps).

---

## 5. Slots — `appendChild` only

`instance.setProperties({ [slotKey]: … })` **throws**. Slot content is set through children.

```js
const slot = illo.findAllWithCriteria({ types: ["SLOT"] })
  .find(s => s.name === "Slot Structure");

const example = srcSet.defaultVariant.createInstance();
slot.appendChild(example);

// If an edit AFTER append throws "Internal Figma Error: Parent not found" —
// re-read the node via slot.children and work with the fresh reference:
// const fresh = slot.children[slot.children.length - 1];
```

Slot limits: `layoutMode = "GRID"` is forbidden; a `ComponentNode` cannot go in directly (instances only); a frame nested in a slot cannot be bound to another slot.

**`slot.resetSlot()` does not empty a slot — it restores the engine demo content.** Emptying a slot inside a **live instance** requires the marker recipe:

```js
// 1. append a plain marker frame — demo children become mortal
const marker = figma.createFrame(); marker.name = "__MARKER__"; marker.resize(1, 1);
slot.appendChild(marker);
// 2. remove the demo children with a fresh lookup each iteration
while (true) {
  const demo = slot.children.find(c => c.name !== "__MARKER__");
  if (!demo) break;
  demo.remove();
}
// 3. remove the marker — an empty slot does not resurrect the demo
slot.children.find(c => c.name === "__MARKER__").remove();
// 4. only now append your own instances
```

Why not simpler: after the first `remove()` the remaining demo children turn into phantoms — their ids read but the nodes reject mutation, and a fresh `findOne` does not help. Appending an instance of the **same component as the demo children** re-keys them the same way; a plain frame does not. In a subtree **detached** from a pattern none of this applies — everything is real nodes, clear them with a plain loop.

An instance dropped into a slot gets `layoutSizingHorizontal = "FIXED"` at its natural width and overflows the container. Set `FILL` explicitly after `appendChild`.

---

## 6. States

```js
const stateHost = variantOf(dcSet, { Type: "State" }).createInstance();
group.appendChild(stateHost);

// slot surgery FIRST, properties AFTER — leaf to root (see Traps)
const stateSlot = stateHost.findAllWithCriteria({ types: ["SLOT"] })
  .find(s => s.name === "Slot State");
const stSet = await figma.getNodeByIdAsync("3:1259");          // ds-doc-component-state

for (const st of [{ name: "Default", desc: "" }, { name: "Disabled", desc: "Not pressable" }]) {
  const row = variantOf(stSet, { Position: "Horizontal" }).createInstance();
  stateSlot.appendChild(row);

  const preview = row.findAllWithCriteria({ types: ["SLOT"] }).find(s => s.name === "Slot");
  const inst = srcSet.children.find(c => c.variantProperties.State === st.name)?.createInstance();
  if (inst) preview.appendChild(inst);

  setProps(row, { "Type": st.name, "Show Description": Boolean(st.desc), ...(st.desc ? { "Description": st.desc } : {}) });
}

setProps(stateHost, { "Show Title": false, "Show Desciption": false });   // host props last
```

`Show Desciption` on `ds-doc-component` carries the typo. `ds-doc-component-state` has the correct `Show Description`. The prefix resolver handles both, but pass the names verbatim.

---

## 6a. A complete changelog entry

The version is never asked — it is computed from the change type.

```js
function bumpVersion(prev, type) {
  if (!prev) return { major: 1, minor: 0, patch: 0 };            // the component's first entry
  if (type === "New")     return { major: prev.major + 1, minor: 0, patch: 0 };
  if (type === "Changed") return { major: prev.major, minor: prev.minor + 1, patch: 0 };
  return { major: prev.major, minor: prev.minor, patch: prev.patch + 1 };   // Fixed
}

// the base is the version of the page's top (newest) entry
function readTopVersion(content) {
  const top = content.children[0];
  if (!top) return null;
  const v = top.findAllWithCriteria({ types: ["INSTANCE"] })
    .find(n => n.mainComponent?.name === "ds-log-changelog-version");
  if (!v) return null;
  const num = name => Number(Object.entries(v.componentProperties)
    .find(([k]) => k.split("#")[0] === name)[1].value);
  return { major: num("Major"), minor: num("Minor"), patch: num("Patch") };
}
```

Assembling one entry. The newest version goes **first** — `insertChild(0, …)`, not `appendChild`.

```js
const entry = { type: "Changed", desc: "<what changed>", date: new Date() };

const version = bumpVersion(readTopVersion(content), entry.type);

const log = (await figma.getNodeByIdAsync("3:1197")).createInstance();
content.insertChild(0, log);
const fresh = content.children[0];

setProps(fresh, { "Description": entry.desc, "Show Description": true, "Show File": false });

const v = fresh.findAllWithCriteria({ types: ["INSTANCE"] })
  .find(n => n.mainComponent?.name === "ds-log-changelog-version");
setProps(v, { "Major": String(version.major), "Minor": String(version.minor), "Patch": String(version.patch) });

const pad = n => String(n).padStart(2, "0");                     // leading zeros are mandatory
const d = fresh.findAllWithCriteria({ types: ["INSTANCE"] })
  .find(n => n.mainComponent?.name === "ds-log-changelog-date");
setProps(d, { "Day": pad(entry.date.getDate()), "Month": pad(entry.date.getMonth() + 1),
              "Year": pad(entry.date.getFullYear() % 100) });

const label = fresh.findAllWithCriteria({ types: ["INSTANCE"] })
  .find(n => n.mainComponent?.parent?.name === "ds-log-label");
setProps(label, { "Type": entry.type });
```

The `Designers` slot in autonomous mode is **not touched** — the component default stays. The `File` slot and the `✱ Image` layer inside `ds-log-designers` are never touched — `Show File` stays `false`.

---

## 6b. Annotations and measurements

Categories and the «layer → properties» table — in `annotations.md`.

```js
const cats = await figma.annotations.getAnnotationCategoriesAsync();
const dev = cats.find(c => c.label === "Development").id;

// a layer inside the instance sitting in Slot Structure
const layer = instanceInSlot.findOne(n => n.name === "<layer name from the inventory>");

layer.annotations = [{
  labelMarkdown: "**<Layer name>** — what this layer does in the component.",
  categoryId: dev,
  properties: [{ type: "minWidth" }, { type: "itemSpacing" }, { type: "padding" }]
}];
```

`annotations` is a read-only array: assign it whole. Never duplicate numbers in `labelMarkdown`. `properties` accept only what is actually set on the node — `width`/`height` are the safe fallback; `BOOLEAN_OPERATION` nodes take no annotations.

A measurement instead of size text:

```js
if (figma.editorType === "dev") {
  figma.currentPage.addMeasurement(
    { node: textContainer, side: "TOP" },
    { node: textContainer, side: "BOTTOM" }
  );
}
```

Never mix axes. Outside Dev Mode the call is unavailable — put the measurement in the report as a manual step.

---

## 6c. Specification blocks from component properties

Block order = the order of `componentPropertyDefinitions` keys, unsorted.

```js
const defs = srcSet.componentPropertyDefinitions;
const blocks = Object.entries(defs)
  .filter(([, d]) => d.type === "VARIANT")
  .map(([k, d]) => ({ prop: k.split("#")[0], values: d.variantOptions }));
// → Configuration, Style, Size, State, Selected
```

Only VARIANT axes become blocks. TEXT and INSTANCE_SWAP properties have no enumerable values — list them in the report as properties without a block. `Selected` is shown as a row inside the States block, never as its own block. A boolean property becomes a block only with display logic of its own; its description then states at which values of other axes it is available.

---

## 7. Axes on the component page

**Never build the grid**: `Slot Component` holds one node — the component itself. The skill labels the axes around it.

```js
const labelSet = await figma.getNodeByIdAsync("3:1318");       // ds-doc-component-label

function label(text, { large = false, vertical = false } = {}) {
  const i = variantOf(labelSet, { Large: String(large), Vertical: String(vertical) }).createInstance();
  setProps(i, { "Label": text });
  return i;
}
```

The horizontal axis — two `Line`s inside `Horizontal Props`:

```js
hp.children[0].appendChild(label(axisX.name, { large: true }));   // the axis name
for (const v of axisX.values) hp.children[1].appendChild(label(v));
```

The vertical axis — **one `Line` per nesting level** inside `Vertical Props` (the container is horizontal):

```js
// levels — top-down by nesting; each next level subdivides the previous
const levels = [
  { values: ["Light"],          large: true  },   // an optional outer level: theme
  { values: axisA.values,       large: true  },   // axis A
  { values: repeat(axisB.values, axisA.values.length), large: false },  // axis B, repeated per value of A
];
for (const lvl of levels) {
  const line = figma.createAutoLayout("VERTICAL", { name: "Line", itemSpacing: refLine.itemSpacing });
  line.fills = [];
  vp.appendChild(line);
  for (const v of lvl.values) line.appendChild(label(v, { large: lvl.large, vertical: true }));
}
```

The number of labels per level = the number of groups it spans. Bracket height defines the hierarchy, not column order. The innermost level is a frame with one `Line` per row block.

Derive bracket heights and gaps from the source set's variant geometry (`x`/`y` of the variants) so the labels match what the reader actually sees. Give labels enough width for their text — a narrow instance wraps the caption mid-word.

Verify label-to-variant correspondence via `variantProperties` (`{ Axis: value }`).

Geometry: an empty auto-layout with `HUG` remembers a stale width and collapses the moment children arrive. Cure: `resize(w, h)` with the width captured **before** filling, plus paddings **copied from a neighbouring engine node**, never numbers:

```js
const w = Math.round(slot.width);                  // capture BEFORE filling
slot.paddingLeft = hp.paddingLeft;                 // hp = Horizontal Props
slot.paddingRight = hp.paddingRight;
slot.paddingTop = slot.paddingBottom = hp.paddingLeft;
slot.resize(w, slot.height);
```

A number here breaks the theme: a copy's engine paddings are different.

---

## 8. Traps

| Symptom | Cause | What to do |
|---|---|---|
| `Cannot write to node with unloaded font` | font not loaded | harvest the actual fonts from engine nodes via `getStyledTextSegments(["fontName"])` and load them before edits |
| `setProperties` on a slot throws | slots are not set through properties | `appendChild` into the SLOT node |
| `FILL can only be set on children of auto-layout frames` | `layoutSizing*` set before `appendChild` | parent first, sizing after |
| `Internal Figma Error: Parent not found` | node reference went stale after append | re-read via `parent.children` |
| property not found | resolved by full name with suffix | resolve by the prefix before `#` |
| a page refuses new blocks | it is an instance, not a frame | `detachInstance()` the page wrapper |
| Content empty after detach | demo blocks removed, nothing added | fill in the same call |
| page context reset | `figma.currentPage` resets between calls | `setCurrentPageAsync` at the start of every call, exactly once |
| `in remove: Node not found` on a slot's second child | after the first `remove()` in a SLOT inside an instance the remaining demo children become phantoms: ids read, nodes reject mutation. A fresh `findOne` does not help | the marker recipe: `appendChild` an empty marker frame → demo children become mortal, remove them with fresh lookups → remove the marker → append your own nodes. An empty slot does not resurrect the demo |
| same, but after `setProperties` | **any** `setProperties` on an instance (BOOLEAN and layout properties included) re-keys its subtree ids | all slot surgery before any `setProperties`; set properties leaf to root: chip → row → host |
| same when appending instances into a slot | appending an instance of the **same component as the demo children** also re-keys them; a plain frame does not | the same marker recipe: clear the demo before appending your instances |
| many edits needed inside a slot | a slot in a live instance is fragile throughout | after a page `detachInstance()` the whole subtree is real nodes, no phantoms; reuse the detached demo block instead of building inside a live instance |
| `setProperties` variant swap + inner mutations | the swap recreates the instance subtree | instance the needed variant directly: `set.children.find(v => v.name.includes('Type=State')).createInstance()` — no swap happens |
| `Invalid property "minWidth" for a FRAME node` on an annotation | annotation `properties` accept only properties actually set on the node; `BOOLEAN_OPERATION` takes no annotations at all | pick `properties` per node (`width`/`height` are almost always valid), skip boolean operations |
| an imported component vanished between calls | the id of a key-imported component is not permanent | re-import with `importComponent[Set]ByKeyAsync` at the start of the call — it is cheap |
| font not found on instance `appendChild` | font loads live within one call | load the engine font list at the start of **every** writing call |
