#!/usr/bin/env bash
# Пересобирает dist/ds-doc-build.skill из SKILL.md и references/.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
out="$root/dist/ds-doc-build.skill"

cd "$root"
[ -f SKILL.md ] || { echo "SKILL.md не найден"; exit 1; }
[ -d references ] || { echo "папка references не найдена"; exit 1; }

mkdir -p dist
rm -f "$out"
zip -r -q "$out" SKILL.md references -x '*.DS_Store'

echo "готово: $out"
unzip -l "$out"
