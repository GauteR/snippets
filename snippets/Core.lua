-- Addon bootstrap: slash command, class detection, and macro creation.
Snippets = Snippets or {}

local function Print(message)
  if DEFAULT_CHAT_FRAME then
    local prefix = (Snippets.L and Snippets.L.CHAT_PREFIX) or "|cff33ff99Snippets|r: "
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. message)
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

-- Expand {IF:...} race conditionals and ensure #showtooltip for the logged-in character.
function Snippets:ExpandBodyForPlayer(body)
  local expanded = self.DB:ExpandConditionals(body, self:GetPlayerRaceFile())
  return self.DB:EnsureShowTooltip(expanded)
end

-- Create a Blizzard macro from a snippet table. Returns macroId or nil, errorMessage.
function Snippets:CreateMacroFromSnippet(snippet)
  if InCombatLockdown and InCombatLockdown() then
    return nil, self:T("ERR_IN_COMBAT")
  end
  if type(snippet) ~= "table" then
    return nil, self:T("ERR_NO_SNIPPET")
  end

  -- Preview text may already be expanded; ExpandConditionals is idempotent without {IF:} blocks.
  local body = self:ExpandBodyForPlayer(snippet.body)
  if body == "" then
    return nil, self:T("ERR_EMPTY_BODY")
  end
  local maxLength = (self.Config and self.Config.MAX_BODY_LENGTH) or 255
  if #body > maxLength then
    return nil, self:T("ERR_BODY_TOO_LONG", maxLength)
  end

  local existing = self:CollectExistingMacroNames()
  local name = self.DB:MakeUniqueMacroName(snippet.name, existing)
  -- Question-mark icon so the action bar follows #showtooltip / cast.
  local icon = "INV_Misc_QuestionMark"
  local perCharacter = self.Config.PER_CHARACTER and true or nil

  local ok, macroId = pcall(CreateMacro, name, icon, body, perCharacter)
  if not ok then
    return nil, self:T("ERR_CREATE_FAILED")
  end
  if not macroId then
    return nil, self:T("ERR_SLOTS_FULL")
  end

  return macroId, nil, name
end


-- Open the Blizzard macro UI, preferring the character tab when PER_CHARACTER is on.
function Snippets:OpenMacroFrame(macroId)
  if InCombatLockdown and InCombatLockdown() then
    return
  end

  -- Load/show MacroFrame (Forever / Retail-style load-on-demand UI).
  if type(ShowMacroFrame) == "function" then
    pcall(ShowMacroFrame)
  else
    if type(MacroFrame_LoadUI) == "function" then
      pcall(MacroFrame_LoadUI)
    end
    if type(MacroFrame_Show) == "function" then
      pcall(MacroFrame_Show)
    elseif MacroFrame and type(ShowUIPanel) == "function" then
      pcall(ShowUIPanel, MacroFrame)
    end
  end

  if not MacroFrame then
    return
  end

  local preferCharacter = self.Config and self.Config.PER_CHARACTER
  if preferCharacter then
    -- Tab 2 = character-specific macros on Blizzard MacroFrame.
    if type(MacroFrame.ChangeTab) == "function" then
      pcall(function()
        MacroFrame:ChangeTab(2)
      end)
    elseif type(PanelTemplates_SetTab) == "function" then
      pcall(PanelTemplates_SetTab, MacroFrame, 2)
      if type(MacroFrame_SetCharacterMacros) == "function" then
        pcall(MacroFrame_SetCharacterMacros)
      end
    elseif MacroFrameTab2 and type(MacroFrameTab2.Click) == "function" then
      pcall(function()
        MacroFrameTab2:Click()
      end)
    end
  end

  if macroId then
    if type(MacroFrame_SelectMacro) == "function" then
      pcall(MacroFrame_SelectMacro, macroId)
    elseif type(MacroFrame.SelectMacro) == "function" then
      pcall(function()
        MacroFrame:SelectMacro(macroId, true)
      end)
    end
    if type(MacroFrame_Update) == "function" then
      pcall(MacroFrame_Update)
    elseif type(MacroFrame.Update) == "function" then
      pcall(function()
        MacroFrame:Update()
      end)
    end
  end
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

function Snippets:GetSnippetsForPlayer(filterMode)
  return self.DB:GetForClassAndFilter(self:GetPlayerClassFile(), filterMode)
end

function Snippets:IsEnabled()
  return self.Config and self.Config.ENABLED == true
end

function Snippets:ToggleWindow()
  if not self:IsEnabled() then
    Print(self:T("CHAT_DISABLED"))
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

  if Snippets.Options and Snippets.Options.Initialize then
    Snippets.Options:Initialize()
  end

  Print(Snippets:T("CHAT_LOADED"))
end)

