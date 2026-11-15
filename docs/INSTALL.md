# Snippets (WoW Forever)

Class-filtered macro snippet templates. Open with `/snippets`, select a snippet, and click **Create Macro**.

## Install

1. Copy the `snippets` folder into your Forever AddOns directory, for example:

   `World of Warcraft\_forever_\Interface\AddOns\snippets`

2. Restart the client or log out and back in.
3. Enable **Snippets** on the addon list if it is disabled.
4. Type `/snippets` in chat (or the value of `Snippets.Config.SLASH_COMMAND`), or open **Options → AddOns → Snippets** and click **Open Snippets**.

### Publish from this repo (developers)

Copy the addon into your local Forever AddOns folder:

```powershell
.\scripts\publish-local.ps1
```

```bash
./scripts/publish-local.sh
```

Optional: `-Destination` / `--destination "…\Interface\AddOns"`, or set `SNIPPETS_FOREVER_ADDONS`, or copy `scripts/forever-addons.path.example` to `scripts/forever-addons.path`.

Then `/reload` in-game.

The preview pane is editable; **Create Macro** uses the preview text and opens the Blizzard macro UI. Hover a list row to read the snippet `note` as a description tooltip.

## Configuration

Edit `snippets/Config.lua`:

| Setting | Meaning |
| --- | --- |
| `ENABLED` | Feature flag. Set `false` to disable slash command and UI. |
| `PER_CHARACTER` | `true` creates character macros; `false` creates general macros. |
| `DEFAULT_FILTER` | `"pve"` or `"pvp"` — which list filter is active when the window opens. |

## Add or edit snippets

Edit or add files under `snippets/Data/`. Each class file registers templates like this:

```lua
Snippets.DB:Register("MAGE", {
  id = "mage_frostbolt",
  name = "Frostbolt",
  icon = "Spell_Frost_FrostBolt02",
  body = "/cast Frostbolt",
  note = "Example template",
})
```

Multiline macros — use a Lua long string or `\n`:

```lua
body = [[
/stopcasting
/cast Counterspell
]]

-- or:
body = "/stopattack\n/cast Feign Death"
```

Categories — `general` (default, shown in PvE and PvP), `pve`, or `pvp`:

```lua
category = "pvp",
```

Race conditionals — expanded from the character’s `UnitRace` file token:

```lua
body = [[
/cast Charge
{IF:DWARF=/cast Stoneform|GNOME=/cast Escape Artist}
]]
```

- `id` must be unique within the class file.
- Macro body is limited to 255 characters (newlines count).
- Macro name is limited to 16 characters (longer names are truncated; collisions get a numeric suffix).

Reload with `/reload` after editing data files.

## Notes for Forever

- Snippet templates live in Lua files. **Maintain** stores its opt-in list in per-character SavedVariables (`SnippetsDB`); Forever may not load SV after a cold start — the list is re-seeded on create/sync when SV is present. Missing macro slots drop their maintain entries.
- Macros created with **Create Macro** do persist across restarts. Maintained macros are rewritten from the template on login and `SPELLS_CHANGED` (including newly learned High off-GCD spells).
- Macro creation and `EditMacro` re-sync are blocked in combat (pending sync runs after combat).

## Editor (LuaLS)

The repo root includes `.luarc.json` so LuaLS treats WoW client APIs
(`CreateFrame`, `DEFAULT_CHAT_FRAME`, `CreateMacro`, …) as known globals.

## Tests

From the repository root (requires a local Lua interpreter):

```
lua tests/test_snippet_db.lua
```
