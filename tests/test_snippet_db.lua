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

if failures > 0 then
  print(string.format("\n%d test(s) failed", failures))
  os.exit(1)
end

print("\nAll tests passed")
