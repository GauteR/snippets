#Requires -Version 5.1
<#
.SYNOPSIS
  Copy the snippets addon into a local Forever AddOns folder for in-game testing.

.PARAMETER Destination
  Full path to the AddOns directory (parent of the snippets folder), or to the
  snippets folder itself. Overrides env SNIPPETS_FOREVER_ADDONS.

.PARAMETER SkipTests
  Skip lua tests/test_snippet_db.lua.

.PARAMETER WhatIf
  Show what would be copied without writing files.
#>
param(
  [string]$Destination = "",
  [switch]$SkipTests,
  [switch]$WhatIf
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Source = Join-Path $RepoRoot "snippets"

function Resolve-ForeverAddOnsDir {
  param([string]$Explicit)

  if ($Explicit) {
    $p = $Explicit.TrimEnd('\', '/')
    if ((Split-Path -Leaf $p) -eq "snippets") {
      return (Split-Path -Parent $p)
    }
    return $p
  }

  if ($env:SNIPPETS_FOREVER_ADDONS) {
    $p = $env:SNIPPETS_FOREVER_ADDONS.TrimEnd('\', '/')
    if ((Split-Path -Leaf $p) -eq "snippets") {
      return (Split-Path -Parent $p)
    }
    return $p
  }

  $localFile = Join-Path $PSScriptRoot "forever-addons.path"
  if (Test-Path $localFile) {
    $pathLine = $null
    foreach ($raw in Get-Content $localFile) {
      $line = $raw.Trim()
      if (-not $line -or $line.StartsWith("#")) { continue }
      $pathLine = $line
      break
    }
    if ($pathLine) {
      $p = $pathLine.TrimEnd('\', '/')
      if ((Split-Path -Leaf $p) -eq "snippets") {
        return (Split-Path -Parent $p)
      }
      return $p
    }
  }

  $candidates = @(
    "D:\World of Warcraft\_forever_\Interface\AddOns",
    "C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns",
    "C:\Program Files\World of Warcraft\_forever_\Interface\AddOns",
    (Join-Path ${env:ProgramFiles(x86)} "World of Warcraft\_forever_\Interface\AddOns"),
    (Join-Path $env:ProgramFiles "World of Warcraft\_forever_\Interface\AddOns")
  )
  foreach ($c in $candidates) {
    if ($c -and (Test-Path $c)) { return $c }
  }

  return $null
}

if (-not (Test-Path (Join-Path $Source "snippets.toc"))) {
  Write-Error "Missing addon source at $Source (expected snippets.toc)."
}

if (-not $SkipTests) {
  $lua = Get-Command lua -ErrorAction SilentlyContinue
  if (-not $lua) {
    Write-Error "lua not found on PATH. Install a Lua interpreter or pass -SkipTests."
  }
  Write-Host "==> Running tests"
  & lua (Join-Path $RepoRoot "tests\test_snippet_db.lua")
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Tests failed (exit $LASTEXITCODE)."
  }
}

$addonsDir = Resolve-ForeverAddOnsDir -Explicit $Destination
if (-not $addonsDir) {
  Write-Error @"
Could not find Forever AddOns folder.
Pass -Destination, set SNIPPETS_FOREVER_ADDONS, or create scripts/forever-addons.path
with one line, e.g.:
  D:\World of Warcraft\_forever_\Interface\AddOns
"@
}

if (-not (Test-Path $addonsDir)) {
  Write-Error "AddOns directory does not exist: $addonsDir"
}

$target = Join-Path $addonsDir "snippets"
Write-Host "==> Publishing $Source"
Write-Host "    -> $target"

if ($WhatIf) {
  Write-Host "WhatIf: would replace target with source contents."
  return
}

if (Test-Path $target) {
  Remove-Item -LiteralPath $target -Recurse -Force
}
New-Item -ItemType Directory -Path $target -Force | Out-Null
Copy-Item -Path (Join-Path $Source "*") -Destination $target -Recurse -Force

$toc = Join-Path $target "snippets.toc"
if (-not (Test-Path $toc)) {
  Write-Error "Publish failed: missing $toc"
}

Write-Host "==> Done. Reload the Forever client (/reload) or restart to load changes."
