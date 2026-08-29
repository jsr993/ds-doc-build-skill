# Пересобирает dist\ из skills\<имя>\.
# На каждый скилл — четыре файла, два формата × два имени:
#   <имя>.skill / <имя>-<версия>.skill   плоский: SKILL.md и references/ в корне архива
#   <имя>.zip   / <имя>-<версия>.zip     обёрнутый: всё внутри папки <имя>/
#
# Версия у каждого скилла своя и берётся из CHANGELOG.md — первый «### x.y.z» после
# заголовка «## <имя скилла>». Общей версии у репозитория нет.
#
# Пути внутри архива пишутся через ПРЯМОЙ слэш: Compress-Archive пишет обратный,
# и строгие валидаторы такой архив отвергают.
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null

$root = Split-Path -Parent $PSScriptRoot
$changelogPath = Join-Path $root "CHANGELOG.md"
if (-not (Test-Path $changelogPath)) { throw "CHANGELOG.md не найден" }
$changelog = Get-Content $changelogPath

function Get-SkillVersion {
  param([string]$Name)
  $inside = $false
  foreach ($line in $changelog) {
    if ($line -eq "## $Name") { $inside = $true; continue }
    if ($line -like '## *')   { $inside = $false }
    if ($inside -and $line -match '^### (\d+\.\d+\.\d+)') { return $Matches[1] }
  }
  return $null
}

function New-Archive {
  param([string]$Destination, [string]$Prefix, [array]$Items)
  if (Test-Path $Destination) { Remove-Item $Destination }
  $zip = [System.IO.Compression.ZipFile]::Open($Destination, 'Create')
  try {
    foreach ($i in $Items) {
      [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $i.path, "$Prefix$($i.name)") | Out-Null
    }
  } finally { $zip.Dispose() }
}

$dist = Join-Path $root "dist"
New-Item -ItemType Directory -Force -Path $dist | Out-Null

foreach ($dir in Get-ChildItem (Join-Path $root "skills") -Directory) {
  $name = $dir.Name
  if (-not (Test-Path (Join-Path $dir.FullName "SKILL.md")))   { throw "$name : нет SKILL.md" }
  if (-not (Test-Path (Join-Path $dir.FullName "references"))) { throw "$name : нет папки references" }

  $version = Get-SkillVersion $name
  if (-not $version) { throw "$name : в CHANGELOG.md нет раздела «## $name» с версией" }

  Get-ChildItem $dist -File | Where-Object {
    $_.Name -match "^$name-(\d+\.\d+\.\d+)\.(skill|zip)$" -and $Matches[1] -ne $version
  } | ForEach-Object { Write-Host ("  удаляю прошлую версию: " + $_.Name); Remove-Item $_.FullName }

  $items = @([pscustomobject]@{ path = (Join-Path $dir.FullName "SKILL.md"); name = "SKILL.md" })
  Get-ChildItem (Join-Path $dir.FullName "references") -Recurse -File |
    Where-Object { $_.Name -ne '.DS_Store' } |
    ForEach-Object {
      $rel = $_.FullName.Substring($dir.FullName.Length + 1).Replace('\', '/')
      $items += [pscustomobject]@{ path = $_.FullName; name = $rel }
    }

  New-Archive (Join-Path $dist "$name.skill") "" $items
  Copy-Item (Join-Path $dist "$name.skill") (Join-Path $dist "$name-$version.skill") -Force
  New-Archive (Join-Path $dist "$name.zip") "$name/" $items
  Copy-Item (Join-Path $dist "$name.zip") (Join-Path $dist "$name-$version.zip") -Force
  Write-Host "$name $version — готово"
}
Get-ChildItem $dist | ForEach-Object { Write-Host ("  " + $_.Name) }
