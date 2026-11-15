-- Shared macro fragments for Forever race IF-blocks and High-confidence off-GCD prefixes.
-- See docs/forever-offgcd-research.md (High only for stacking).
Snippets = Snippets or {}
Snippets.Shared = Snippets.Shared or {}

local S = Snippets.Shared

-- Racial burst used in Forever racial+trinket macros.
-- High: Blood Fury, Berserking, Eureka!. Unverified GCD: Elune's Light (Night Elf +10% crit; helps damage and heals).
S.RACIAL_BURST_IF =
  "{IF:ORC=/cast Blood Fury|TROLL=/cast Berserking|GNOME=/cast Eureka!|NIGHTELF=/cast Elune's Light}"

-- On-use trinkets (High: no GCD per Forever macro guides).
S.TRINKETS = "/use 13\n/use 14"

function S.join(...)
  local parts = { ... }
  local out = {}
  for i = 1, #parts do
    local part = parts[i]
    if type(part) == "string" and part ~= "" then
      -- Trim leading/trailing newlines from long strings.
      part = string.gsub(part, "^\n+", "")
      part = string.gsub(part, "\n+$", "")
      if part ~= "" then
        out[#out + 1] = part
      end
    end
  end
  return table.concat(out, "\n")
end

-- Utility / defensive actives for engage macros (GCD Unverified; IF drops unmatched races).
-- Two IF blocks so races with two actives (Human, Skyborne) can expand both.
-- Skyborne UnitRace tokens Unverified (HIGHORDER / WINDSHAPER) — confirm with /dump UnitRace("player").
-- Rapid Regeneration is omitted: channel cancelled by any action.
S.RACIAL_DEFENSIVE_IF = S.join(
  "{IF:DWARF=/cast Stoneform|GNOME=/cast Escape Artist|SCOURGE=/cast Will of the Forsaken|NIGHTELF=/cast Shadowmeld|HUMAN=/cast Will to Survive|TAUREN=/cast War Stomp|ORC=/cast Shatter Curse|HIGHORDER=/cast Walk on Air|WINDSHAPER=/cast Walk on Air}",
  "{IF:HUMAN=/cast Perception|HIGHORDER=/cast Read Ley Line|WINDSHAPER=/cast Skysight}"
)

-- Trinkets + High racial burst, then the rest of the body (free cooldown first).
function S.withBurstPrefix(body)
  return S.join(S.TRINKETS, S.RACIAL_BURST_IF, body)
end

-- High racial burst only (no trinkets), then body.
function S.withRacialBurst(body)
  return S.join(S.RACIAL_BURST_IF, body)
end
