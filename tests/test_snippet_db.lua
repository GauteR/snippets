-- Pure Lua tests for Snippets DB helpers (no WoW runtime required).
-- Run: lua tests/test_snippet_db.lua

local root = arg[0]:match("^(.*)[/\\]") or "."
local addonRoot = root .. "/../snippets"

dofile(addonRoot .. "/Config.lua")
dofile(addonRoot .. "/SnippetDB.lua")

local failures = 0

local function assert_eq(actual, expected, message)
  if actual ~= expected then
    failures = failures + 1
    print(string.format("FAIL: %s\n  expected: %s\n  actual:   %s", message, tostring(expected), tostring(actual)))
  else
    print("PASS: " .. message)
  end
end

local function assert_true(condition, message)
  if not condition then
    failures = failures + 1
    print("FAIL: " .. message)
  else
    print("PASS: " .. message)
  end
end

-- Register sample data
Snippets.DB:Register("WARRIOR", {
  id = "warrior_charge",
  name = "Charge",
  icon = "INV_Misc_QuestionMark",
  body = "/cast Charge",
  note = "Example",
})
Snippets.DB:Register("WARRIOR", {
  id = "warrior_shout",
  name = "Battle Shout",
  icon = "INV_Misc_QuestionMark",
  body = "/cast Battle Shout",
  note = "Example",
})
Snippets.DB:Register("MAGE", {
  id = "mage_food",
  name = "Conjure Food",
  icon = "INV_Misc_QuestionMark",
  body = "/cast Conjure Food",
  note = "Example",
})

-- Multiline body using a Lua long string (same form as in Data/*.lua examples).
local multilineBody = [[
/stopcasting
/cast Counterspell
]]
Snippets.DB:Register("MAGE", {
  id = "mage_counterspell_multiline",
  name = "Counterspell",
  icon = "INV_Misc_QuestionMark",
  body = multilineBody,
  note = "Multiline example",
})

-- Multiline body using escaped newlines.
Snippets.DB:Register("HUNTER", {
  id = "hunter_feign_multiline",
  name = "Feign Death",
  icon = "INV_Misc_QuestionMark",
  body = "/stopattack\n/cast Feign Death",
  note = "Multiline example",
})

local warrior = Snippets.DB:GetForClass("WARRIOR")
assert_eq(#warrior, 2, "GetForClass returns warrior snippets only")
assert_eq(warrior[1].id, "warrior_charge", "first warrior snippet id")

local mage = Snippets.DB:GetForClass("MAGE")
assert_eq(#mage, 2, "GetForClass returns mage snippets only")

local empty = Snippets.DB:GetForClass("ROGUE")
assert_eq(#empty, 0, "unknown/empty class returns empty list")

local longBody = string.rep("a", 300)
local clamped = Snippets.DB:ClampBody(longBody)
assert_eq(#clamped, 255, "ClampBody truncates to 255 characters")

local shortBody = "/cast Frostbolt"
assert_eq(Snippets.DB:ClampBody(shortBody), shortBody, "ClampBody keeps short body")

local storedMultiline = Snippets.DB:GetById("MAGE", "mage_counterspell_multiline")
assert_true(storedMultiline ~= nil, "multiline long-string snippet is registered")
assert_eq(storedMultiline.body, multilineBody, "Register keeps long-string newlines")
assert_true(storedMultiline.body:find("\n", 1, true) ~= nil, "long-string body contains newline characters")
assert_eq(
  Snippets.DB:ClampBody(storedMultiline.body),
  multilineBody,
  "ClampBody keeps short multiline body intact"
)

local escapedMultiline = Snippets.DB:GetById("HUNTER", "hunter_feign_multiline")
assert_eq(
  escapedMultiline.body,
  "/stopattack\n/cast Feign Death",
  "Register keeps escaped newline body"
)
assert_eq(
  select(2, escapedMultiline.body:gsub("\n", "\n")),
  1,
  "escaped multiline body has one newline"
)

-- Newlines count toward the 255-character macro limit.
local paddedMultiline = "/cast A\n" .. string.rep("b", 300)
local clampedMultiline = Snippets.DB:ClampBody(paddedMultiline)
assert_eq(#clampedMultiline, 255, "ClampBody truncates multiline bodies to 255 characters")
assert_true(clampedMultiline:find("\n", 1, true) ~= nil, "truncated multiline body still contains a newline")

assert_eq(
  Snippets.DB:MakeUniqueMacroName("Charge", {}),
  "Charge",
  "unique name when unused"
)
assert_eq(
  Snippets.DB:MakeUniqueMacroName("Charge", { Charge = true }),
  "Charge 2",
  "suffix when name exists"
)
assert_eq(
  Snippets.DB:MakeUniqueMacroName("Charge", { Charge = true, ["Charge 2"] = true }),
  "Charge 3",
  "increments until free"
)

-- 16-char WoW name limit: long names are truncated first, then suffix is applied.
assert_eq(
  Snippets.DB:MakeUniqueMacroName("VeryLongMacroNameX", { VeryLongMacroNam = true }),
  "VeryLongMacroN 2",
  "truncates base to fit suffix within 16 chars"
)

local byId = Snippets.DB:GetById("WARRIOR", "warrior_shout")
assert_true(byId ~= nil, "GetById finds snippet")
assert_eq(byId.name, "Battle Shout", "GetById returns correct snippet")
assert_true(Snippets.DB:GetById("WARRIOR", "missing") == nil, "GetById returns nil for missing id")

-- Race conditionals: {IF:RACE=text|OTHER=text}
local conditional = "/cast Charge\n{IF:DWARF=/cast Stoneform|GNOME=/cast Escape Artist}\n/startattack"

assert_eq(
  Snippets.DB:ExpandConditionals(conditional, "Dwarf"),
  "/cast Charge\n/cast Stoneform\n/startattack",
  "ExpandConditionals picks DWARF branch"
)
assert_eq(
  Snippets.DB:ExpandConditionals(conditional, "GNOME"),
  "/cast Charge\n/cast Escape Artist\n/startattack",
  "ExpandConditionals picks GNOME branch case-insensitively"
)
assert_eq(
  Snippets.DB:ExpandConditionals(conditional, "Orc"),
  "/cast Charge\n/startattack",
  "ExpandConditionals removes block when race does not match"
)
assert_eq(
  Snippets.DB:ExpandConditionals(
    "{IF:ORC=/cast Blood Fury|TROLL=/cast Berserking}",
    "Scourge"
  ),
  "",
  "ExpandConditionals returns empty when only unmatched branches exist"
)
assert_eq(
  Snippets.DB:ExpandConditionals(
    "{IF:SCOURGE=/cast Will of the Forsaken}",
    "Scourge"
  ),
  "/cast Will of the Forsaken",
  "ExpandConditionals matches Scourge undead race token"
)
assert_eq(
  Snippets.DB:ExpandConditionals("{IF:ORC=/cast Blood Fury\\n/startattack}", "Orc"),
  "/cast Blood Fury\n/startattack",
  "ExpandConditionals expands \\n inside branch values"
)

local multi = "{IF:DWARF=/cast Stoneform}{IF:GNOME=/cast Escape Artist}"
assert_eq(
  Snippets.DB:ExpandConditionals(multi, "Dwarf"),
  "/cast Stoneform",
  "ExpandConditionals resolves multiple blocks independently"
)
assert_eq(
  Snippets.DB:ExpandConditionals("{IF:DWARF =/cast Stoneform}", "Dwarf"),
  "/cast Stoneform",
  "ExpandConditionals trims spaces around race tokens"
)

-- Category filter: general visible in both PvE and PvP; pve/pvp are exclusive.
assert_eq(Snippets.DB:NormalizeCategory(nil), "general", "NormalizeCategory defaults nil to general")
assert_eq(Snippets.DB:NormalizeCategory("PvP"), "pvp", "NormalizeCategory lowercases")
assert_eq(Snippets.DB:NormalizeCategory("raid"), "general", "NormalizeCategory falls back for unknown")

assert_true(Snippets.DB:MatchesFilter("general", "pve"), "general matches pve filter")
assert_true(Snippets.DB:MatchesFilter("general", "pvp"), "general matches pvp filter")
assert_true(Snippets.DB:MatchesFilter("pve", "pve"), "pve matches pve filter")
assert_true(not Snippets.DB:MatchesFilter("pve", "pvp"), "pve does not match pvp filter")
assert_true(Snippets.DB:MatchesFilter("pvp", "pvp"), "pvp matches pvp filter")
assert_true(not Snippets.DB:MatchesFilter("pvp", "pve"), "pvp does not match pve filter")

Snippets.DB:Register("ROGUE", {
  id = "rogue_general",
  name = "Sprint",
  category = "general",
  body = "/cast Sprint",
})
Snippets.DB:Register("ROGUE", {
  id = "rogue_pve",
  name = "Sap",
  category = "pve",
  body = "/cast Sap",
})
Snippets.DB:Register("ROGUE", {
  id = "rogue_pvp",
  name = "Kidney Shot",
  category = "pvp",
  body = "/cast Kidney Shot",
})

local roguePve = Snippets.DB:GetForClassAndFilter("ROGUE", "pve")
assert_eq(#roguePve, 2, "PvE filter returns general + pve")
assert_eq(roguePve[1].id, "rogue_general", "PvE filter keeps general first")
assert_eq(roguePve[2].id, "rogue_pve", "PvE filter includes pve")

local roguePvp = Snippets.DB:GetForClassAndFilter("ROGUE", "pvp")
assert_eq(#roguePvp, 2, "PvP filter returns general + pvp")
assert_eq(roguePvp[1].id, "rogue_general", "PvP filter keeps general")
assert_eq(roguePvp[2].id, "rogue_pvp", "PvP filter includes pvp")

-- EnsureShowTooltip
local tipCast = Snippets.DB:EnsureShowTooltip("/cast Shield Block")
assert_eq(tipCast, "#showtooltip Shield Block\n/cast Shield Block", "EnsureShowTooltip adds spell name for /cast")

local tipCond = Snippets.DB:EnsureShowTooltip("/cast [@mouseover,harm,nodead][] Kick")
assert_eq(tipCond, "#showtooltip Kick\n/cast [@mouseover,harm,nodead][] Kick", "EnsureShowTooltip strips conditionals for spell name")

local tipSeq = Snippets.DB:EnsureShowTooltip("/castsequence reset=combat Immolate, Corruption, Shadow Bolt")
assert_eq(tipSeq, "#showtooltip\n/castsequence reset=combat Immolate, Corruption, Shadow Bolt", "EnsureShowTooltip is bare for castsequence")

local tipExisting = Snippets.DB:EnsureShowTooltip("#showtooltip Old\n/cast Frostbolt")
assert_eq(tipExisting, "#showtooltip Frostbolt\n/cast Frostbolt", "EnsureShowTooltip replaces existing tooltip line")

local tipMod = Snippets.DB:EnsureShowTooltip("/cast [mod:shift] Multi-Shot; Aimed Shot")
assert_eq(tipMod, "#showtooltip\n/cast [mod:shift] Multi-Shot; Aimed Shot", "EnsureShowTooltip is bare for mod/; multi-spell lines")

local tipBang = Snippets.DB:EnsureShowTooltip("/cast !Auto Shot")
assert_eq(tipBang, "#showtooltip Auto Shot\n/cast !Auto Shot", "EnsureShowTooltip strips leading ! from spell name")

local tipUseSlot = Snippets.DB:EnsureShowTooltip("/use 13\n/cast Bloodthirst")
assert_eq(tipUseSlot, "#showtooltip Bloodthirst\n/use 13\n/cast Bloodthirst", "EnsureShowTooltip skips numeric /use slots")

local tipRacialPrefix = Snippets.DB:EnsureShowTooltip("/cast Blood Fury\n/cast Bloodrage\n/cast Bloodthirst")
assert_eq(tipRacialPrefix, "#showtooltip Bloodthirst\n/cast Blood Fury\n/cast Bloodrage\n/cast Bloodthirst", "EnsureShowTooltip skips High off-GCD prefix casts")

local tipPom = Snippets.DB:EnsureShowTooltip("/cast Eureka!\n/cast Presence of Mind\n/cast Pyroblast")
assert_eq(tipPom, "#showtooltip Pyroblast\n/cast Eureka!\n/cast Presence of Mind\n/cast Pyroblast", "EnsureShowTooltip skips Eureka and Presence of Mind")

local tipOnlyPrefix = Snippets.DB:EnsureShowTooltip("/cast Blood Fury")
assert_eq(tipOnlyPrefix, "#showtooltip\n/cast Blood Fury", "EnsureShowTooltip is bare when only High prefix remains")

assert_true(Snippets.DB:IsHighOffGcdCast("Presence of Mind"), "PoM is High off-GCD")
assert_true(not Snippets.DB:IsHighOffGcdCast("Cold Blood"), "Cold Blood is not High (Unverified)")
assert_true(not Snippets.DB:IsHighOffGcdCast("Divine Favor"), "Divine Favor is not High (Unverified)")
assert_true(not Snippets.DB:IsHighOffGcdCast("Pyroblast"), "main CD is not High off-GCD")

-- FilterUnknownOffGcdCasts: drop High off-GCD /cast lines when spell is unknown.
local filterBody = "/use 13\n/use 14\n/cast Blood Fury\n/cast Presence of Mind\n/cast Pyroblast"
local knownNone = function(spell)
  return false
end
local filteredNone = Snippets.DB:FilterUnknownOffGcdCasts(filterBody, knownNone)
assert_eq(
  filteredNone,
  "/use 13\n/use 14\n/cast Pyroblast",
  "FilterUnknownOffGcdCasts drops unknown High off-GCD casts, keeps trinkets and main spell"
)

local knownPom = function(spell)
  return string.lower(spell) == "presence of mind"
end
local filteredPom = Snippets.DB:FilterUnknownOffGcdCasts(filterBody, knownPom)
assert_eq(
  filteredPom,
  "/use 13\n/use 14\n/cast Presence of Mind\n/cast Pyroblast",
  "FilterUnknownOffGcdCasts keeps known High off-GCD casts"
)

local knownAll = function()
  return true
end
assert_eq(
  Snippets.DB:FilterUnknownOffGcdCasts(filterBody, knownAll),
  filterBody,
  "FilterUnknownOffGcdCasts keeps all lines when every High cast is known"
)

local condLine = "/cast [@player] Inner Focus\n/cast Flash Heal"
assert_eq(
  Snippets.DB:FilterUnknownOffGcdCasts(condLine, knownNone),
  "/cast Flash Heal",
  "FilterUnknownOffGcdCasts strips High cast with conditionals when unknown"
)

local rawBurst = "{IF:ORC=/cast Blood Fury|GNOME=/cast Eureka!}\n/cast Presence of Mind\n/cast Pyroblast"
local afterIf = Snippets.DB:ExpandConditionals(rawBurst, "Orc")
local afterFilter = Snippets.DB:FilterUnknownOffGcdCasts(afterIf, knownNone)
local afterTip = Snippets.DB:EnsureShowTooltip(afterFilter)
assert_eq(
  afterTip,
  "#showtooltip Pyroblast\n/cast Pyroblast",
  "Expand pipeline drops unknown Blood Fury and PoM for Orc"
)

-- Curing templates from Data/*.lua (Shared required by class files).
dofile(addonRoot .. "/Data/SHARED.lua")
dofile(addonRoot .. "/Data/DRUID.lua")
dofile(addonRoot .. "/Data/MAGE.lua")
dofile(addonRoot .. "/Data/SHAMAN.lua")
dofile(addonRoot .. "/Data/PRIEST.lua")

local curingSnippets = {
  { "DRUID", "druid_cure_key" },
  { "MAGE", "mage_remove_curse_mo" },
  { "SHAMAN", "shaman_cure_key" },
  { "PRIEST", "priest_cure_disease_mo" },
}

for i = 1, #curingSnippets do
  local classFile, snippetId = curingSnippets[i][1], curingSnippets[i][2]
  local snippet = Snippets.DB:GetById(classFile, snippetId)
  assert_true(snippet ~= nil, "curing snippet registered: " .. snippetId)
  if snippet then
    assert_true(#snippet.name <= 16, snippetId .. " name within 16 chars")
    local expanded = Snippets.DB:EnsureShowTooltip(snippet.body)
    assert_true(
      #expanded <= 255,
      string.format("%s expanded body <= 255 (got %d)", snippetId, #expanded)
    )
    assert_true(
      snippet.body:find("@player", 1, true) ~= nil,
      snippetId .. " includes @player fallback"
    )
  end
end

local druidCure = Snippets.DB:GetById("DRUID", "druid_cure_key")
if druidCure then
  assert_true(druidCure.body:find("Remove Curse", 1, true) ~= nil, "druid cure has Remove Curse")
  assert_true(druidCure.body:find("Cure Poison", 1, true) ~= nil, "druid cure has Cure Poison")
  assert_true(druidCure.body:find("Abolish Poison", 1, true) ~= nil, "druid cure has Abolish Poison")
  assert_true(druidCure.body:find("/cancelform", 1, true) ~= nil, "druid cure cancels form")
end

local mageCure = Snippets.DB:GetById("MAGE", "mage_remove_curse_mo")
if mageCure then
  assert_true(
    mageCure.body:find("Remove Lesser Curse", 1, true) ~= nil,
    "mage uses Forever Remove Lesser Curse"
  )
end

if failures > 0 then
  print(string.format("\n%d test(s) failed", failures))
  os.exit(1)
end

print("\nAll tests passed")

