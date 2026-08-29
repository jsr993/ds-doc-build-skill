# Annotations and measurements

The rule: **no numbers in documentation text.** Anything with a numeric or token value is shown as a Figma annotation on the specific layer. Values then update with the component — documentation is never rewritten, only blocks are added or removed.

## Categories

`figma.annotations.getAnnotationCategoriesAsync()`. The file ships four presets:

| Category | Colour | What to mark with it |
|---|---|---|
| `Development` | green | sizes, spacing, tokens, text styles, fills |
| `Interaction` | blue | behaviour and reaction to actions |
| `Accessibility` | pink | focus, contrast, hit area, screen reader |
| `Content` | orange | text and content rules |

Default — `Development`. Never create new categories (do not call `addAnnotationCategoryAsync`). The exact mapping is refined by the library owner.

## Format

```js
node.annotations = [{
  labelMarkdown: "**<Layer name>** — what this layer does in the component.",
  categoryId: developmentCategoryId,
  properties: [{ type: "minWidth" }, { type: "itemSpacing" }, { type: "padding" }]
}];
```

- `labelMarkdown` — the term in `**bold**`, a dash, the layer's purpose. Purpose, not a restatement of the value.
- `properties` — Figma pulls the value from the node itself and shows the token when the property is bound to one. Never duplicate numbers in `labelMarkdown`.
- `annotations` is a read-only array: assign it whole.

`properties` accept only properties actually set on that node — `minWidth` on a plain FRAME throws `Invalid property`. `width`/`height` are almost always valid. `BOOLEAN_OPERATION` nodes take no annotations at all — skip them.

## `AnnotationPropertyType`

`width` · `height` · `maxWidth` · `minWidth` · `maxHeight` · `minHeight` · `fills` · `strokes` · `effects` · `strokeWeight` · `cornerRadius` · `textStyleId` · `textAlignHorizontal` · `fontFamily` · `fontStyle` · `fontSize` · `fontWeight` · `lineHeight` · `letterSpacing` · `itemSpacing` · `padding` · `layoutMode` · `alignItems` · `opacity` · `mainComponent` · `gridRowGap` · `gridColumnGap` · `gridRowCount` · `gridColumnCount` · `gridRowAnchorIndex` · `gridColumnAnchorIndex` · `gridRowSpan` · `gridColumnSpan`

Typical mapping:

| Layer | `properties` |
|---|---|
| root backing container | `minWidth`, `itemSpacing`, `padding` |
| side icon slot | `minWidth`, `minHeight` |
| text container | `minHeight` |
| text layer | `textStyleId`, `fills` |
| preview in a styles block | `fills` |

## Where to attach

On a layer inside the instance sitting in `Slot Structure`. Path — `instance.findAll(...)` by the layer name from the inventory. The annotation lives on the documentation node, not on the source, so it survives component edits.

**Do not duplicate.** With several configurations the first block carries the shared architecture, each following one only its own differences. The same annotation on every block is an error, not thoroughness.

## Measurements

```js
if (figma.editorType === "dev") {
  figma.currentPage.addMeasurement(
    { node: textContainer, side: "TOP" },
    { node: textContainer, side: "BOTTOM" }
  );
}
```

- Never mix axes: `TOP → BOTTOM` or `LEFT → RIGHT`, not `LEFT → TOP`.
- Available **only in Dev Mode**. Outside it — put the measurement in the report as a manual step; never substitute a number in text.
- A self-measurement (`TOP → BOTTOM`) gives the layer height — that is how a sizes block is marked.

## Hint for the reader

The «Anatomy» heading description is an invitation to open Dev Mode (the `anatomy.description` locale string). Without it the reader sees neither annotations nor measurements.
