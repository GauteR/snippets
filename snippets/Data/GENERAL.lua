-- Shared macros registered for every class (trinkets / racial burst).
-- Pattern templates with SPELL_NAME stay in docs/MACROS.md.
-- Requires Data/SHARED.lua loaded first (see snippets.toc).
local S = Snippets.Shared
if type(S) ~= "table" or type(S.join) ~= "function" then
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99Snippets|r: SHARED.lua missing; general templates skipped.")
  end
  return
end

local CLASSES = {
  "WARRIOR",
  "PALADIN",
  "HUNTER",
  "ROGUE",
  "PRIEST",
  "SHAMAN",
  "MAGE",
  "WARLOCK",
  "DRUID",
}

local function registerAll(snippet)
  for i = 1, #CLASSES do
    Snippets.DB:Register(CLASSES[i], snippet)
  end
end

registerAll({
  id = "general_trinket_racial",
  name = "Trinket Racial",
  icon = "INV_Misc_QuestionMark",
  body = S.join(S.TRINKETS, S.RACIAL_BURST_IF),
  category = "general",
  note = "Trinkets + Orc/Troll/Gnome racial burst",
})
