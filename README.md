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

- UI strings live in `Locale/enUS.lua` (`Snippets:T("KEY")`)
- Options → AddOns → Snippets panel (version, help text, open button)
- Template database of macro snippets, one data file per class
- List filtered automatically to the logged-in character’s class (`UnitClass`)
- PvE / PvP filter buttons (`general` snippets appear in both)
- Race conditionals in template bodies (`{IF:…}`) expanded from `UnitRace`
- Preview pane shows the expanded macro (editable before create)
- Hover a list row to see the snippet `note` as a tooltip description
- Bodies always get `#showtooltip` with the primary `/cast` spell (bare `#showtooltip` for `/castsequence`)
- High off-GCD `/cast` lines are omitted until the spell is known (`IsSpellKnown`)
- **Maintain** checkbox: re-sync from the raw template on login / `SPELLS_CHANGED` (disabled if preview was edited)
- **Create Macro** uses `CreateMacro` with the `?` icon (character macros by default)
- Options → AddOns → Snippets panel (icon, version, help text, open button)
- Feature flags (`ENABLED`, `MAINTAIN_ENABLED`) to disable UI or maintain without removing the addon
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
4. Select a snippet in the list (hover a row to read its description tooltip).
5. Check the **Preview** pane — `{IF:…}` blocks are already expanded for your race (you can still edit).
6. Optionally enable **Maintain** — only available while the preview matches the expanded template (no manual edits). Maintained macros re-sync from the template on login and when spells change; that overwrites the macro body on purpose.
7. Click **Create Macro** — without Maintain the preview text is the source (then run through the same expand/filter/`#showtooltip` pipeline); with Maintain the raw template is the source.

The new macro appears in the Blizzard macro UI (opened automatically on create, character tab when `PER_CHARACTER` is on). Creation is blocked while in combat. If a name is already taken, a numeric suffix is added (`Charge`, `Charge 2`, …). Names are limited to 16 characters; bodies to 255 characters (newlines count).

Close the Snippets window with the frame’s X or Escape (`UISpecialFrames`).

## Configuration

Edit [`snippets/Config.lua`](snippets/Config.lua):

| Setting | Default | Meaning |
| --- | --- | --- |
| `ENABLED` | `true` | Feature flag. `false` disables slash command and UI. |
| `MAINTAIN_ENABLED` | `true` | Feature flag for Maintain checkbox and template re-sync. |
| `PER_CHARACTER` | `true` | `true` = character macros; `false` = general account macros. |
| `MAX_BODY_LENGTH` | `255` | Client macro body limit. |
| `MAX_NAME_LENGTH` | `16` | Client macro name limit. |
| `ADDON_NAME` | `"Snippets"` | Display name used by the addon. |
| `VERSION` | `"1.2.0"` | Options panel version when TOC `@project-version@` is not packaged yet. |
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
| `note` | no | Author note shown as a tooltip when hovering the snippet in the list. |

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

`Data/GENERAL.lua` registers shared trinket/racial templates onto every class. Per-class files: `WARRIOR`, `PALADIN`, `HUNTER`, `ROGUE`, `PRIEST`, `SHAMAN`, `MAGE`, `WARLOCK`, `DRUID` — Forever essentials from [`docs/MACROS.md`](docs/MACROS.md). Shared helpers live in `Data/SHARED.lua` (trinkets + racial burst including Night Elf **Elune's Light**). Curing/dispel templates: Druid Cure Key, Mage Remove Lesser Curse, Shaman Cure Poison/Disease, Priest Cure/Abolish Disease; Paladin uses existing Cleanse. Castsequence openers (DoTs, Mark/Sting, Vigil/Shock, …) are listed under Cast sequences in [`docs/MACROS.md`](docs/MACROS.md).


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

See `Data/WARRIOR.lua` (`warrior_charge_intercept`) for a fuller example.

## Documentation

| Doc | Contents |
| --- | --- |
| [`docs/INSTALL.md`](docs/INSTALL.md) | Short install guide |
| [`docs/RELEASE.md`](docs/RELEASE.md) | Local packager / CurseForge–Wago release |
| [`docs/CURSEFORGE.md`](docs/CURSEFORGE.md) | User-facing CurseForge / Wago description (when published) |
| [`docs/MACROS.md`](docs/MACROS.md) | Forever-first common macros (general + all classes) |
| [`docs/forever-offgcd-research.md`](docs/forever-offgcd-research.md) | Off-GCD stacking research for Forever |

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
  Locale/enUS.lua         # UI strings (English)
  UI/Options.lua          # Options → AddOns → Snippets
  Data/SHARED.lua         # Racial IF fragments + High off-GCD burst helpers
  Data/GENERAL.lua        # Shared templates registered for every class
  Data/*.lua              # Per-class Forever essentials (may include {IF:...})


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

- Snippet templates stay in Lua files. **Maintain** uses per-character SavedVariables (`SnippetsDB`) for the opt-in list; Forever may not load SV after a cold start — re-create with Maintain or re-seed after login if the list is empty. Stale entries are removed when the macro slot is missing.
- Macros created with **Create Macro** do persist across client restarts.
- `## Interface: 16001` matches the Forever client; do not treat this as Classic Era `115xx` tooling.
- Forever lacks Retail specializations the same way Retail does; class filtering uses class file tokens only, not spec.
- Race conditionals use `UnitRace` file tokens (`Human`, `Orc`, `Scourge`, …).

## Editor (LuaLS)

[`.luarc.json`](.luarc.json) whitelists WoW client globals (`CreateFrame`, `DEFAULT_CHAT_FRAME`, `CreateMacro`, …) so the language server does not report false “undefined global” warnings. Reload the Lua language server (or the editor window) after cloning if warnings linger.

Existence checks on methods must use `.` (e.g. `Snippets.IsMaintainEnabled`), not `:`. A bare `Snippets:IsMaintainEnabled and …` is a parse error (`function arguments expected near 'and'`) because `:` always starts a method call.

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
- [ ] Hovering a list row with a `note` shows a description tooltip; empty notes show no tooltip.
- [ ] **Create Macro** creates a usable character macro and opens the Blizzard macro UI (character tab when configured).
- [ ] Snippets window has no bottom Close button; X / Escape still close it.
- [ ] Creating the same snippet twice gets a unique name suffix.
- [ ] In combat, creation fails with a clear status message.
- [ ] `ENABLED = false` disables slash/UI after `/reload`.
- [ ] Options → AddOns → Snippets shows name, version, help text, and Open Snippets.

## License

Personal / project use unless otherwise stated by the repository owner.
