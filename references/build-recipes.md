# Рецепты Plugin API

Вызовы через `use_figma`, `skillNames` содержит `figma-use`. Оттуда: `return` вместо `console.log`, один `setCurrentPageAsync` на вызов, возвращать ID созданных узлов, при ошибке не повторять вслепую.

---

## 0. Разрешение ключей property

Суффикс (`#814:6`) стабилен внутри файла, но меняется при переиздании библиотеки. Хардкодить нельзя — резолвить по префиксу.

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

VARIANT-property (`Type`, `Large`, `Vertical`, `Position`) идут без суффикса — тот же резолвер их поймает.

---

## 1. Инвентарь исходного компонента (read-only)

Проверка входа — здесь, до любой записи.

```js
const node = await figma.getNodeByIdAsync("SRC_ID");

if (node.type !== "COMPONENT_SET" && node.type !== "COMPONENT") {
  return { stop: true, got: { type: node.type, name: node.name },
           reason: "нужна ссылка на сам компонент — COMPONENT_SET или COMPONENT" };
}
// вариант внутри набора — поднимаемся к набору, это тот же компонент
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

Токены — отдельным вызовом `get_variable_defs` на `defaultVariant`.

---

## 2. Разрешение движка

Скилл переносимый: движок ищется по имени, а не по id. Node-id и keys из `ds-engine-map.md` — только быстрый путь в файле-первоисточнике.

```js
// один read-only вызов: собрать ds-* по всем страницам файла
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

Совпадение по имени точное: `wanted.includes(n.name)`, без `startsWith`, `toLowerCase` и `trim`. Поиск по префиксу `ds-` зацепил бы компоненты пользователя.

Пусто → пробовать `importComponentByKeyAsync` по ключам из карты (движок подключён библиотекой). Всё ещё пусто → вернуть `{ stop: true, expected, found, missing }` и остановиться. Похожие имена не подбирать, самодельными фреймами не подменять: почти всегда причина в том, что компоненты движка переименовали.

Собранную карту `имя → id` держать в памяти сборки и передавать в следующие вызовы строками.

Шрифты — снимать с узлов движка, а не хардкодить:

```js
const fonts = new Map();
for (const t of headerInstance.findAllWithCriteria({ types: ["TEXT"] }))
  for (const seg of t.getStyledTextSegments(["fontName"]))
    fonts.set(seg.fontName.family + "|" + seg.fontName.style, seg.fontName);
await Promise.all([...fonts.values()].map(f => figma.loadFontAsync(f)));
```

---

## 2а. Площадка: секция и её оформление

Визуал секции — на переменных `decoration`. Цвета и радиус ставить **только привязкой**, не значениями. `setBoundVariableForPaint` возвращает **новый** paint — результат обязательно перехватывать.

```js
const col = (await figma.variables.getLocalVariableCollectionsAsync())
  .find(c => c.name === "decoration");
const vars = {};
for (const id of col.variableIds) {
  const v = await figma.variables.getVariableByIdAsync(id);
  if (v) vars[v.name] = v;
}
const need = ["radius/ds-radius-section", "color/section/ds-section-01",
              "color/section/ds-section-02", "color/ds-tertiary"];
const missing = need.filter(n => !vars[n]);
if (missing.length) return { stop: true, missing };   // не подставлять цвета руками

const solid = (opacity) => ({ type: "SOLID", color: { r: 0, g: 0, b: 0 }, opacity });

// две заливки: базовая и почти прозрачная поверх
const f2 = figma.variables.setBoundVariableForPaint(solid(1),    "color", vars["color/section/ds-section-02"]);
const f1 = figma.variables.setBoundVariableForPaint(solid(0.01), "color", vars["color/section/ds-section-01"]);
section.fills = [f2, f1];

const st = figma.variables.setBoundVariableForPaint(solid(0.4), "color", vars["color/ds-tertiary"]);
section.strokes = [st];
section.strokeWeight = 1;
section.strokeAlign = "INSIDE";

for (const corner of ["topLeftRadius", "topRightRadius", "bottomLeftRadius", "bottomRightRadius"])
  section.setBoundVariable(corner, vars["radius/ds-radius-section"]);
```

Если в файле уже есть готовая секция документации — снять настройки с неё (`fills`, `strokes`, `strokeWeight`, `strokeAlign`, `boundVariables`) и присвоить своей: правки владельца подхватятся сами.

Раскладка страниц: отступ от края секции `PAD = 100`, шаг между страницами `GAP = 200`, порядок — слева направо по мере сборки.

```js
const PAD = 100, GAP = 200;
const right = section.children.reduce((m, c) => Math.max(m, c.x + c.width), PAD - GAP);
frame.x = right + GAP;      // первая страница встанет в PAD
frame.y = PAD;
```

Обтяжка — **последним шагом**, когда все страницы собраны и высоты окончательные:

```js
let maxR = 0, maxB = 0;
for (const c of section.children) { maxR = Math.max(maxR, c.x + c.width); maxB = Math.max(maxB, c.y + c.height); }
section.resizeWithoutConstraints(Math.ceil(maxR + PAD), Math.ceil(maxB + PAD));
```

`SECTION` не умеет auto-layout и сам не хугает — только явный `resizeWithoutConstraints`.

---

## 2б. Создание секции

```js
const page = await figma.getNodeByIdAsync("TARGET_PAGE_ID");
await figma.setCurrentPageAsync(page);           // ровно один раз за вызов

// шрифты уже загружены на шаге разрешения движка

const right = page.children.reduce((m, n) => Math.max(m, n.x + n.width), 0);

const section = figma.createSection();
section.name = "COMPONENT_NAME";
section.x = right + 400;
section.y = 0;
section.resizeWithoutConstraints(8000, 8000);   // временный размер, обтянем в конце

return { sectionId: section.id };
```

Узлы движка брать из карты, собранной в рецепте 2: `await figma.getNodeByIdAsync(found["ds-doc/changelog"])`.

---

## 3. Страница: инстанс → детач → наполнение

```js
const pattern = await figma.getNodeByIdAsync(found["ds-doc/specification"]);
const page = pattern.createInstance();
const frame = page.detachInstance();                          // → FrameNode

const section = await figma.getNodeByIdAsync("SECTION_ID");
section.appendChild(frame);
frame.x = 0; frame.y = 0;

// шапка осталась инстансом ds-doc-header — значения НЕ ТРОГАТЬ.
// Title/Description приходят из паттерна и привязаны к переменным decoration.
// Любой setProps по ним рвёт связь с переменной и подменяет название раздела.
const header = frame.findAllWithCriteria({ types: ["INSTANCE"] })
  .find(n => n.mainComponent?.name === "ds-doc-header");

// имя frame = Title шапки, а не свой список названий
const title = Object.entries(header.componentProperties)
  .find(([k]) => k.split("#")[0] === "Title")?.[1].value;
frame.name = (title && String(title).trim())
  || pattern.name.replace(/^ds-doc\//, "");                    // фолбэк: имя паттерна

// Content очищаем от демо-блоков
const content = frame.children.find(c => c.name === "Content");
for (const c of [...content.children]) c.remove();

return { frameId: frame.id, contentId: content.id };
```

`detachInstance()` сохраняет привязки к переменным и отступы. Детачится только страничная обёртка; атомы остаются инстансами.

---

## 4. Блок «заголовок + контент» для Спецификации

```js
const pSet = await figma.getNodeByIdAsync("3:1246");           // ds-paragraph
const dcSet = await figma.getNodeByIdAsync("3:1240");          // ds-doc-component

function variantOf(set, props) {
  return set.children.find(c =>
    Object.entries(props).every(([k, v]) => c.variantProperties[k] === v));
}

// лид страницы: только описание
const lead = variantOf(pSet, { Type: "H1" }).createInstance();
content.appendChild(lead);
setProps(lead, { "Show Title": false, "Description": "<лид: имя компонента жирным, что это и когда брать>" });

// блок
const group = figma.createFrame();
group.layoutMode = "VERTICAL";
group.itemSpacing = refGroup.itemSpacing;      // шаг копируем с группы паттерна, не числом
group.fills = [];
content.appendChild(group);                                    // сначала в auto-layout…
group.layoutSizingHorizontal = "FILL";                         // …только потом FILL
group.layoutSizingVertical = "HUG";
group.name = "Group";

const h = variantOf(pSet, { Type: "H1" }).createInstance();
group.appendChild(h);
setProps(h, { "Title": "Анатомия", "Description": "У компонента следующая структура…" });

const illo = variantOf(dcSet, { Type: "Structure" }).createInstance();
group.appendChild(illo);
setProps(illo, { "Title": "Состав", "Description": "Контейнер, текст, иконка" });
```

---

## 5. Слоты — только через `appendChild`

`instance.setProperties({ [slotKey]: … })` **бросает исключение**. Содержимое слота задаётся детьми.

```js
const slot = illo.findAllWithCriteria({ types: ["SLOT"] })
  .find(s => s.name === "Slot Structure");

const example = srcSet.defaultVariant.createInstance();
slot.appendChild(example);

// Если правка ПОСЛЕ append бросает "Internal Figma Error: Parent not found" —
// перечитать узел через slot.children и работать со свежей ссылкой:
// const fresh = slot.children[slot.children.length - 1];
```

Ограничения слотов: `layoutMode = "GRID"` запрещён; `ComponentNode` напрямую класть нельзя (только инстанс); вложенный в слот фрейм нельзя привязать к другому слоту.

**`slot.resetSlot()` не очищает слот, а возвращает демо-содержимое движка.** Чтобы слот стал пустым:

```js
while (slot.children.length > 0) slot.children[0].remove();
```

Снимок `[...slot.children]` использовать нельзя — id детей смещаются после первого `remove()`, и второй бросит «Node with id … not found».

Инстанс, положенный в слот, получает `layoutSizingHorizontal = "FIXED"` со своей натуральной шириной и вылезает за контейнер. После `appendChild` ставить `FILL` явно.

---

## 6. Состояния

```js
const stateHost = variantOf(dcSet, { Type: "State" }).createInstance();
group.appendChild(stateHost);
setProps(stateHost, { "Show Title": false, "Show Desciption": false });

const stateSlot = stateHost.findAllWithCriteria({ types: ["SLOT"] })
  .find(s => s.name === "Slot State");
const stSet = await figma.getNodeByIdAsync("3:1259");          // ds-doc-component-state

for (const st of [{ name: "Default", desc: "" }, { name: "Disabled", desc: "Недоступно для нажатия" }]) {
  const row = variantOf(stSet, { Position: "Horizontal" }).createInstance();
  stateSlot.appendChild(row);
  setProps(row, { "Type": st.name, "Show Description": Boolean(st.desc), ...(st.desc ? { "Description": st.desc } : {}) });

  const preview = row.findAllWithCriteria({ types: ["SLOT"] }).find(s => s.name === "Slot");
  const inst = srcSet.children.find(c => c.variantProperties.State === st.name)?.createInstance();
  if (inst) preview.appendChild(inst);
}
```

`Show Desciption` у `ds-doc-component` — с опечаткой. У `ds-doc-component-state` — правильное `Show Description`. Резолвер по префиксу это учитывает, но имена надо передавать дословно.

---

## 6а. Запись changelog целиком

Версия не спрашивается — считается из типа изменения.

```js
function bumpVersion(prev, type) {
  if (!prev) return { major: 1, minor: 0, patch: 0 };            // первая запись компонента
  if (type === "New")     return { major: prev.major + 1, minor: 0, patch: 0 };
  if (type === "Changed") return { major: prev.major, minor: prev.minor + 1, patch: 0 };
  return { major: prev.major, minor: prev.minor, patch: prev.patch + 1 };   // Fixed
}

// база — версия верхней (самой свежей) записи страницы
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

Сборка одной записи. Свежая версия кладётся **первой** — `insertChild(0, …)`, не `appendChild`.

```js
const entry = { type: "Changed", desc: "<что изменилось>", designers: ["<Имя>", "<Имя>"], date: new Date() };

const version = bumpVersion(readTopVersion(content), entry.type);

const log = (await figma.getNodeByIdAsync("3:1197")).createInstance();
content.insertChild(0, log);
const fresh = content.children[0];

setProps(fresh, { "Description": entry.desc, "Show Description": true, "Show File": false });

const v = fresh.findAllWithCriteria({ types: ["INSTANCE"] })
  .find(n => n.mainComponent?.name === "ds-log-changelog-version");
setProps(v, { "Major": String(version.major), "Minor": String(version.minor), "Patch": String(version.patch) });

const pad = n => String(n).padStart(2, "0");                     // ведущие нули обязательны
const d = fresh.findAllWithCriteria({ types: ["INSTANCE"] })
  .find(n => n.mainComponent?.name === "ds-log-changelog-date");
setProps(d, { "Day": pad(entry.date.getDate()), "Month": pad(entry.date.getMonth() + 1),
              "Year": pad(entry.date.getFullYear() % 100) });

const label = fresh.findAllWithCriteria({ types: ["INSTANCE"] })
  .find(n => n.mainComponent?.parent?.name === "ds-log-label");
setProps(label, { "Type": entry.type });
```

Участники — по инстансу на человека:

```js
const desSlot = fresh.findAllWithCriteria({ types: ["SLOT"] }).find(s => s.name === "Designers");
while (desSlot.children.length > 0) desSlot.children[0].remove();   // resetSlot() вернёт демо-инстанс, а не очистит
for (const name of entry.designers) {
  const inst = (await figma.getNodeByIdAsync("10010:9177")).createInstance();
  desSlot.appendChild(inst);
  setProps(desSlot.children[desSlot.children.length - 1], { "Designer": name });
}
```

Слот `File` и слой `✱ Image` внутри `ds-log-designers` не трогать — `Show File` остаётся `false`.

---

## 6б. Аннотации и линейки

Категории и таблица «слой → properties» — в `annotations.md`.

```js
const cats = await figma.annotations.getAnnotationCategoriesAsync();
const dev = cats.find(c => c.label === "Development").id;

// слой внутри инстанса, лежащего в Slot Structure
const layer = instanceInSlot.findOne(n => n.name === "<имя слоя из инвентаря>");

layer.annotations = [{
  labelMarkdown: "**<Имя слоя>** — что этот слой делает в компоненте.",
  categoryId: dev,
  properties: [{ type: "minWidth" }, { type: "itemSpacing" }, { type: "padding" }]
}];
```

`annotations` — read-only массив: присваивать целиком. Числа в `labelMarkdown` не дублировать.

Линейка вместо текста о размере:

```js
if (figma.editorType === "dev") {
  figma.currentPage.addMeasurement(
    { node: textContainer, side: "TOP" },
    { node: textContainer, side: "BOTTOM" }
  );
}
```

Оси не смешивать. Вне Dev Mode вызов недоступен — линейку вынести в отчёт как ручной шаг.

---

## 6в. Блоки спецификации по свойствам компонента

Порядок блоков = порядок ключей `componentPropertyDefinitions`, без сортировки.

```js
const defs = srcSet.componentPropertyDefinitions;
const blocks = Object.entries(defs)
  .filter(([, d]) => d.type === "VARIANT" || d.type === "BOOLEAN")
  .map(([k, d]) => ({ prop: k.split("#")[0], values: d.variantOptions || [String(d.defaultValue)] }));
// → Configuration, Style, Size, State, Selected, Show Indicator
```

`Selected` показывается строкой внутри блока «Состояния», отдельным блоком не выносится. Булево свойство становится блоком, только если у него своя логика показа; в описании тогда указывается, при каких значениях других осей оно доступно.

---

## 7. Оси на странице компонента

Сетку **не строить**: в `Slot Component` один узел — сам компонент. Скилл подписывает оси вокруг него.

```js
const labelSet = await figma.getNodeByIdAsync("3:1318");       // ds-doc-component-label

function label(text, { large = false, vertical = false } = {}) {
  const i = variantOf(labelSet, { Large: String(large), Vertical: String(vertical) }).createInstance();
  setProps(i, { "Label": text });
  return i;
}
```

Горизонтальная ось — два `Line` внутри `Horizontal Props`:

```js
hp.children[0].appendChild(label(axisX.name, { large: true }));   // имя оси
for (const v of axisX.values) hp.children[1].appendChild(label(v));
```

Вертикальная ось — **по `Line` на уровень вложенности** внутри `Vertical Props` (контейнер горизонтальный):

```js
// levels — сверху вниз по вложенности, каждый следующий дробит предыдущий
const levels = [
  { values: ["Light"],          large: true  },   // необязательный внешний уровень: тема
  { values: axisA.values,       large: true  },   // ось A
  { values: repeat(axisB.values, axisA.values.length), large: false },  // ось B, повторяется на каждое значение A
];
for (const lvl of levels) {
  const line = figma.createAutoLayout("VERTICAL", { name: "Line", itemSpacing: refLine.itemSpacing });
  line.fills = [];
  vp.appendChild(line);
  for (const v of lvl.values) line.appendChild(label(v, { large: lvl.large, vertical: true }));
}
```

Число подписей на уровне = число групп, которые он накрывает. Иерархию задаёт высота скобки, а не порядок колонок. Самый внутренний уровень — фрейм с `Line` на каждый блок строк.

Соответствие подписей вариантам сверять по `variantProperties` (`{ Ось: значение }`).

Геометрия: пустой auto-layout с `HUG` держит ширину «по памяти» и схлопывается, как только в него кладут детей. Лечится `resize(w, h)` до ширины, снятой **до** наполнения, плюс отступы, **скопированные с соседнего узла движка**, а не написанные числом:

```js
const w = Math.round(slot.width);                  // снять ДО наполнения
slot.paddingLeft = hp.paddingLeft;                 // hp = Horizontal Props
slot.paddingRight = hp.paddingRight;
slot.paddingTop = slot.paddingBottom = hp.paddingLeft;
slot.resize(w, slot.height);
```

Число здесь сломает тему: в чужой копии отступы движка другие.

---

## 8. Ловушки

| Симптом | Причина | Что делать |
|---|---|---|
| `Cannot write to node with unloaded font` | шрифт не загружен | снять фактические шрифты с узлов движка через `getStyledTextSegments(["fontName"])` и загрузить до правок |
| `setProperties` на слоте кидает | слоты не задаются через property | `appendChild` в узел SLOT |
| `FILL can only be set on children of auto-layout frames` | `layoutSizing*` выставлен до `appendChild` | сначала добавить в родителя, потом задавать sizing |
| `Internal Figma Error: Parent not found` | ссылка на узел устарела после append | перечитать через `parent.children` |
| property не найдено | резолвинг по полному имени с суффиксом | резолвить по префиксу до `#` |
| страница не даёт добавить блок | это инстанс, а не фрейм | `detachInstance()` страничной обёртки |
| Content пустой после детача | демо-блоки удалены, но новые не добавлены | наполнять сразу в том же вызове |
| контекст страницы сбросился | `figma.currentPage` сбрасывается между вызовами | `setCurrentPageAsync` в начале каждого вызова, ровно один раз |
