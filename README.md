# Snippets

Class-filtered macro snippet templates for **World of Warcraft: Forever**.

Open a browser with `/snippets`, pick a template for your current class, and click **Create Macro** to add it to the Blizzard macro list.

| | |
| --- | --- |
| Interface | `16001` (Forever / build line 1.60.x) |
| Slash command | `/snippets` |
| Language | English (UI, docs, and data) |
| Version | From git tag via `@project-version@` in TOC (see [`docs/RELEASE.md`](docs/RELEASE.md)) |

## Features

- Template database of macro snippets, one data file per class
- List filtered automatically to the logged-in character’s class (`UnitClass`)
- PvE / PvP filter buttons (`general` snippets appear in both)
- Race conditionals in template bodies (`{IF:…}`) expanded from `UnitRace`
- Preview pane shows the expanded macro (editable before create)
- **Create Macro** uses `CreateMacro` (character macros by default)
- Options → AddOns → Snippets panel (icon, version, help text, open button)
- Feature flag (`ENABLED`) to disable the whole UI without removing the addon
- Pure Lua unit tests for the snippet registry helpers

## Install

1. Copy the `snippets` folder into your Forever AddOns directory, for example:

   `World of Warcraft\_forever_\Interface\AddOns\snippets`

2. Restart the client, or log out and back in.
3. Enable **Snippets** on the character addon list if it is disabled.
4. Type `/snippets` in chat.

## Usage

1. Log in on the character you want macros for.
2. Run `/snippets`.
3. Choose **PvE** or **PvP** (general templates stay visible in both).
4. Select a snippet in the list.
5. Check the **Preview** pane — `{IF:…}` blocks are already expanded for your race (you can still edit).
6. Click **Create Macro** — the macro body is taken from the preview contents.

The new macro appears in the normal Blizzard macro UI. Creation is blocked while in combat. If a name is already taken, a numeric suffix is added (`Charge`, `Charge 2`, …). Names are limited to 16 characters; bodies to 255 characters (newlines count).

Close the window with **Close**, the frame’s X, or Escape (`UISpecialFrames`).

## Configuration

Edit [`snippets/Config.lua`](snippets/Config.lua):

| Setting | Default | Meaning |
| --- | --- | --- |
| `ENABLED` | `true` | Feature flag. `false` disables slash command and UI. |
| `PER_CHARACTER` | `true` | `true` = character macros; `false` = general account macros. |
| `MAX_BODY_LENGTH` | `255` | Client macro body limit. |
| `MAX_NAME_LENGTH` | `16` | Client macro name limit. |
| `ADDON_NAME` | `"Snippets"` | Display name used by the addon. |
| `SLASH_COMMAND` | `"/snippets"` | Documented slash command (registration is in `Core.lua`). |
| `DEFAULT_FILTER` | `"pve"` | Initial list filter: `"pve"` or `"pvp"`. |

After changing config or data files, reload with `/reload`.

## Adding or editing snippets

Edit files under [`snippets/Data/`](snippets/Data/). Each class file registers templates:

```lua
Snippets.DB:Register("MAGE", {
  id = "mage_frostbolt",
  name = "Frostbolt",
  icon = "Spell_Frost_FrostBolt02",
  body = "/cast Frostbolt",
  note = "Example template",
})
```

| Field | Required | Description |
| --- | --- | --- |
| `id` | yes | Unique within that class file. |
| `name` | recommended | Macro name shown in the list and used for `CreateMacro`. |
| `icon` | no | Icon token (defaults to `INV_Misc_QuestionMark`). |
| `body` | yes | Macro text. Empty bodies cannot be created. |
| `category` | no | `general` (default), `pve`, or `pvp`. `general` is shown under both filters. |
| `note` | no | Author note (not shown in the UI yet). |

### Multiline macros

Use a Lua long string or escaped newlines:

```lua
body = [[
/stopcasting
/cast Counterspell
]]

-- or:
body = "/stopattack\n/cast Feign Death"
```

Examples ship in `Data/MAGE.lua` (long string) and `Data/HUNTER.lua` (`\n`).

### Classes included

`WARRIOR`, `PALADIN`, `HUNTER`, `ROGUE`, `PRIEST`, `SHAMAN`, `MAGE`, `WARLOCK`, `DRUID` — each with a few placeholder templates. Replace them with your own macros.

### Race conditionals (`{IF:…}`)

Embed race-specific lines inside any class template. Tokens match `UnitRace` file values (`Scourge` = Undead):

```lua
body = [[
/cast Charge
{IF:DWARF=/cast Stoneform|GNOME=/cast Escape Artist|ORC=/cast Blood Fury}
]]
```

- On a Dwarf this becomes `/cast Charge` + `/cast Stoneform`.
- On a race with no matching branch, the whole `{IF:…}` block is removed.
- Use `\n` inside a branch value for an extra line break.
- Preview and **Create Macro** both expand against the current character race.

See `Data/WARRIOR.lua` (`warrior_charge`) for a fuller example.

## Documentation

| Doc | Contents |
| --- | --- |
| [`docs/INSTALL.md`](docs/INSTALL.md) | Short install guide |
| [`docs/RELEASE.md`](docs/RELEASE.md) | Local packager / CurseForge–Wago release |
| [`docs/CURSEFORGE.md`](docs/CURSEFORGE.md) | User-facing CurseForge / Wago description (when published) |

## Local Forever install (dev)

```powershell
.\scripts\publish-local.ps1
```

```bash
./scripts/publish-local.sh
```

Copies `snippets/` into your Forever `Interface\AddOns` folder (auto-detects common Forever paths when present). Override with `-Destination` / `--destination`, `SNIPPETS_FOREVER_ADDONS`, or `scripts/forever-addons.path`. Then `/reload` in-game.

## Release (local)

```powershell
.\scripts\release.ps1 -DryRun
```

```bash
./scripts/release.sh --dry-run
```

Requires bash (Git Bash on Windows) and `lua` on PATH. See [`docs/RELEASE.md`](docs/RELEASE.md). Add `X-Curse-Project-ID` / `X-Wago-ID` to the TOC only when those projects exist.

## Project layout

```
snippets/                 # Addon folder (copy this to Interface/AddOns)
  snippets.toc
  Config.lua
  SnippetDB.lua
  Core.lua
  UI/Window.lua
  UI/Options.lua          # Options → AddOns → Snippets
  Data/*.lua              # Per-class templates (may include {IF:...} blocks)
.pkgmeta                  # BigWigs packager ignore / package-as
.release/release.sh       # Pinned BigWigs packager (v2.7.0)
scripts/release.ps1       # Tests + package (+ optional upload) — Windows
scripts/release.sh        # Same as release.ps1 — bash / Git Bash / macOS / Linux
scripts/publish-local.ps1 # Copy addon into local Forever AddOns
scripts/publish-local.sh  # Same as publish-local.ps1 — bash
docs/INSTALL.md           # Short install guide
docs/RELEASE.md           # Release instructions
tests/test_snippet_db.lua # Unit tests (no WoW client required)
.luarc.json               # LuaLS WoW globals
README.md
```

## Forever-specific notes

- Snippet data is stored in Lua files on purpose. Forever does not load SavedVariables after a cold start.
- Macros created with **Create Macro** do persist across client restarts.
- `## Interface: 16001` matches the Forever client; do not treat this as Classic Era `115xx` tooling.
- Forever lacks Retail specializations the same way Retail does; class filtering uses class file tokens only, not spec.
- Race conditionals use `UnitRace` file tokens (`Human`, `Orc`, `Scourge`, …).

## Editor (LuaLS)

[`.luarc.json`](.luarc.json) whitelists WoW client globals (`CreateFrame`, `DEFAULT_CHAT_FRAME`, `CreateMacro`, …) so the language server does not report false “undefined global” warnings. Reload the Lua language server (or the editor window) after cloning if warnings linger.

## Tests

Requires a local Lua interpreter (5.1+ / 5.4 is fine). From the repository root:

```bash
lua tests/test_snippet_db.lua
```

Coverage includes class filtering, PvE/PvP category filtering, unique macro names (including the 16-character limit), body clamping to 255 characters, multiline bodies, and `{IF:…}` race expansion.

## QA checklist

- [ ] Addon loads on Forever (`Interface` 16001).
- [ ] `/snippets` opens the window when `ENABLED = true`.
- [ ] List matches the current character class.
- [ ] PvE filter shows `general` + `pve`; PvP filter shows `general` + `pvp`.
- [ ] Preview expands `{IF:…}` for the current race and drops unmatched branches.
- [ ] Preview shows single-line and multiline bodies.
- [ ] **Create Macro** creates a usable character macro.
- [ ] Creating the same snippet twice gets a unique name suffix.
- [ ] In combat, creation fails with a clear status message.
- [ ] `ENABLED = false` disables slash/UI after `/reload`.
- [ ] Options → AddOns → Snippets shows name, version, help text, and Open Snippets.

## License

Personal / project use unless otherwise stated by the repository owner.
