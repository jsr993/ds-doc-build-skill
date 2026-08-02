# Аннотации и линейки

Правило: **в тексте документации нет чисел.** Всё, что имеет числовое или токенное значение, показывается аннотацией Figma на конкретном слое. Значения обновляются вслед за компонентом — доку не переписывают, а только добавляют и убирают блоки.

## Категории

`figma.annotations.getAnnotationCategoriesAsync()`. В файле четыре пресета:

| Категория | Цвет | Чем помечать |
|---|---|---|
| `Development` | green | размеры, отступы, токены, стили текста, заливки |
| `Interaction` | blue | поведение и реакция на действие |
| `Accessibility` | pink | фокус, контраст, зона нажатия, скринридер |
| `Content` | orange | правила текста и содержимого |

Дефолт — `Development`. Новые категории не создавать (`addAnnotationCategoryAsync` не вызывать). Точное распределение уточняет владелец библиотеки.

## Формат

```js
node.annotations = [{
  labelMarkdown: "**<Имя слоя>** — что этот слой делает в компоненте.",
  categoryId: developmentCategoryId,
  properties: [{ type: "minWidth" }, { type: "itemSpacing" }, { type: "padding" }]
}];
```

- `labelMarkdown` — термин `**жирным**`, тире, назначение слоя. Назначение, не пересказ значения.
- `properties` — Figma сама подтягивает значение с узла и показывает токен, если свойство к нему привязано. В `labelMarkdown` числа не дублировать.
- `annotations` — read-only массив: присваивать целиком.

## `AnnotationPropertyType`

`width` · `height` · `maxWidth` · `minWidth` · `maxHeight` · `minHeight` · `fills` · `strokes` · `effects` · `strokeWeight` · `cornerRadius` · `textStyleId` · `textAlignHorizontal` · `fontFamily` · `fontStyle` · `fontSize` · `fontWeight` · `lineHeight` · `letterSpacing` · `itemSpacing` · `padding` · `layoutMode` · `alignItems` · `opacity` · `mainComponent` · `gridRowGap` · `gridColumnGap` · `gridRowCount` · `gridColumnCount` · `gridRowAnchorIndex` · `gridColumnAnchorIndex` · `gridRowSpan` · `gridColumnSpan`

Типовое соответствие:

| Слой | `properties` |
|---|---|
| корневой контейнер-подложка | `minWidth`, `itemSpacing`, `padding` |
| боковой слот под иконку | `minWidth`, `minHeight` |
| контейнер текста | `minHeight` |
| текстовый слой | `textStyleId`, `fills` |
| превью в блоке стилей | `fills` |

## Куда вешать

На слой внутри инстанса, лежащего в `Slot Structure`. Путь — `instance.findAll(...)` по имени слоя из инвентаря. Аннотация живёт на узле документации, а не на исходнике, поэтому переживает правку компонента.

**Не дублировать.** При нескольких конфигурациях первый блок несёт общую архитектуру, каждый следующий — только свои отличия. Одинаковая аннотация на каждом блоке — ошибка, а не полнота.

## Линейки

```js
if (figma.editorType === "dev") {
  figma.currentPage.addMeasurement(
    { node: textContainer, side: "TOP" },
    { node: textContainer, side: "BOTTOM" }
  );
}
```

- Оси не смешивать: `TOP → BOTTOM` или `LEFT → RIGHT`, не `LEFT → TOP`.
- Доступно **только в Dev Mode**. Вне его — вынести в отчёт как ручной шаг, не подменять числом в тексте.
- Линейка на самого себя (`TOP → BOTTOM`) даёт высоту слоя — так размечается блок размеров.

## Подсказка читателю

Описание заголовка «Анатомия» — приглашение открыть Dev Mode: «Для ознакомления структурой компонента используйте DevMode (Shift+D)». Без него читатель не увидит ни аннотаций, ни линеек.
