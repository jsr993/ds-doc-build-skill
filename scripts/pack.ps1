# Пересобирает dist\ из SKILL.md и references\.
# Кладёт два файла с одинаковым содержимым:
#   ds-doc-build.skill          — постоянное имя, всегда текущая версия (на него ссылается README)
#   ds-doc-build-<версия>.skill — версия в имени, чтобы новая и старая сборки различались на глаз
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot

if (-not (Test-Path (Join-Path $root "SKILL.md")))     { throw "SKILL.md не найден" }
if (-not (Test-Path (Join-Path $root "references")))   { throw "папка references не найдена" }
if (-not (Test-Path (Join-Path $root "CHANGELOG.md"))) { throw "CHANGELOG.md не найден" }

# версия — первый заголовок вида «### 4.0.0» в CHANGELOG
$version = (Select-String -Path (Join-Path $root "CHANGELOG.md") -Pattern '^### (\d+\.\d+\.\d+)' |
            Select-Object -First 1).Matches[0].Groups[1].Value
if (-not $version) { throw "не удалось прочитать версию из CHANGELOG.md" }

$latest = Join-Path $root "dist\ds-doc-build.skill"
$tagged = Join-Path $root "dist\ds-doc-build-$version.skill"

New-Item -ItemType Directory -Force -Path (Join-Path $root "dist") | Out-Null
foreach ($f in @($latest, $tagged)) { if (Test-Path $f) { Remove-Item $f } }

$tmp = Join-Path $env:TEMP ("ds-doc-build-" + [guid]::NewGuid().ToString("N") + ".zip")
Compress-Archive -Path (Join-Path $root "SKILL.md"), (Join-Path $root "references") -DestinationPath $tmp
Move-Item $tmp $latest
Copy-Item $latest $tagged

Write-Host "версия $version"
Write-Host "  $latest"
Write-Host "  $tagged"
