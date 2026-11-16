#Requires -Version 5.1
<#
.SYNOPSIS
  Run unit tests, then package Snippets with BigWigs release.sh (optional upload).

.PARAMETER DryRun
  Skip CurseForge/Wago/GitHub upload (passes -d to release.sh).

.PARAMETER SkipTests
  Skip lua tests/test_snippet_db.lua.

.PARAMETER ExtraArgs
  Extra arguments forwarded to release.sh.
#>
param(
  [switch]$DryRun,
  [switch]$SkipTests,
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$ExtraArgs
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $RepoRoot

function ConvertTo-GitBashPath([string]$WinPath) {
  $full = (Resolve-Path $WinPath).Path
  if ($full -match '^([A-Za-z]):\\(.*)$') {
    $drive = $Matches[1].ToLowerInvariant()
    $rest = ($Matches[2] -replace '\\', '/')
    return "/$drive/$rest"
  }
  return ($full -replace '\\', '/')
}

function Find-Bash {
  # Prefer Git Bash. Avoid Windows\system32\bash.exe (WSL launcher).
  $candidates = @(
    "C:\Program Files\Git\bin\bash.exe",
    "C:\Program Files\Git\usr\bin\bash.exe"
  )
  foreach ($c in $candidates) {
    if (Test-Path $c) { return $c }
  }
  $cmd = Get-Command bash -ErrorAction SilentlyContinue
  if ($cmd -and $cmd.Source -notmatch '(?i)\\Windows\\System32\\bash\.exe$') {
    return $cmd.Source
  }
  return $null
}

function Test-GitBashHasZip([string]$BashPath) {
  & $BashPath -lc "command -v zip >/dev/null 2>&1"
  return ($LASTEXITCODE -eq 0)
}

function New-ReleaseZip {
  param(
    [string]$PackageDir,
    [string]$ZipPath
  )
  if (-not (Test-Path $PackageDir)) {
    Write-Error "Package directory missing: $PackageDir"
  }
  if (Test-Path $ZipPath) { Remove-Item -Force $ZipPath }
  $parent = Split-Path -Parent $PackageDir
  $name = Split-Path -Leaf $PackageDir

  # Real ZIP only. Windows tar.exe -a often writes a tar stream named *.zip;
  # CurseForge then rejects uploads ("Failed to verify archive").
  $zipCmd = Get-Command zip -ErrorAction SilentlyContinue
  if ($zipCmd) {
    Push-Location $parent
    try {
      & zip -r $ZipPath $name
      if ($LASTEXITCODE -ne 0) {
        Write-Error "zip failed to create $ZipPath (exit $LASTEXITCODE)."
      }
    }
    finally {
      Pop-Location
    }
    return
  }

  $py = Get-Command python -ErrorAction SilentlyContinue
  if (-not $py) { $py = Get-Command python3 -ErrorAction SilentlyContinue }
  if ($py) {
    & $py.Source -c "import sys; from pathlib import Path; import shutil; parent, name, zip_path = sys.argv[1:4]; shutil.make_archive(str(Path(zip_path).with_suffix('')), 'zip', root_dir=parent, base_dir=name)" $parent $name $ZipPath
    if ($LASTEXITCODE -ne 0) {
      Write-Error "python failed to create $ZipPath (exit $LASTEXITCODE)."
    }
    return
  }

  Push-Location $parent
  try {
    Compress-Archive -Path $name -DestinationPath $ZipPath -Force
  }
  finally {
    Pop-Location
  }
}

function Import-DotEnv([string]$Path) {
  if (-not (Test-Path $Path)) { return $false }
  Get-Content $Path | ForEach-Object {
    $line = $_.Trim()
    if (-not $line -or $line.StartsWith("#")) { return }
    $eq = $line.IndexOf("=")
    if ($eq -lt 1) { return }
    $name = $line.Substring(0, $eq).Trim()
    $value = $line.Substring($eq + 1).Trim()
    if ($value.StartsWith('"') -and $value.EndsWith('"')) {
      $value = $value.Substring(1, $value.Length - 2)
    }
    # Do not overwrite tokens already set in the process environment.
    $existing = [Environment]::GetEnvironmentVariable($name, "Process")
    if ([string]::IsNullOrEmpty($existing)) {
      [Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
  }
  return $true
}

# release.sh only auto-loads $topdir/.env; also support .release/.env via this wrapper.
$loadedReleaseEnv = Import-DotEnv (Join-Path $RepoRoot ".release\.env")
$loadedRootEnv = Import-DotEnv (Join-Path $RepoRoot ".env")
if ($loadedReleaseEnv -or $loadedRootEnv) {
  Write-Host "==> Loaded local token env file(s)"
}

if (-not $SkipTests) {
  $lua = Get-Command lua -ErrorAction SilentlyContinue
  if (-not $lua) {
    Write-Error "lua not found on PATH. Install a Lua interpreter or pass -SkipTests."
  }
  Write-Host "==> Running tests"
  & lua "tests/test_snippet_db.lua"
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Tests failed (exit $LASTEXITCODE)."
  }
}

$bash = Find-Bash
if (-not $bash) {
  Write-Error "Git Bash (bash.exe) not found. Install Git for Windows or put bash on PATH."
}

$releaseSh = Join-Path $RepoRoot ".release\release.sh"
if (-not (Test-Path $releaseSh)) {
  Write-Error "Missing $releaseSh. Restore from BigWigsMods/packager (pinned v2.7.0)."
}

$unixRoot = ConvertTo-GitBashPath $RepoRoot
$useFallbackZip = -not (Test-GitBashHasZip $bash)
$argList = @()
if ($DryRun) { $argList += "-d" }
if ($useFallbackZip) {
  Write-Host "==> zip not found in Git Bash; packager will skip zip (-z), then Python/Compress-Archive will create a real ZIP"
  $argList += "-z"
}
if ($ExtraArgs) { $argList += $ExtraArgs }
$argString = ($argList | ForEach-Object {
  if ($_ -match '[\s]') { "'" + ($_ -replace "'", "'\''") + "'" } else { $_ }
}) -join " "

Write-Host "==> Packaging with release.sh $argString"
$bashCmd = "cd '$unixRoot' && bash ./.release/release.sh $argString"
& $bash -lc $bashCmd
if ($LASTEXITCODE -ne 0) {
  Write-Error "release.sh failed (exit $LASTEXITCODE)."
}

$packageDir = Join-Path $RepoRoot ".release\snippets"
if (-not (Test-Path (Join-Path $packageDir "snippets.toc"))) {
  Write-Error "Expected packaged TOC at .release/snippets/snippets.toc"
}
$forbidden = @("docs", "tests", "scripts")
foreach ($name in $forbidden) {
  if (Test-Path (Join-Path $packageDir $name)) {
    Write-Error "Packaged tree must not contain '$name'."
  }
}

if ($useFallbackZip) {
  $toc = Get-Content (Join-Path $packageDir "snippets.toc") -Raw
  $version = "unknown"
  if ($toc -match '(?m)^## Version:\s*(.+)\s*$') {
    $version = $Matches[1].Trim()
  }
  $zipName = "snippets-$version-forever.zip"
  $zipPath = Join-Path (Join-Path $RepoRoot ".release") $zipName
  Write-Host "==> Creating $zipName (real ZIP fallback)"
  New-ReleaseZip -PackageDir $packageDir -ZipPath $zipPath
}

Write-Host "==> Done. Artifacts are under .release/"
Get-ChildItem (Join-Path $RepoRoot ".release\*.zip") | ForEach-Object { Write-Host "  $($_.Name) ($([int]($_.Length/1KB)) KB)" }
