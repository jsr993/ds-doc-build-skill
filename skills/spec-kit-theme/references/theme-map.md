# Карта коллекции `theme`

Снято с основного файла `KNEAKDWElVE0JkNi9j0x8S` («Component Spec Kit», тот, что идёт в Community) 28.08.2026.
Коллекция `theme`, **164 переменных**, моды: `lite`, `enterprise`, `engineering`.

Имена — контракт. Переносить дословно, включая опечатки: `size-mono-02 2`,
`letter-spacing-mono-01 2`, `paragraphy-spacing` (не paragraph), `interation` (не interaction),
Группа геометрии теперь называется `layers` — прежде она называлась `space | radius | gap | border`.

---

## Два яруса

Коллекция делится на два яруса, и скилл обращается с ними по-разному.

**Примитивы** — задаются значением в каждом моде. Их и генерирует скилл.
**Семантика** — задаётся алиасом на примитив. Скилл проставляет те же алиасы, что в `lite`,
и не изобретает новых связей.

Соотношение: 124 примитива и 41 семантический алиас.

---

## 1. Примитивы

### 1.1 Цвет — 24

| Переменная | `lite` | `enterprise` |
|---|---|---|
| `colors/base/ds-base-primary` | `#030712` | `#f8f8fc` |
| `colors/base/ds-base-secondary` | `#03071299` | `#f8f8fca3` |
| `colors/base/ds-base-tertiary` | `#03071266` | `#f8f8fc52` |
| `colors/base/ds-layer-inverse` | `#d1d5db` | `#1e1b3a` |
| `colors/accent/ds-accent-primary` | → `ds-base-primary` | `#8c71ff` |
| `colors/accent/ds-accent-secondary` | → `ds-base-secondary` | `#8c71ff99` |
| `colors/accent/ds-accent-tertiary` | `#0307121a` | `#8c71ff1a` |
| `colors/layer/ds-layer-01` | `#ffffff` | `#121216` |
| `colors/layer/ds-layer-02` | `#f3f4f6` | `#1a1a1f` |
| `colors/layer/ds-layer-03` | `#e5e7eb` | `#23232b` |
| `colors/border/ds-border-01` | `#ffffff00` | `#2a2a35` |
| `colors/border/ds-border-02` | `#ffffff00` | `#2a2a35` |
| `colors/border/ds-border-03` | `#ffffff00` | `#2a2a35` |
| `colors/section/ds-section-accent` | `#03071203` | `#8c71ff03` |
| `colors/section/ds-section-01` | `#eff1f3` | `#050506` |
| `colors/section/ds-section-02` | `#e7e9eb` | `#0a0a0c` |
| `colors/section/ds-section-03` | `#e1e3e5` | `#252533` |
| `colors/section/ds-section-border-01…03` | `#ffffff00` — прозрачные | `#252533` |
| `colors/cover/ds-gradient-01` | `#ffffff` | `#8c71ff` |
| `colors/cover/ds-gradient-02` | → `ds-base-primary` | `#ffffff` |

**Что читается из этой пары.** `base` — цвет текста и иконок, три ступени прозрачности одного
тона (100 / 60 / 40 %). `layer` — три подложки от светлой к тёмной. `section` — фон секции
документации, отдельная от `layer` шкала. `border` — в светлой теме прозрачные (`#ffffff00`),
в тёмной видимые: **граница появляется там, где перестают работать тени и разделение по светлоте.**
`accent` в `lite` алиасится на `base` — то есть акцента как отдельного цвета нет; в `enterprise`
это фиолетовый `#8c71ff`.

### 1.2 Типографика — 52

| Группа | Переменные | Тип |
|---|---|---|
| `typography/font-family` | `global-font`, `font-title`, `font-subtitle`, `font-body`, `font-mono` | STRING |
| `typography/weight` | `weight-title`, `-subtitle`, `-body`, `-mono` | FLOAT |
| `typography/size` | `size-title`, `size-subtitle-01…04`, `size-body-01…04`, `size-mono-01`, `size-mono-02 2`, `size-mono-03` | FLOAT |
| `typography/line-height` | те же 12 ступеней | FLOAT |
| `typography/letter-spacing` | те же 12 ступеней, включая `letter-spacing-mono-01 2` | FLOAT |
| `typography/paragraphy-spacing` | `body-01…04`, `mono-01…03` — 7 | FLOAT |

`lite`: `Inter` во всём (`font-title/subtitle/body` → алиас на `global-font`), моно — `IBM Plex Mono`,
веса 600 / 550 / 500 / 500, `size-title` 48.
`enterprise`: `global-font` пустой, семейства заданы поимённо — `Merriweather` для заголовков,
`Geist` для текста, `Geist Mono`; все веса 400, `size-title` 40.

**Вывод для скилла:** обе схемы легальны. Одна гарнитура на всё — алиасить на `global-font`;
разные — задавать поимённо, тогда `global-font` не используется.

### 1.3 Форма — 5

| Переменная | Тип | Оба мода |
|---|---|---|
| `shape/ds-shape` | BOOLEAN | `true` |
| `shape/ds-shape-color` | COLOR | → `colors/accent/ds-accent-tertiary` |
| `shape/ds-shape-bg-color` | COLOR | → `colors/layer/ds-layer-02` |
| `shape/ds-shape-size` | FLOAT | `20` |
| `shape/ds-shape-scale` | FLOAT | `0.2` |

Декоративный паттерн внутри карточек. Цвета — всегда алиасы, поэтому форма следует за темой
автоматически. Скилл трогает только `ds-shape`, `-size`, `-scale`.

### 1.4 Геометрия — 24 примитива

| Группа | Переменные | `lite` | `enterprise` |
|---|---|---|---|
| `layers/global/space` | `ds-doc-global-space-01…07` | 64 48 32 24 16 8 4 | 40 40 32 24 16 8 4 |
| `layers/global/radius` | `ds-doc-global-radius-01…03` | 48 24 8 | 32 16 8 |
| `layers/section/radius` | `ds-radius-section-01…03` | 48 48 48 | 24 24 24 |
| `layers/section/border` | `ds-section-border-01…03` | 0 0 0 | 2 1 0.5 |
| `layers/global/gap` | `ds-doc-global-gap-01…07` | 64 32 24 16 12 8 4 | 40 32 24 16 8 4 2 |
| `layers/global/border` | `ds-border-01…03` | 0 0 0 | 2 1 0.5 |
| `paragraph` | `ds-paragraph-gap-h1…h4` | 12 8 4 2 | 8 6 2 0 |
| `layer-03/layer` | `top/left/right/bottom/gap` | 2 4 4 2 4 | то же |
| `layer-03/avatar` | `ds-layer-avatar-size`, `-radius` | 24 / 4 | то же |
| `doc` | `ds-doc-min-width`, `ds-doc-max-width` | 640 / 1024 | то же |
| `doc/header` | `ds-doc-header-min-height` | 248 | 200 |

**Что читается.** `lite` — просторная и круглая: шаг 64, радиус секции 64, границ нет.
`enterprise` — плотная и строгая: шаг 40, радиус 24, границы от 0.5 до 2.
Ширина документа и мелочь `layer-03` одинаковы — это структурные константы, не тема.

### 1.5 Тексты — 13 STRING

`text/ds-name` — имя дизайн-системы, **единственная строка, которая меняется между модами**
(`Lite Design System` / `Enterprise Design System`).

`text/docs-header/<паттерн>/title` и `/description` для `changelog`, `specification`, `interation`,
`tips-practices`, `microcopy`, `components` — **одинаковы в обоих модах**. Это названия разделов
документации, а не тема. Скилл копирует их в новый мод дословно и не переводит.

---

## 2. Семантика — 67 алиасов

Скилл проставляет их точно так же, как в `lite`.

| Группа | На что алиасится |
|---|---|
| `doc/radius/ds-doc-radius-*` (4 угла) | `global/radius/ds-doc-global-radius-01` |
| `doc/ds-doc-border` | `global/border/ds-border-01` |
| `doc/header/top`, `left`, `right` | `global/space/ds-doc-global-space-01` |
| `doc/header/bottom` | `global/space/ds-doc-global-space-03` |
| `doc/header/gap` | `global/gap/ds-doc-global-gap-01` |
| `doc/header/text-gap` | `global/gap/ds-doc-global-gap-04` |
| `doc/content/top` | `global/space/ds-doc-global-space-03` |
| `doc/content/left`, `right`, `bottom` | `global/space/ds-doc-global-space-01` |
| `doc/content/gap` | `global/gap/ds-doc-global-gap-01` |
| `doc/content/logs-gap` | `global/gap/ds-doc-global-gap-04` |
| `layer-02/layer/top…bottom` | `global/space/ds-doc-global-space-04` |
| `layer-02/layer/gap` | `global/gap/ds-doc-global-gap-02` |
| `layer-02/layer/border` | `global/border/ds-border-02` |
| `layer-02/layer/logs-gap` | `global/gap/ds-doc-global-gap-04` |
| `layer-02/radius/*` (4 угла) | `global/radius/ds-doc-global-radius-02` |
| `layer-03/layer/border` | `global/border/ds-border-03` |
| `layer-03/radius/*` (4 угла) | `global/radius/ds-doc-global-radius-03` |

### Расхождение, которое нужно знать

В `enterprise` четыре семантические переменные **разорваны в значения**:
`doc/header/bottom` = 16, `doc/header/gap` = 32, `doc/header/text-gap` = 8,
против алиасов в `lite`. Скорее всего ручная подгонка шапки.

Скилл повторяет схему **`lite`** — она полная и последовательная. Разрыв алиаса делает тему
невосприимчивой к правке примитива, и повторять это не нужно.

---

## 3. Что из этого — тема, а что нет

| Не тема, копируется дословно | Почему |
|---|---|
| `text/docs-header/*` (12 строк) | названия разделов документации |
| `ds-doc-min-width`, `ds-doc-max-width` | формат страницы |
| `layer-03/layer/*`, `layer-03/avatar/*` | мелкая механика вложенного слоя |
| алиасы `shape/ds-shape-color`, `-bg-color` | форма следует за темой сама |

Всё остальное — тема, и его скилл выводит из референса.

---

## 4. Что изменилось 28.08.2026

Владелец перестроил коллекцию и разобрал кит. Записано по факту, а не по памяти.

**Группа геометрии переименована:** `space | radius | gap | border` → `layers`. Старый путь
не резолвится ни в одном рецепте.

**Появилась секционная ветка** — секция документации получила собственные токены вместо
одного общего радиуса:

| Было | Стало |
|---|---|
| `global/radius/ds-radius-section` — один | `layers/section/radius/ds-radius-section-01…03` — три |
| — | `layers/section/border/ds-section-border-01…03` — три толщины |
| — | `colors/section/ds-section-border-01…03` — три цвета |

Итого 165 переменных против 157.

**Два паттерна удалены из кита:** `tips-practices` и `microcopy`. Осталось четыре — `changelog`,
`specification`, `interation`, `components`. Их переменные `text/docs-header/tips-practices/*`
и `.../microcopy/*` **в коллекции остались** — четыре осиротевшие строки, на холст не смотрят.

**Компоненты переименованы под путевую схему.** Старые имена не резолвятся:

| Было | Стало |
|---|---|
| `ds-paragraph` | `ds-doc/specification/paragraph` |
| `ds-doc-component` | `ds-doc/specification/component` |
| `ds-doc-component-state` | `ds-doc/specification/component/state` |
| `ds-log` | `ds-doc/changelog/log` |
| `ds-log-label` | `ds-doc/changelog/log/type` |
| `ds-log-changelog-version` | `ds-doc/changelog/log/version` |
| `ds-log-changelog-date` | `ds-doc/changelog/log/date` |
| `ds-log-designers` | `ds-doc/changelog/log/designers` |
| `ds-doc-interaction` | `ds-doc/interaction/device` и `.../container` — разделён надвое |
| `ds-row` | удалён |

Без изменений: `ds-doc-header`, `ds-doc-header-cover`, `ds-doc-component-label`, `Name`,
`ds-icon-components` и сами паттерны `ds-doc/*`.

---

## 5. Сверка с основным файлом, 28.08.2026

Разделы выше сняты с основного файла — того, что публикуется в Community. Отличия от копии,
по которой карта писалась изначально:

**164 переменных, не 165.** `layers/layer-03/avatar` вырос с двух переменных до пяти:
добавились `ds-layer-avatar-content-top-bottom`, `-content-right`, `-content-left`.

**Две поломки в `text/docs-header/`, обе починены 29.08.2026.** Записаны здесь потому,
что обе невидимы на холсте и обе воспроизводятся в любой копии файла, снятой раньше этой даты:

- Заголовок паттерна `ds-doc/components` — инстанс шапки, node-id `3:1639` — был привязан
  к `VariableID:10038:5180` и `10038:5181`. По имени они резолвились
  (`text/docs-header/components/title` и `/description`), но в `variableIds` коллекции их
  не было: переменные удалили, а привязка осталась жить ссылкой. Симптом отсутствует —
  узел рисует последнее известное значение, и при переключении мода оно не меняется.
  Починено: пары пересозданы STRING-переменными со значениями `Components` / `Source component`
  во всех трёх модах, скоупы скопированы с `text/docs-header/specification/title`,
  привязка переставлена через `createVariableAlias`.
- Строки `text/docs-header/tips-practices/*` осиротели вместе с удалённым паттерном —
  удалены владельцем.

Итог: четыре группы `text/docs-header/` ровно под четыре паттерна — `changelog`,
`specification`, `interation`, `components`. Число переменных не изменилось: минус две
осиротевшие, плюс две восстановленные.

**Компоненты переименованы под путевую схему целиком** — все двадцать живут под `ds-doc/`.
Для скилла темы это не важно (он пишет в переменные, а не в компоненты), но карта применения
`token-usage.md` называет их старыми именами. Роли токенов при этом не изменились: страница
по-прежнему `layer-01`, карточка `layer-02`, чип `layer-03`.

**Паттернов четыре:** `changelog`, `specification`, `interation`, `components`.
