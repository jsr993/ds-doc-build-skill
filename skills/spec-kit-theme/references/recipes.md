# Plugin API recipes

Pure Figma Plugin API. What to execute it with — `SKILL.md`, section «What to work with».

---

## 1. Find the collection and take the map

```js
const col = (await figma.variables.getLocalVariableCollectionsAsync())
  .find(c => c.name === "theme");
if (!col) return { stop: true, reason: "theme collection not found" };

const byName = {}, byId = {};
for (const id of col.variableIds) {
  const v = await figma.variables.getVariableByIdAsync(id);
  if (v) { byName[v.name] = v; byId[v.id] = v.name; }
}
const base = col.modes.find(m => m.name === "lite") || col.modes[0];
return { modes: col.modes.map(m => m.name), count: col.variableIds.length, baseMode: base.name };
```

The sample mode is `lite`: the aliases and everything that is not a theme are taken from it.
No `lite` — the first mode.

## 2. Add the mode

```js
const modeId = col.addMode("<theme name>");   // throws if the name is taken or the plan allows one mode
```

The mode limit depends on the Figma plan. On that error — stop and say so: it cannot be fixed
from code.

**Values of a new mode are not inherited predictably** — the skill sets all 164 explicitly.
That also removes any dependence on `addMode` behaviour.

## 3. Write a value

```js
// a number
byName["layers/global/space/ds-doc-global-space-01"]
  .setValueForMode(modeId, 64);

// a string
byName["typography/font-family/font-body"].setValueForMode(modeId, "Geist");

// a boolean
byName["shape/ds-shape"].setValueForMode(modeId, true);

// a colour: 0–1 range, alpha as its own field
byName["colors/base/ds-base-primary"]
  .setValueForMode(modeId, { r: 0.012, g: 0.027, b: 0.071, a: 1 });

// an alias
byName["colors/accent/ds-accent-primary"].setValueForMode(modeId, {
  type: "VARIABLE_ALIAS",
  id: byName["colors/base/ds-base-primary"].id
});
```

Hex → RGB: divide by 255, the alpha too. `#03071299` = `{ r:3/255, g:7/255, b:18/255, a:153/255 }`.

## 4. Carry the aliases and the «not a theme» values over from the sample

```js
const CARRY_OVER = [/^text\/docs-header\//, /ds-doc-min-width$/, /ds-doc-max-width$/,
                    /^layers\/layer-03\//];

for (const [name, v] of Object.entries(byName)) {
  const src = v.valuesByMode[base.modeId];
  const isAlias = src && typeof src === "object" && src.type === "VARIABLE_ALIAS";
  if (isAlias || CARRY_OVER.some(re => re.test(name))) {
    v.setValueForMode(modeId, src);          // alias or value — as is
  }
}
```

All of this is carried over first; the theme's primitives are then written on top. The order
matters: otherwise the carry-over would clobber the computed values.

An aside: `layer-03/layer/border` and `layer-03/radius/*` are aliases and land in the first
branch anyway.

## 5. Verify a font family

```js
const fonts = await figma.listAvailableFontsAsync();
const has = (family, style) => fonts.some(f => f.fontName.family === family && f.fontName.style === style);
if (!has("Geist", "Regular")) return { stop: true, missingFont: "Geist" };
```

The weight in the variable is a number (400, 500, 600); in Figma it is a style name. Mapping:
400 → `Regular`, 500 → `Medium`, 550 → `Semi Bold`, 600 → `Semi Bold`, 700 → `Bold`.
The exact style missing — take the nearest and name the substitution in the report.

## 6. Verify the result

```js
const missing = [];
for (const [name, v] of Object.entries(byName))
  if (v.valuesByMode[modeId] === undefined) missing.push(name);
return { modeId, total: Object.keys(byName).length, missing };
```

`missing` not empty — the theme is incomplete, and that is an error, not a detail: an unset
variable renders in the new mode with the first mode's value and looks random.

---

## 7. Traps

| Symptom | Cause | What to do |
|---|---|---|
| `addMode` throws | the mode limit of the Figma plan | stop and ask the human — it cannot be fixed from code |
| a colour came out 255 times brighter | the Plugin API takes 0–1 | divide by 255 |
| the alpha did not apply | `a` nested inside `color` instead of a field of the object | `{ r, g, b, a }` whole into `setValueForMode` |
| a variable is not found by name | the path predates engine 3.0: geometry lives under `layers/`, not `space \| radius \| gap \| border` | use `layers/...`; in a copy of the file saved before 28.08.2026 the old group name still applies — copy it verbatim, spaces and vertical bars included |
| `size-mono-02` not found | a typo in the source | search for `size-mono-02 2`, with the space and the two |
| the theme «slid» on one page | part of the variables not set | the completeness check of recipe 6 |
