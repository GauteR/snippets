-- Addon bootstrap: slash command, class detection, and macro creation.
Snippets = Snippets or {}

local ADDON_PRINT_PREFIX = "|cff33ff99Snippets|r: "

local function Print(message)
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage(ADDON_PRINT_PREFIX .. message)
  end
end

-- Collect existing macro names into a set for uniqueness checks.
-- Account macros occupy slots 1..N; character macros occupy 121..(120+M).
function Snippets:CollectExistingMacroNames()
  local names = {}
  local globalCount, characterCount = GetNumMacros()
  globalCount = globalCount or 0
  characterCount = characterCount or 0

  for index = 1, globalCount do
    local name = GetMacroInfo(index)
    if name then
      names[name] = true
    end
  end

  local characterOffset = MAX_ACCOUNT_MACROS or 120
  for index = characterOffset + 1, characterOffset + characterCount do
    local name = GetMacroInfo(index)
    if name then
      names[name] = true
    end
  end

  return names
end

-- Expand {IF:...} race conditionals for the logged-in character.
function Snippets:ExpandBodyForPlayer(body)
  return self.DB:ExpandConditionals(body, self:GetPlayerRaceFile())
end

-- Create a Blizzard macro from a snippet table. Returns macroId or nil, errorMessage.
function Snippets:CreateMacroFromSnippet(snippet)
  if InCombatLockdown and InCombatLockdown() then
    return nil, "Cannot create macros while in combat."
  end
  if type(snippet) ~= "table" then
    return nil, "No snippet selected."
  end

  -- Preview text may already be expanded; ExpandConditionals is idempotent without {IF:} blocks.
  local body = self:ExpandBodyForPlayer(snippet.body)
  body = self.DB:ClampBody(body)
  if body == "" then
    return nil, "Snippet body is empty."
  end

  local existing = self:CollectExistingMacroNames()
  local name = self.DB:MakeUniqueMacroName(snippet.name, existing)
  local icon = snippet.icon or "INV_Misc_QuestionMark"
  local perCharacter = self.Config.PER_CHARACTER and true or nil

  local ok, macroId = pcall(CreateMacro, name, icon, body, perCharacter)
  if not ok then
    return nil, "CreateMacro failed."
  end
  if not macroId then
    return nil, "Macro slots may be full."
  end

  return macroId, nil, name
end

function Snippets:GetPlayerClassFile()
  local _, classFile = UnitClass("player")
  return classFile
end

-- Race file token from UnitRace (Undead characters return "Scourge").
function Snippets:GetPlayerRaceFile()
  local _, raceFile = UnitRace("player")
  return raceFile
end

function Snippets:GetSnippetsForPlayer()
  return self.DB:GetForClass(self:GetPlayerClassFile())
end

function Snippets:IsEnabled()
  return self.Config and self.Config.ENABLED == true
end

function Snippets:ToggleWindow()
  if not self:IsEnabled() then
    Print("Addon is disabled (Snippets.Config.ENABLED = false).")
    return
  end
  if self.UI and self.UI.Toggle then
    self.UI:Toggle()
  end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(_, event)
  if event ~= "PLAYER_LOGIN" then
    return
  end
  if not Snippets:IsEnabled() then
    return
  end

  SLASH_SNIPPETS1 = (Snippets.Config and Snippets.Config.SLASH_COMMAND) or "/snippets"
  SlashCmdList["SNIPPETS"] = function()
    Snippets:ToggleWindow()
  end

  if Snippets.UI and Snippets.UI.Initialize then
    Snippets.UI:Initialize()
  end

  Print("Loaded. Type /snippets to open the snippet browser.")
end)
