# Рецепты Plugin API

Чистый Figma Plugin API. Чем выполнять — в `SKILL.md`, раздел «Чем работать».

---

## 1. Найти коллекцию и снять карту

```js
const col = (await figma.variables.getLocalVariableCollectionsAsync())
  .find(c => c.name === "theme");
if (!col) return { stop: true, reason: "коллекция theme не найдена" };

const byName = {}, byId = {};
for (const id of col.variableIds) {
  const v = await figma.variables.getVariableByIdAsync(id);
  if (v) { byName[v.name] = v; byId[v.id] = v.name; }
}
const base = col.modes.find(m => m.name === "lite") || col.modes[0];
return { modes: col.modes.map(m => m.name), count: col.variableIds.length, baseMode: base.name };
```

Мод-образец — `lite`: из него берутся алиасы и всё, что не тема. Нет `lite` — первый мод.

## 2. Добавить мод

```js
const modeId = col.addMode("<имя темы>");   // бросит, если имя занято или мод один на плане
```

Лимит модов зависит от плана Figma. Ошибка — остановиться и сказать: из кода это не чинится.

**Значения нового мода не наследуются предсказуемо** — скилл задаёт все 164 явно.
Это заодно снимает зависимость от поведения `addMode`.

## 3. Записать значение

```js
// число
byName["layers/global/space/ds-doc-global-space-01"]
  .setValueForMode(modeId, 64);

// строка
byName["typography/font-family/font-body"].setValueForMode(modeId, "Geist");

// булево
byName["shape/ds-shape"].setValueForMode(modeId, true);

// цвет: 0–1, альфа отдельным полем
byName["colors/base/ds-base-primary"]
  .setValueForMode(modeId, { r: 0.012, g: 0.027, b: 0.071, a: 1 });

// алиас
byName["colors/accent/ds-accent-primary"].setValueForMode(modeId, {
  type: "VARIABLE_ALIAS",
  id: byName["colors/base/ds-base-primary"].id
});
```

Hex → RGB: делить на 255, альфу тоже. `#03071299` = `{ r:3/255, g:7/255, b:18/255, a:153/255 }`.

## 4. Перенести алиасы и «не тему» из образца

```js
const CARRY_OVER = [/^text\/docs-header\//, /ds-doc-min-width$/, /ds-doc-max-width$/,
                    /^space \| radius \| gap \| border\/layer-03\//];

for (const [name, v] of Object.entries(byName)) {
  const src = v.valuesByMode[base.modeId];
  const isAlias = src && typeof src === "object" && src.type === "VARIABLE_ALIAS";
  if (isAlias || CARRY_OVER.some(re => re.test(name))) {
    v.setValueForMode(modeId, src);          // алиас или значение — как есть
  }
}
```

Сначала переносится всё это, затем поверх записываются примитивы темы. Порядок важен:
иначе перенос затрёт вычисленные значения.

Исключение: `layer-03/layer/border` и `layer-03/radius/*` — алиасы, они попадут первой веткой.

## 5. Проверить гарнитуру

```js
const fonts = await figma.listAvailableFontsAsync();
const has = (family, style) => fonts.some(f => f.fontName.family === family && f.fontName.style === style);
if (!has("Geist", "Regular")) return { stop: true, missingFont: "Geist" };
```

Вес в переменной — число (400, 500, 600), в Figma — имя начертания. Соответствие:
400 → `Regular`, 500 → `Medium`, 550 → `Semi Bold`, 600 → `Semi Bold`, 700 → `Bold`.
Точного начертания нет — брать ближайшее и называть замену в отчёте.

## 6. Проверить результат

```js
const missing = [];
for (const [name, v] of Object.entries(byName))
  if (v.valuesByMode[modeId] === undefined) missing.push(name);
return { modeId, total: Object.keys(byName).length, missing };
```

`missing` не пуст — тема неполна, и это ошибка, а не мелочь: незаданная переменная в новом
моде рендерится значением первого мода и выглядит как случайная.

---

## 7. Ловушки

| Симптом | Причина | Что делать |
|---|---|---|
| `addMode` бросает | лимит модов на плане Figma | стоп, попросить человека — из кода не чинится |
| цвет вышел в 255 раз ярче | Plugin API принимает 0–1 | делить на 255 |
| альфа не применилась | `a` внутри `color` вместо поля объекта | `{ r, g, b, a }` целиком в `setValueForMode` |
| переменная не найдена по имени | в имени пробелы и вертикальные черты | группа называется `space \| radius \| gap \| border` — копировать дословно |
| `size-mono-02` не найдена | в исходнике опечатка | искать `size-mono-02 2`, с пробелом и двойкой |
| тема «поехала» на одной странице | не задана часть переменных | проверка полноты из рецепта 6 |
