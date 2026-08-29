# Locale: ru

Strings the skill writes into the documentation and the report, Russian build. The skill reads **exactly one** locale file per build — the one matching the chosen documentation language.

## formats

| Key | Value |
|---|---|
| `date` | numeric `дд.мм.гг`, leading zeros required (`01`, not `1`), two-digit year. The format is dictated by the `ds-log-changelog-date` component (three text slots joined with dots), so it is identical in every locale |
| `quotes` | `«…»` |
| `dash` | `—` with spaces around it |

## glossary

Property name → block `Title`. Properties not listed here keep their name verbatim.

| Property | Title |
|---|---|
| `Configuration` | Конфигурации |
| `Style` | Стили |
| `Size` | Размеры |
| `State` | Состояния |

## write

The only strings the skill is allowed to write without them coming from the component. Placeholders in `<...>`.

| Key | Value |
|---|---|
| `anatomy.title` | Анатомия |
| `anatomy.description` | Структуру компонента смотрите в Dev Mode (Shift+D) |
| `lead` (when component `description` is empty) | `<Имя> — компонент с <N> вариантами по осям <оси через запятую>.` |
| `property-block.description` | `Свойство \`<Имя>\` задаёт <заголовок блока в родительном падеже>: <значения через запятую>.` |
| `changelog.first-entry` | `Первая версия компонента. Оси: <перечень осей>.` |
| `state-row` | value name verbatim; no explanation appended |

Genitive forms for `property-block.description`: Конфигурации → конфигурации, Стили → стили, Размеры → размеры, Состояния → состояния.

## report

Labels for gate reports and the final report.

| Key | Value |
|---|---|
| `component` | Компонент |
| `target` | Куда |
| `pages` | Страницы |
| `built` | Собрано |
| `generated` | Сгенерировано скиллом |
| `gaps` | Осталось незаполненным |
| `typos` | Опечатки исходника |
| `library` | Библиотека |
