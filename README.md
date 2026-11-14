# Snippets

Class-filtered macro snippet templates for **World of Warcraft: Forever**.

Open a browser with `/snippets`, pick a template for your current class, and click **Create Macro** to add it to the Blizzard macro list.

| | |
| --- | --- |
| Interface | `16001` (Forever / build line 1.60.x) |
| Slash command | `/snippets` |
| Language | English (UI, docs, and data) |
| Version | 1.0.0 |

## Features

- Template database of macro snippets, one data file per class
- List filtered automatically to the logged-in character’s class (`UnitClass`)
- Preview pane for the selected macro body (including multiline)
- **Create Macro** uses `CreateMacro` (character macros by default)
- Feature flag to disable the UI without removing the addon
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
3. Select a snippet in the list (only that class’s templates are shown).
4. Check the **Preview** pane (you can edit the text before creating).
5. Click **Create Macro** — the macro body is taken from the preview contents.

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

## Project layout

```
snippets/                 # Addon folder (copy this to Interface/AddOns)
  snippets.toc
  Config.lua
  SnippetDB.lua
  Core.lua
  UI/Window.lua
  Data/*.lua              # Per-class templates
docs/INSTALL.md           # Short install guide
tests/test_snippet_db.lua # Unit tests (no WoW client required)
.luarc.json               # LuaLS WoW globals
README.md
```

## Forever-specific notes

- Snippet data is stored in Lua files on purpose. Forever does not load SavedVariables after a cold start.
- Macros created with **Create Macro** do persist across client restarts.
- `## Interface: 16001` matches the Forever client; do not treat this as Classic Era `115xx` tooling.
- Forever lacks Retail specializations the same way Retail does; filtering uses class file tokens only, not spec.

## Editor (LuaLS)

[`.luarc.json`](.luarc.json) whitelists WoW client globals (`CreateFrame`, `DEFAULT_CHAT_FRAME`, `CreateMacro`, …) so the language server does not report false “undefined global” warnings. Reload the Lua language server (or the editor window) after cloning if warnings linger.

## Tests

Requires a local Lua interpreter (5.1+ / 5.4 is fine). From the repository root:

```bash
lua tests/test_snippet_db.lua
```

Coverage includes class filtering, unique macro names (including the 16-character limit), body clamping to 255 characters, and multiline body handling.

## QA checklist

- [ ] Addon loads on Forever (`Interface` 16001).
- [ ] `/snippets` opens the window when `ENABLED = true`.
- [ ] List matches the current character class only.
- [ ] Preview shows single-line and multiline bodies.
- [ ] **Create Macro** creates a usable character macro.
- [ ] Creating the same snippet twice gets a unique name suffix.
- [ ] In combat, creation fails with a clear status message.
- [ ] `ENABLED = false` disables slash/UI after `/reload`.

## License

Personal / project use unless otherwise stated by the repository owner.
