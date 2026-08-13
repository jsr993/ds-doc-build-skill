#!/usr/bin/env bash
# Пересобирает dist/ из SKILL.md и references/.
# Кладёт два файла с одинаковым содержимым:
#   ds-doc-build.skill          — постоянное имя, всегда текущая версия (на него ссылается README)
#   ds-doc-build-<версия>.skill — версия в имени, чтобы новая и старая сборки различались на глаз
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

[ -f SKILL.md ] || { echo "SKILL.md не найден"; exit 1; }
[ -d references ] || { echo "папка references не найдена"; exit 1; }
[ -f CHANGELOG.md ] || { echo "CHANGELOG.md не найден"; exit 1; }

# версия — первый заголовок вида «### 4.0.0» в CHANGELOG
version="$(grep -m1 -oE '^### [0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
[ -n "$version" ] || { echo "не удалось прочитать версию из CHANGELOG.md"; exit 1; }

latest="$root/dist/ds-doc-build.skill"
tagged="$root/dist/ds-doc-build-$version.skill"

mkdir -p dist
rm -f "$latest" "$tagged"
zip -r -q "$latest" SKILL.md references -x '*.DS_Store'
cp "$latest" "$tagged"

echo "версия $version"
echo "  $latest"
echo "  $tagged"
unzip -l "$latest"
