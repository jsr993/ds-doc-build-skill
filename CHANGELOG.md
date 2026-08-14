# История версий

Формат: [Keep a Changelog](https://keepachangelog.com/ru/1.1.0/), нумерация — [SemVer](https://semver.org/lang/ru/).

Здесь два независимых счётчика — скилла и движка. Третий, версия документируемого компонента, живёт в записи `ds-log` на странице `Changelog` и сюда не попадает. Правило совместимости: major-версия скилла заявляет, с какой major-версией движка он работает.

| Скилл | Движок |
|---|---|
| 3.x | 2.x — файл `Component Spec Kit` |
| 2.x | 2.x — файл `Component Spec Kit` |
| 1.x | 1.x — файл `JQ10AuRUEFp0KGoOyT3iHJ`, выведен из поддержки |

---

## Скилл

### 4.1.0 — 14.08.2026

No confirmations remain anywhere in the build. Link in, finished section out.

#### Changed

- **Moving the source set into `Slot Component` is unconditional.** It was the last question in the build; the owner's ruling is that it always happens and needs no asking. What the move changes is the set's parent and position on the canvas — properties and instances elsewhere are untouched — and it is named in the report. On a rebuild the set moves out of the previous section's slot into the new one; the old section keeps its pages with an empty slot, and the report offers to delete it.
- **Four stops instead of five,** each a dead end rather than a checkpoint: unreadable references, no library, input that is not a component, a missing `ds-*` or variable.
- **Axes on the `components` page are read from the set's geometry,** not from property declaration order — columns from the `x` clusters, vertical levels from the `y` clusters, outermost first, with bracket heights taken from the cluster heights. Declaration order still governs the specification blocks. Found in the field: `Chips Item` declares `Style` before `Size` but is laid out `Size → Style → State`, so declaration order would have mislabelled every bracket.

#### Fixed

- **Slot clearing had one recipe where two are needed,** and the wrong one breaks the build. A plain loop before appending anything is the default and works when the demo is an ordinary node — `Slot Structure`, whose demo is a frame named `Button`. The marker recipe is only for slots whose demo children are instances of the component being appended, like `Slot State`; on a plain-node demo the marker append is itself what re-keys the node. Both cases now stand in `build-recipes.md` with their symptoms.

### 4.0.0 — 12.08.2026

Major: the reference set changed. Gate ceremony cut, `execution.md` folded into `SKILL.md`.

#### Removed

- **`references/execution.md`** — its content lives in `SKILL.md` under «How to run it»: the capability requirements, the adapter table and the call contract, all intact. It was the smallest reference and the one most often missing from a partial install; twice in one week a run stopped because it alone had not arrived. Four references remain plus the locale.
- **The gate ceremony.** Five named gates with a closing protocol proved a heavier frame than the thing it framed. The steps stay numbered 0–4 as a pipeline.

#### Changed

- What the gates protected became plain rules: every step reports its facts before acting, nothing is written before step 2 closes, doubt is a stop.
- The install-diagnosis marker table updated for the new shape: `execution.md` **present** now means the folder predates 4.0; a missing `references/` altogether is called out explicitly.

#### Kept deliberately

- **The completeness check.** It is the only thing between a partial install and a build that invents engine keys and node-ids — a failure invisible in the finished Figma section. Cutting it along with the ceremony would have removed the protection while leaving the cause.

### 3.2.0 — 12.08.2026

G0 now diagnoses a version desync instead of merely reporting a missing file.

#### Added

- **A version marker** in `SKILL.md`: the pipeline and `references/` ship as one archive and are versioned together.
- **An install diagnosis table** at G0. A stale folder names its own generation: `interview.md` or `designers.md` present, or `execution.md` missing → the folder predates 3.0; no `locales/` → predates 3.1. The stop message now ends with a verdict — reinstall the whole folder, or add the one missing file — instead of leaving the user to guess.
- An explicit prohibition on editing the required-context table to fit a broken folder. Found in the field: an agent facing a missing `execution.md` proposed dropping it from the table and restoring `interview.md`/`designers.md` — a change that makes the error disappear and silently rolls the skill back a generation.

#### Why

A run in another environment hit a hybrid install: `SKILL.md` from 3.0, `references/` from the 2.0 rollback that preceded it. G0 stopped correctly, but the report could not tell an incomplete unpack from a version desync — and the two need opposite fixes.

### 3.1.0 — 12.08.2026

The skill now speaks English; generated documentation follows the language of the request. Entries from here on are written in English — the repository's public language.

#### Added

- **`references/locales/`**: `en.md` and `ru.md` — formats, the heading glossary, the write templates and the report labels. The skill reads exactly one locale per build. Adding a language = one new file in `locales/` plus a `description` line; not a line in the pipeline.
- **The language rule**: documentation language = the language of the user's request. Safeguard: after the engine resolves, the skill compares the header-variable language with the chosen one; a mismatch is named in the report, never a stop — a file may be intentionally mixed.
- The `en` date-format question is closed: numeric `dd.mm.yy` in every locale, because the format is dictated by the `ds-log-changelog-date` component (three text slots joined with dots), not by the locale.

#### Changed

- `SKILL.md` and every reference translated into English — the model reads them, and the repository is public in English. The pipeline itself is unchanged.
- README split: `README.md` (English) + `README.ru.md` (Russian).
- The detach-rule step «rename to the Russian page name» in the engine map corrected to the actual rule: the frame takes the header `Title` value.

#### Fixed

- Slot traps from the first full run on Chips Item recorded in `build-recipes.md`: phantom demo children after the first `remove()` in a live-instance slot (cured by the marker recipe), subtree re-keying from any `setProperties` and from appending same-component instances, annotation `properties` validity, non-permanent imported-component ids, per-call font loading.

### 3.0.0 — 05.08.2026

Major: сменился контракт со сборкой. Скилл 2.x собирал шесть страниц по ответам пользователя, 3.0 собирает три и почти ничего не спрашивает. Результат прежнего запуска не воспроизводится.

#### Добавлено

- **Раздел «Тексты»** в `SKILL.md`: глоссарий заголовков (`Configuration` → Конфигурации, `Style` → Стили, `Size` → Размеры, `State` → Состояния) и шаблоны формулировок для лида, описания блока свойства и записи changelog. Рядом — закрытый список того, что не генерируется никогда: когда применять конфигурацию, чем стили отличаются по смыслу, правила текста, рекомендации «делать / не делать», назначение слоя, не выводимое из его имени. Пустой блок лучше правдоподобной выдумки.
- Отчёт сдачи обязан перечислять **сгенерированные тексты** отдельным списком: читатель должен видеть, что написал скилл, а что взято из компонента.
- `references/execution.md` вернулся — контракт вызова, таблица адаптеров под разные обвязки и гейты. В 2.0.0 он был откатан.

#### Изменено

- **Всегда ровно три страницы:** `changelog`, `specification`, `components`. Без них документации не существует; `interation`, `tips-practices` и `microcopy` из сборки убраны — их содержимое нельзя вывести из компонента, только написать руками. Паттерны остались в движке и собираются вручную.
- **Гейтов пять вместо восьми:** G0 Готовность, G1 Вход и инвентарь, G2 Площадка, G3 Страница, G4 Сдача. Гейт перестал быть вопросом пользователю — это отчёт фактами перед действием. Остановка осталась только там, где написано «стоп»: не читаются референсы, нет библиотеки, на входе не компонент, не найден `ds-*` или переменная.
- **Шаг «Согласовать план» и шаг «Интервью» удалены целиком.** Вместе с ними — правило «без подтверждения плана не писать». Порог записи сместился с G3 на G2.
- **Changelog пишется сам:** первая сборка даёт `1.0.0` / `New` / сегодняшнюю дату и описание по шаблону. Слот `Designers` больше не заполняется — остаётся дефолт компонента. При пересборке тип берётся из сказанного пользователем, не сказал — `Changed`.
- **Ось в столбцы на странице компонента** — первая ось в порядке объявления свойств, остальные уходят в уровни `Vertical Props` в том же порядке. Раньше спрашивалось.
- **Описания строк в спецификации** заданы правилом, а не вопросом: включены для конфигураций, стилей и размеров, выключены для состояний.
- Лид спецификации: непустой `description` компонента берётся дословно, пустой — генерируется по шаблону. Показ черновика на подтверждение убран.
- Чек-лист сократился с 15 пунктов до 12.
- `SKILL.md` похудел примерно на четверть; `description` во фронтматтере переписан под поточную документацию многих компонентов подряд.

#### Удалено

- `references/interview.md` и `references/designers.md` — вопросов больше нет, ростер дизайнеров не нужен. Референсов осталось пять.

#### Исправлено

- В карте движка `ds-doc/*/title` заменено на `ds-title-description/*/title` — переменные шапок лежат в другой ветке коллекции, старый путь не резолвился.
- Три несобираемых паттерна помечены в карте движка сноской, чтобы их отсутствие в сборке не читалось как пропуск.
- **Перенос исходного set в `Slot Component` — только с разрешения.** Автономный прогон молча перемещал бы продуктовый компонент пользователя внутрь секции — у него меняется родитель и позиция. Теперь это единственный вопрос сборки: стоп перед страницей `components`, при отказе слот остаётся пустым, причина — в отчёте.
- **Пересборка определена.** Секция с именем компонента уже есть → база версии из её верхней записи `ds-log`, новая секция строится справа, старая не удаляется — предложение удалить уходит в отчёт. Раньше поведение при повторном прогоне не было задано.
- **Опознание библиотеки — по коллекции `decoration`, не по имени** «Component Spec Kit»: переименованный файл и опубликованная под своим названием копия работают наравне с оригиналом. Регрессия 3.0.0 относительно 2.0.0, возвращено.
- Слой анатомии с невыводимым назначением аннотируется именем слоя без расшифровки и уходит в отчёт пробелом — раньше требование «аннотация на каждом layout» сталкивалось с запретом генерации, исход был не определён.
- **Блоки спецификации — только для VARIANT-осей** (и BOOLEAN со своей логикой показа): у TEXT и INSTANCE_SWAP значений-строк нет, блок из них не собирается — такие свойства перечисляются в отчёте. Найдено сухим прогоном на Chips Item, у которого первые четыре свойства — INSTANCE_SWAP и TEXT.

### 2.0.0 — 03.08.2026

Major, потому что сменился контракт с движком: скилл 1.0.0 не работает с движком 2.x и наоборот. Все 38 ключей движка стали другими, три компонента из движка исчезли.

#### Добавлено

- **Раздел «Чем работать»** в `SKILL.md`: скилл рассчитан на Claude Code с Figma MCP и называет инструменты прямо — `use_figma`, `get_screenshot`, обязательный `figma-use` перед каждым вызовом. Там же контракт вызова: один вызов на логический шаг, `return` вместо `console.log`, `setCurrentPageAsync` ровно раз, не повторять упавший вызов вслепую.
- Правила «без подтверждения плана не писать» и «сомнение — стоп» подняты в незыблемые.
- **Шаг 0.2 — проверка библиотеки.** Движок опознаётся по коллекции переменных `decoration` среди подключённых библиотек, а не по имени библиотеки: владелец волен переименовать файл, а пользователь — опубликовать свою копию под своим названием. Имя «Component Spec Kit» осталось значением по умолчанию и подсказкой человеку. Если подходящих библиотек несколько, скилл спрашивает, какую брать; если нет ни одной, работает по локальной копии с предупреждением либо останавливается с просьбой подключить. Подключить библиотеку из кода нельзя.
- Правила оформления SECTION: радиус, две заливки и обводка — привязкой к переменным `decoration`. Заливок именно две, не одна.
- `OVERVIEW.md` — сквозной документ: две половины решения, как их спарить, правило совместимости.

#### Изменено

- **Разрешение движка зависит от того, где он лежит:** в локальной копии — по имени обходом страниц, в подключённой библиотеке — только по `key` через `importComponentByKeyAsync`. Компоненты библиотеки нельзя найти по имени: Plugin API их не перечисляет.
- Наполнение `ds-doc/tips-practices` и `ds-doc/microcopy` переписано по фактическому составу паттернов: `ds-paragraph H1` плюс `ds-doc-component` с `Type=Device` и `Type=Structure` соответственно.
- Состав референсов остался прежним — шесть файлов. Промежуточный `execution.md` с таблицей адаптеров и гейтами G0–G7 был добавлен и **откатан в этой же версии**, наружу не выходил: абстракция под вторую обвязку платила настоящую цену за гипотетическую выгоду, а гейты на сильной модели качества не добавляли. Существенное из неё переехало в `SKILL.md`.
- Правило «визуал не задавать» смягчено до «не задавать **значениями**»: SECTION скилл создаёт сам и обязан оформить, но только привязкой к переменным.

#### Исправлено

- **Переменная радиуса секции переехала** в `space/global/radius/ds-radius-section`. Скилл искал её по старому пути `radius/ds-radius-section` и остановился бы на оформлении секции, не найдя переменную. Заливки и обводка (`color/section/ds-section-01`, `ds-section-02`, `color/ds-tertiary`) остались на прежних именах.
- Карта движка описывала страницы файла по прошлому поколению (`documentation components`, `example`, `cover`). Актуально: `component kit` и `information`. Заодно записано, что имена страниц и секций справочные, а не контрактные: поиск идёт обходом всего документа, и перестановка страниц сборку не ломает.
- Из списка контрактных имён убран `ds-paragraph-ux-wtiting` — компонент удалён из движка.
- README: адрес репозитория вместо заглушки, актуальный Figma-файл вместо выведенного из поддержки, фактические имена страниц (`Changelog`, `Specification`, `Animated`, `Tips and practices`, `Microcopy`, `Components`) вместо русских подписей — скилл берёт их из `Title` шапки.

### 1.0.0 — 02.08.2026

#### Добавлено

- Скилл `ds-doc-build`: пайплайн из семи шагов, незыблемые правила, чек-лист из 15 пунктов.
- Референсы: карта движка `ds-*`, рецепты Figma Plugin API, вопросы интервью, правила аннотаций, справочник авторов, шаблон markdown-контракта.
- Сборка архива `dist/ds-doc-build.skill` скриптами `scripts/pack.sh` и `scripts/pack.ps1`.
- README с инструкцией по работе с документацией в Figma и по установке скилла в Claude Code.

---

## Движок

### 2.0.0 — 02.08.2026

Файл пересоздан под именем **Component Spec Kit** (`KNEAKDWElVE0JkNi9j0x8S`). Major: несовместим с движком 1.x.

#### Изменено

- **Все 38 ключей компонентов стали новыми** — Figma выдаёт новые ключи при пересоздании файла. Node-id уцелели. Скилл, собранный на старых ключах, не импортирует ни одного компонента.
- Title и Description шести шапок вынесены в STRING-переменные коллекции `decoration` (`ds-doc/<паттерн>/title|description`). Отсюда имена фреймов страниц идут за темой и языком файла.

#### Удалено

- `ds-doc` (мастер), `ds-paragraph-dev-mode`, `ds-paragraph-ux-wtiting`.

### 1.0.0

Файл `JQ10AuRUEFp0KGoOyT3iHJ`. Выведен из поддержки, используйте 2.x.

---

## Известные ограничения

Действуют на текущих версиях обоих счётчиков.

- Страницу `ds-doc/components` приходится детачить: сетка внутри — `layoutMode: "GRID"`, строить её в слоте инстанса нецелесообразно.
- Привязка STRING-переменной к component property не переживает `detachInstance()` — текст запекается статикой. Переживает только привязка на уровне `characters` текстового слоя.
- Ключи в карте движка — от библиотеки владельца. Пользователь, опубликовавший **свою** копию файла, получит другие ключи, и импорт по ключу не пройдёт. Обходной путь — вынести любой `ds-doc/*` на холст и снять `mainComponent.key` — покрывает один компонент из восемнадцати.
- Три паттерна движка — `interation`, `tips-practices`, `microcopy` — сборкой не создаются. Автор собирает их вручную из библиотеки.
- Строки, которые видит пользователь, пока лежат внутри пайплайна по-русски. До выноса в `references/locales/` английская сборка невозможна.
