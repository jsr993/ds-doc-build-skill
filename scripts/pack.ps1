# Пересобирает dist\ из SKILL.md и references\.
# Кладёт четыре файла — два формата × два имени:
#   ds-doc-build.skill / ds-doc-build-<версия>.skill
#       плоский архив: SKILL.md и references/ в корне.
#       Для ручной установки внутрь ~/.claude/skills/ds-doc-build/ и для форм загрузки,
#       которым нужен SKILL.md в корне архива
#   ds-doc-build.zip / ds-doc-build-<версия>.zip
#       то же содержимое, обёрнутое в папку ds-doc-build/.
#       Для распаковки «куда попало»: папка приезжает вместе с архивом
# Имя без версии — постоянный адрес для README, с версией — чтобы сборку было видно на глаз.
#
# ВАЖНО: пути внутри архива пишутся через ПРЯМОЙ слэш. Compress-Archive в Windows
# PowerShell пишет обратный, и строгие читатели zip такой архив отвергают
# («Zip file contains path with invalid characters»). Поэтому архив собирается
# вручную через ZipArchive с явными именами записей.
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null

$root = Split-Path -Parent $PSScriptRoot

if (-not (Test-Path (Join-Path $root "SKILL.md")))     { throw "SKILL.md не найден" }
if (-not (Test-Path (Join-Path $root "references")))   { throw "папка references не найдена" }
if (-not (Test-Path (Join-Path $root "CHANGELOG.md"))) { throw "CHANGELOG.md не найден" }

# версия — первый заголовок вида «### 4.0.0» в CHANGELOG
$version = (Select-String -Path (Join-Path $root "CHANGELOG.md") -Pattern '^### (\d+\.\d+\.\d+)' |
            Select-Object -First 1).Matches[0].Groups[1].Value
if (-not $version) { throw "не удалось прочитать версию из CHANGELOG.md" }

# список файлов сборки: полный путь + имя записи относительно корня скилла
$items = @([pscustomobject]@{ path = (Join-Path $root "SKILL.md"); name = "SKILL.md" })
Get-ChildItem (Join-Path $root "references") -Recurse -File |
  Where-Object { $_.Name -ne '.DS_Store' } |
  ForEach-Object {
    $rel = $_.FullName.Substring($root.Length + 1) -replace '\\', '/'
    $items += [pscustomobject]@{ path = $_.FullName; name = $rel }
  }

function New-SkillArchive {
  param([string]$Destination, [string]$Prefix)
  if (Test-Path $Destination) { Remove-Item $Destination }
  $zip = [System.IO.Compression.ZipFile]::Open($Destination, 'Create')
  try {
    foreach ($i in $items) {
      [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $i.path, "$Prefix$($i.name)") | Out-Null
    }
  } finally { $zip.Dispose() }
}

$dist = Join-Path $root "dist"
New-Item -ItemType Directory -Force -Path $dist | Out-Null

New-SkillArchive (Join-Path $dist "ds-doc-build.skill") ""
Copy-Item (Join-Path $dist "ds-doc-build.skill") (Join-Path $dist "ds-doc-build-$version.skill") -Force

New-SkillArchive (Join-Path $dist "ds-doc-build.zip") "ds-doc-build/"
Copy-Item (Join-Path $dist "ds-doc-build.zip") (Join-Path $dist "ds-doc-build-$version.zip") -Force

Write-Host "версия $version"
Get-ChildItem $dist | ForEach-Object { Write-Host ("  " + $_.Name) }
