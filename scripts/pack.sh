#!/usr/bin/env bash
# Пересобирает dist/ из SKILL.md и references/.
# Кладёт четыре файла — два формата × два имени:
#   ds-doc-build.skill / ds-doc-build-<версия>.skill
#       плоский архив: SKILL.md и references/ в корне.
#       Для ручной установки — распаковывается ВНУТРЬ папки ~/.claude/skills/ds-doc-build/
#   ds-doc-build.zip / ds-doc-build-<версия>.zip
#       то же содержимое, обёрнутое в папку ds-doc-build/.
#       Для загрузчиков и распаковки «куда попало»: папка приезжает вместе с архивом
# Имя без версии — постоянный адрес для README, с версией — чтобы сборку было видно на глаз.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

[ -f SKILL.md ] || { echo "SKILL.md не найден"; exit 1; }
[ -d references ] || { echo "папка references не найдена"; exit 1; }
[ -f CHANGELOG.md ] || { echo "CHANGELOG.md не найден"; exit 1; }

# версия — первый заголовок вида «### 4.0.0» в CHANGELOG
version="$(grep -m1 -oE '^### [0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
[ -n "$version" ] || { echo "не удалось прочитать версию из CHANGELOG.md"; exit 1; }

mkdir -p dist
# в dist живёт только текущая версия: сборки прошлых версий удаляются
for f in dist/ds-doc-build-*.skill dist/ds-doc-build-*.zip; do
  [ -e "$f" ] || continue
  case "$f" in
    "dist/ds-doc-build-$version.skill"|"dist/ds-doc-build-$version.zip") ;;
    *) echo "  удаляю прошлую версию: $(basename "$f")"; rm -f "$f" ;;
  esac
done
rm -f "dist/ds-doc-build.skill" "dist/ds-doc-build-$version.skill" \
      "dist/ds-doc-build.zip"   "dist/ds-doc-build-$version.zip"

# плоский: SKILL.md и references в корне архива
zip -r -q "dist/ds-doc-build.skill" SKILL.md references -x '*.DS_Store'
cp "dist/ds-doc-build.skill" "dist/ds-doc-build-$version.skill"

# обёрнутый: всё внутри папки ds-doc-build/
stage="$(mktemp -d)"
mkdir -p "$stage/ds-doc-build"
cp SKILL.md "$stage/ds-doc-build/"
cp -r references "$stage/ds-doc-build/"
( cd "$stage" && zip -r -q "$root/dist/ds-doc-build.zip" ds-doc-build -x '*.DS_Store' )
cp "dist/ds-doc-build.zip" "dist/ds-doc-build-$version.zip"
rm -rf "$stage"

echo "версия $version"
ls -1 dist/
