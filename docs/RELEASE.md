# Releasing Snippets

Local packaging uses [BigWigsMods/packager](https://github.com/BigWigsMods/packager) (`release.sh` **v2.7.0**, Forever-aware).

## Prerequisites (Windows)

- Git for Windows (Git Bash; not the WSL `bash.exe` launcher)
- `lua` on PATH (for unit tests), or pass `-SkipTests`
- `curl` (for upload)
- `jq` on PATH when uploading (not required for dry-run)
- Info-ZIP `zip` in Git Bash **or** Windows `tar.exe` (script falls back to `tar -a` automatically)

## One-time setup

1. Ensure [`.release/release.sh`](../.release/release.sh) is present (tracked in git; pinned **BigWigsMods/packager v2.7.0**).
2. Copy [`.release/.env.example`](../.release/.env.example) to `.release/.env` and add tokens when you are ready to upload:
   - `CF_API_TOKEN` — CurseForge
   - `WAGO_API_TOKEN` — Wago Addons  
   `scripts/release.ps1` loads `.release/.env` (and optionally repo-root `.env`) into the process environment before calling `release.sh`. Do not commit either env file.
3. When CurseForge / Wago projects exist, add these lines to [`snippets/snippets.toc`](../snippets/snippets.toc):
   - `## X-Curse-Project-ID: <id>`
   - `## X-Wago-ID: <id>`

Until those IDs exist, omit the lines (dry-run packaging still works; upload needs real IDs + tokens).

## Versioning

Packager reads the version from an **annotated git tag** on HEAD (for example `v1.1.0`).  
`## Version: @project-version@` in the TOC is replaced at package time.

```powershell
git tag -a v1.1.0 -m "v1.1.0"
```

Untagged HEAD builds are treated as alpha by packager.

## Local in-game test (not a release)

Copy the working tree addon into Forever AddOns:

```powershell
.\scripts\publish-local.ps1
```

Same test policy as release: requires `lua` on PATH unless you pass `-SkipTests`. See [`INSTALL.md`](INSTALL.md) for path overrides. This does **not** run packager or upload.

## Commands

Dry-run (tests + zip, no upload):

```powershell
.\scripts\release.ps1 -DryRun
```


Skip tests:

```powershell
.\scripts\release.ps1 -DryRun -SkipTests
```

Upload (requires `.env` tokens and real project IDs):

```powershell
.\scripts\release.ps1
```

Extra `release.sh` flags:

```powershell
.\scripts\release.ps1 -DryRun -ExtraArgs @("-g", "forever")
```

## What gets packaged

[`.pkgmeta`](../.pkgmeta) uses `package-as: snippets` and `move-folders` so the nested [`snippets/`](../snippets/) addon becomes the zip root. `ignore` excludes docs, tests, scripts, and other repo metadata.

Artifacts land under `.release/` (gitignored except `release.sh` and `.env.example`).

## CurseForge description

Paste [`docs/CURSEFORGE.md`](CURSEFORGE.md) (body below the horizontal rule) into the CurseForge project Description field when the project exists. That file is not included in the zip.
