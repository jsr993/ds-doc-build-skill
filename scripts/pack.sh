#!/usr/bin/env bash
# Пересобирает dist/ из skills/<имя>/.
# На каждый скилл — четыре файла, два формата × два имени:
#   <имя>.skill / <имя>-<версия>.skill   плоский: SKILL.md и references/ в корне архива
#   <имя>.zip   / <имя>-<версия>.zip     обёрнутый: всё внутри папки <имя>/
# Имя без версии — постоянный адрес для README, с версией — чтобы сборку было видно на глаз.
# В dist живёт только текущая версия: сборки прошлых версий удаляются.
#
# Версия у каждого скилла своя и берётся из CHANGELOG.md — первый «### x.y.z» после
# заголовка «## <имя скилла>». Общей версии у репозитория нет: она врала бы про тот скилл,
# который в этот раз не менялся.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
[ -f CHANGELOG.md ] || { echo "CHANGELOG.md не найден"; exit 1; }
mkdir -p dist

for dir in skills/*/; do
  name="$(basename "$dir")"
  [ -f "$dir/SKILL.md" ] || { echo "$name: нет SKILL.md"; exit 1; }
  [ -d "$dir/references" ] || { echo "$name: нет папки references"; exit 1; }

  version="$(awk -v s="## $name" '
    $0 == s        { inside = 1; next }
    /^## /         { inside = 0 }
    inside && /^### [0-9]+\.[0-9]+\.[0-9]+/ { print $2; exit }
  ' CHANGELOG.md)"
  [ -n "$version" ] || { echo "$name: в CHANGELOG.md нет раздела «## $name» с версией"; exit 1; }

  for f in dist/$name-*.skill dist/$name-*.zip; do
    [ -e "$f" ] || continue
    case "$f" in
      "dist/$name-$version.skill"|"dist/$name-$version.zip") ;;
      *) echo "  удаляю прошлую версию: $(basename "$f")"; rm -f "$f" ;;
    esac
  done
  rm -f "dist/$name.skill" "dist/$name-$version.skill" "dist/$name.zip" "dist/$name-$version.zip"

  ( cd "$dir" && zip -r -q "$root/dist/$name.skill" SKILL.md references -x '*.DS_Store' )
  cp "dist/$name.skill" "dist/$name-$version.skill"

  stage="$(mktemp -d)"
  mkdir -p "$stage/$name"
  cp "$dir/SKILL.md" "$stage/$name/"
  cp -r "$dir/references" "$stage/$name/"
  ( cd "$stage" && zip -r -q "$root/dist/$name.zip" "$name" -x '*.DS_Store' )
  cp "dist/$name.zip" "dist/$name-$version.zip"
  rm -rf "$stage"
  echo "$name $version — готово"
done
ls -1 dist/
