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

-- True when the player knows a spell by English Forever name (High off-GCD gating).
function Snippets:PlayerKnowsSpell(spellName)
  if type(spellName) ~= "string" or spellName == "" then
    return false
  end
  -- Without client APIs (unit tests), keep optional casts so fixtures stay stable.
  if type(GetSpellInfo) ~= "function" or type(IsSpellKnown) ~= "function" then
    return true
  end

  local _, _, _, _, _, _, spellId = GetSpellInfo(spellName)
  if not spellId then
    return false
  end
  if IsSpellKnown(spellId) then
    return true
  end
  if type(IsPlayerSpell) == "function" and IsPlayerSpell(spellId) then
    return true
  end
  return false
end

-- Expand {IF:...}, drop unknown High off-GCD casts, ensure #showtooltip.
function Snippets:ExpandBodyForPlayer(body)
  local expanded = self.DB:ExpandConditionals(body, self:GetPlayerRaceFile())
  expanded = self.DB:FilterUnknownOffGcdCasts(expanded, function(spell)
    return self:PlayerKnowsSpell(spell)
  end)
  return self.DB:EnsureShowTooltip(expanded)
end

-- SavedVariables bootstrap (Forever may omit load after cold start — re-seed on create/sync).
function Snippets:EnsureSavedVars()
  if type(SnippetsDB) ~= "table" then
    SnippetsDB = {}
  end
  if type(SnippetsDB.maintained) ~= "table" then
    SnippetsDB.maintained = {}
  end
  SnippetsDB.version = 1
  return SnippetsDB
end

function Snippets:IsMaintainEnabled()
  return self.Config and self.Config.MAINTAIN_ENABLED == true
end

function Snippets:RegisterMaintained(macroName, entry)
  if not self:IsMaintainEnabled() then
    return
  end
  if type(macroName) ~= "string" or macroName == "" or type(entry) ~= "table" then
    return
  end
  if type(entry.snippetId) ~= "string" or type(entry.classFile) ~= "string" then
    return
  end
  local db = self:EnsureSavedVars()
  db.maintained[macroName] = {
    snippetId = entry.snippetId,
    classFile = entry.classFile,
    perCharacter = entry.perCharacter and true or false,
  }
end

function Snippets:UnregisterMaintained(macroName)
  local db = self:EnsureSavedVars()
  if db.maintained then
    db.maintained[macroName] = nil
  end
end

-- Find macro slot by name in account or character range.
function Snippets:FindMacroIndexByName(macroName, perCharacter)
  if type(macroName) ~= "string" or macroName == "" then
    return nil
  end
  local globalCount, characterCount = GetNumMacros()
  globalCount = globalCount or 0
  characterCount = characterCount or 0

  if perCharacter then
    local characterOffset = MAX_ACCOUNT_MACROS or 120
    for index = characterOffset + 1, characterOffset + characterCount do
      local name = GetMacroInfo(index)
      if name == macroName then
        return index
      end
    end
  else
    for index = 1, globalCount do
      local name = GetMacroInfo(index)
      if name == macroName then
        return index
      end
    end
  end
  return nil
end

-- Re-expand one maintained macro from its raw template. Returns true when body changed.
function Snippets:MaintainOne(macroName, entry)
  if not self:IsMaintainEnabled() then
    return false
  end
  if InCombatLockdown and InCombatLockdown() then
    self._maintainPending = true
    return false
  end
  if type(macroName) ~= "string" or type(entry) ~= "table" then
    return false
  end

  local snippet = self.DB:GetById(entry.classFile, entry.snippetId)
  if not snippet then
    return false
  end

  local body = self:ExpandBodyForPlayer(snippet.body)
  local maxLength = (self.Config and self.Config.MAX_BODY_LENGTH) or 255
  if body == "" or #body > maxLength then
    return false
  end

  local index = self:FindMacroIndexByName(macroName, entry.perCharacter)
  if not index then
    -- Macro deleted or renamed — drop stale SavedVariables entry.
    self:UnregisterMaintained(macroName)
    return false
  end

  local _, _, currentBody = GetMacroInfo(index)
  if currentBody == body then
    return false
  end

  local icon = "INV_Misc_QuestionMark"
  local ok = pcall(EditMacro, index, macroName, icon, body)
  if not ok then
    Print(self:T("ERR_MAINTAIN_FAILED", macroName))
    return false
  end
  return true
end

function Snippets:MaintainAll()
  if not self:IsMaintainEnabled() then
    return
  end
  if InCombatLockdown and InCombatLockdown() then
    self._maintainPending = true
    return
  end

  self._maintainPending = false
  local db = self:EnsureSavedVars()
  -- Copy keys first so UnregisterMaintained during the loop is safe.
  local names = {}
  for macroName in pairs(db.maintained) do
    names[#names + 1] = macroName
  end
  for i = 1, #names do
    local macroName = names[i]
    local entry = db.maintained[macroName]
    if entry then
      self:MaintainOne(macroName, entry)
    end
  end
end

-- Create a Blizzard macro from a snippet table. Returns macroId or nil, errorMessage.
-- opts.maintain = true registers the macro for template re-sync (raw body only).
function Snippets:CreateMacroFromSnippet(snippet, opts)
  opts = opts or {}
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

  if opts.maintain and self:IsMaintainEnabled() and type(snippet.id) == "string" then
    self:RegisterMaintained(name, {
      snippetId = snippet.id,
      classFile = opts.classFile or self:GetPlayerClassFile(),
      perCharacter = self.Config.PER_CHARACTER and true or false,
    })
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
eventFrame:RegisterEvent("SPELLS_CHANGED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript("OnEvent", function(_, event)
  if not Snippets:IsEnabled() then
    return
  end

  if event == "PLAYER_LOGIN" then
    Snippets:EnsureSavedVars()

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

    Snippets:MaintainAll()
    --Print(Snippets:T("CHAT_LOADED"))
    return
  end

  if event == "SPELLS_CHANGED" then
    if not Snippets:IsMaintainEnabled() then
      return
    end
    -- Throttle bursty SPELLS_CHANGED (talent/trainer spam).
    local now = (type(GetTime) == "function" and GetTime()) or 0
    if Snippets._lastMaintainSpellTime and (now - Snippets._lastMaintainSpellTime) < 0.5 then
      Snippets._maintainPending = true
      return
    end
    Snippets._lastMaintainSpellTime = now
    Snippets:MaintainAll()
    return
  end

  if event == "PLAYER_REGEN_ENABLED" then
    if Snippets._maintainPending then
      Snippets:MaintainAll()
    end
  end
end)
