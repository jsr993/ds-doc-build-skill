# Пересобирает dist\ из SKILL.md и references\.
# Кладёт четыре файла — два формата × два имени:
#   ds-doc-build.skill / ds-doc-build-<версия>.skill
#       плоский архив: SKILL.md и references\ в корне.
#       Для ручной установки — распаковывается ВНУТРЬ папки ~/.claude/skills/ds-doc-build/
#   ds-doc-build.zip / ds-doc-build-<версия>.zip
#       то же содержимое, обёрнутое в папку ds-doc-build\.
#       Для загрузчиков и распаковки «куда попало»: папка приезжает вместе с архивом
# Имя без версии — постоянный адрес для README, с версией — чтобы сборку было видно на глаз.
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot

if (-not (Test-Path (Join-Path $root "SKILL.md")))     { throw "SKILL.md не найден" }
if (-not (Test-Path (Join-Path $root "references")))   { throw "папка references не найдена" }
if (-not (Test-Path (Join-Path $root "CHANGELOG.md"))) { throw "CHANGELOG.md не найден" }

# версия — первый заголовок вида «### 4.0.0» в CHANGELOG
$version = (Select-String -Path (Join-Path $root "CHANGELOG.md") -Pattern '^### (\d+\.\d+\.\d+)' |
            Select-Object -First 1).Matches[0].Groups[1].Value
if (-not $version) { throw "не удалось прочитать версию из CHANGELOG.md" }

$dist = Join-Path $root "dist"
New-Item -ItemType Directory -Force -Path $dist | Out-Null

$out = @{
  flatLatest   = Join-Path $dist "ds-doc-build.skill"
  flatTagged   = Join-Path $dist "ds-doc-build-$version.skill"
  foldedLatest = Join-Path $dist "ds-doc-build.zip"
  foldedTagged = Join-Path $dist "ds-doc-build-$version.zip"
}
foreach ($f in $out.Values) { if (Test-Path $f) { Remove-Item $f } }

# плоский: SKILL.md и references в корне архива
$tmp = Join-Path $env:TEMP ("dsdb-flat-" + [guid]::NewGuid().ToString("N") + ".zip")
Compress-Archive -Path (Join-Path $root "SKILL.md"), (Join-Path $root "references") -DestinationPath $tmp
Move-Item $tmp $out.flatLatest
Copy-Item $out.flatLatest $out.flatTagged

# обёрнутый: всё внутри папки ds-doc-build\
$stageRoot = Join-Path $env:TEMP ("dsdb-stage-" + [guid]::NewGuid().ToString("N"))
$stage = Join-Path $stageRoot "ds-doc-build"
New-Item -ItemType Directory -Force -Path $stage | Out-Null
Copy-Item (Join-Path $root "SKILL.md") $stage
Copy-Item (Join-Path $root "references") $stage -Recurse
$tmp2 = Join-Path $env:TEMP ("dsdb-folded-" + [guid]::NewGuid().ToString("N") + ".zip")
Compress-Archive -Path $stage -DestinationPath $tmp2
Move-Item $tmp2 $out.foldedLatest
Copy-Item $out.foldedLatest $out.foldedTagged
Remove-Item $stageRoot -Recurse

Write-Host "версия $version"
foreach ($k in 'flatLatest','flatTagged','foldedLatest','foldedTagged') { Write-Host ("  " + $out[$k]) }
