# Пересобирает dist\ds-doc-build.skill из SKILL.md и references\.
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$out  = Join-Path $root "dist\ds-doc-build.skill"

if (-not (Test-Path (Join-Path $root "SKILL.md")))    { throw "SKILL.md не найден" }
if (-not (Test-Path (Join-Path $root "references")))  { throw "папка references не найдена" }

New-Item -ItemType Directory -Force -Path (Join-Path $root "dist") | Out-Null
if (Test-Path $out) { Remove-Item $out }

$tmp = Join-Path $env:TEMP ("ds-doc-build-" + [guid]::NewGuid().ToString("N") + ".zip")
Compress-Archive -Path (Join-Path $root "SKILL.md"), (Join-Path $root "references") -DestinationPath $tmp
Move-Item $tmp $out

Write-Host "готово: $out"
