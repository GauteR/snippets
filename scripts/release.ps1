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

  Non-dry-run creates annotated tag v{Config.VERSION} on HEAD when missing.
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
  # Windows tar creates zip archives without requiring Info-ZIP.
  Push-Location $parent
  try {
    & tar.exe -a -cf $ZipPath $name
    if ($LASTEXITCODE -ne 0) {
      Write-Error "tar failed to create $ZipPath (exit $LASTEXITCODE)."
    }
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

# Create annotated v{Config.VERSION} on HEAD when missing (real releases only).
function Ensure-VersionTag([string]$ConfigPath) {
  if (-not (Test-Path $ConfigPath)) {
    Write-Error "Missing Config.lua at $ConfigPath"
  }
  $raw = Get-Content $ConfigPath -Raw
  if ($raw -notmatch '(?m)^\s*VERSION\s*=\s*"([^"]+)"') {
    Write-Error "Could not resolve Config.VERSION from $ConfigPath"
  }
  $version = $Matches[1].Trim()
  $tag = "v$version"
  # Avoid piping git into Out-Null — that can drop a reliable $LASTEXITCODE.
  & git show-ref --tags --verify --quiet "refs/tags/$tag"
  if ($LASTEXITCODE -eq 0) {
    $tagCommit = (git rev-list -n 1 $tag).Trim()
    $headCommit = (git rev-parse HEAD).Trim()
    if ($tagCommit -ne $headCommit) {
      Write-Error "Tag $tag exists but does not point at HEAD ($tagCommit vs $headCommit)."
    }
    Write-Host "==> Tag $tag already on HEAD"
    return
  }
  Write-Host "==> Creating annotated tag $tag from Config.VERSION"
  git tag -a $tag -m $tag
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to create tag $tag (exit $LASTEXITCODE)."
  }
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
$useTarZip = -not (Test-GitBashHasZip $bash)
$argList = @()
if ($DryRun) {
  $argList += "-d"
} else {
  Ensure-VersionTag (Join-Path $RepoRoot "snippets\Config.lua")
}
if ($useTarZip) {
  Write-Host "==> zip not found in Git Bash; packager will skip zip (-z), then tar.exe will create it"
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

if ($useTarZip) {
  $toc = Get-Content (Join-Path $packageDir "snippets.toc") -Raw
  $version = "unknown"
  if ($toc -match '(?m)^## Version:\s*(.+)\s*$') {
    $version = $Matches[1].Trim()
  }
  $zipName = "snippets-$version-forever.zip"
  $zipPath = Join-Path (Join-Path $RepoRoot ".release") $zipName
  Write-Host "==> Creating $zipName with tar.exe"
  New-ReleaseZip -PackageDir $packageDir -ZipPath $zipPath
}

Write-Host "==> Done. Artifacts are under .release/"
Get-ChildItem (Join-Path $RepoRoot ".release\*.zip") | ForEach-Object { Write-Host "  $($_.Name) ($([int]($_.Length/1KB)) KB)" }
