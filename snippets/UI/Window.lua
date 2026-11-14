-- Simple snippet browser: class-filtered list, preview, create macro.
Snippets = Snippets or {}
Snippets.UI = Snippets.UI or {}

local UI = Snippets.UI
local ROW_HEIGHT = 20
local VISIBLE_ROWS = 8
local LIST_HEIGHT = VISIBLE_ROWS * ROW_HEIGHT

function UI:Initialize()
  if self.frame then
    return
  end

  local frame = CreateFrame("Frame", "SnippetsFrame", UIParent, "BasicFrameTemplateWithInset")
  frame:SetSize(420, 420)
  frame:SetPoint("CENTER")
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  frame:Hide()
  tinsert(UISpecialFrames, "SnippetsFrame")

  frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  frame.title:SetPoint("TOP", 0, -5)
  frame.title:SetText("Snippets")

  frame.classLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.classLabel:SetPoint("TOPLEFT", 16, -32)
  frame.classLabel:SetText("Class / Race:")

  local pveButton = CreateFrame("Button", "SnippetsFilterPveButton", frame, "UIPanelButtonTemplate")
  pveButton:SetSize(60, 22)
  pveButton:SetPoint("TOPLEFT", 16, -52)
  pveButton:SetText("PvE")
  pveButton:SetScript("OnClick", function()
    UI:SetFilter("pve")
  end)

  local pvpButton = CreateFrame("Button", "SnippetsFilterPvpButton", frame, "UIPanelButtonTemplate")
  pvpButton:SetSize(60, 22)
  pvpButton:SetPoint("LEFT", pveButton, "RIGHT", 8, 0)
  pvpButton:SetText("PvP")
  pvpButton:SetScript("OnClick", function()
    UI:SetFilter("pvp")
  end)

  frame.listLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.listLabel:SetPoint("TOPLEFT", 16, -78)
  frame.listLabel:SetText("Snippets")

  -- Explicit list height so the preview pane keeps usable space for multiline bodies.
  local scrollFrame = CreateFrame("ScrollFrame", "SnippetsScrollFrame", frame, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", 16, -94)
  scrollFrame:SetPoint("TOPRIGHT", -36, -94)
  scrollFrame:SetHeight(LIST_HEIGHT)

  local content = CreateFrame("Frame", "SnippetsScrollChild", scrollFrame)
  content:SetSize(360, LIST_HEIGHT)
  scrollFrame:SetScrollChild(content)

  frame.previewLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.previewLabel:SetPoint("TOPLEFT", scrollFrame, "BOTTOMLEFT", 0, -12)
  frame.previewLabel:SetText("Preview (race conditionals expanded; editable)")

  local preview = CreateFrame("EditBox", "SnippetsPreviewBox", frame)
  preview:SetMultiLine(true)
  preview:SetFontObject(GameFontHighlightSmall)
  preview:SetPoint("TOPLEFT", frame.previewLabel, "BOTTOMLEFT", 0, -4)
  preview:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 48)
  preview:SetAutoFocus(false)
  preview:EnableMouse(true)
  preview:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
  end)
  preview:SetText("")

  local previewBg = frame:CreateTexture(nil, "BACKGROUND")
  previewBg:SetAllPoints(preview)
  previewBg:SetColorTexture(0, 0, 0, 0.35)

  local createButton = CreateFrame("Button", "SnippetsCreateButton", frame, "UIPanelButtonTemplate")
  createButton:SetSize(140, 24)
  createButton:SetPoint("BOTTOMLEFT", 16, 12)
  createButton:SetText("Create Macro")
  createButton:SetScript("OnClick", function()
    UI:CreateSelected()
  end)

  local closeButton = CreateFrame("Button", "SnippetsCloseButton", frame, "UIPanelButtonTemplate")
  closeButton:SetSize(80, 24)
  closeButton:SetPoint("BOTTOMRIGHT", -16, 12)
  closeButton:SetText("Close")
  closeButton:SetScript("OnClick", function()
    frame:Hide()
  end)

  frame.status = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.status:SetPoint("BOTTOMLEFT", createButton, "TOPLEFT", 0, 6)
  frame.status:SetPoint("RIGHT", closeButton, "LEFT", -8, 0)
  frame.status:SetJustifyH("LEFT")
  frame.status:SetText("")

  self.frame = frame
  self.scrollFrame = scrollFrame
  self.content = content
  self.preview = preview
  self.pveButton = pveButton
  self.pvpButton = pvpButton
  self.rows = {}
  self.selectedIndex = nil
  self.snippets = {}
  local defaultFilter = (Snippets.Config and Snippets.Config.DEFAULT_FILTER) or "pve"
  if defaultFilter ~= "pve" and defaultFilter ~= "pvp" then
    defaultFilter = "pve"
  end
  self.filterMode = defaultFilter

  frame:SetScript("OnShow", function()
    UI:Refresh()
  end)
end

function UI:SetFilter(filterMode)
  if filterMode ~= "pve" and filterMode ~= "pvp" then
    filterMode = "pve"
  end
  self.filterMode = filterMode
  self:Refresh()
end

function UI:UpdateFilterButtons()
  if not self.pveButton or not self.pvpButton then
    return
  end
  -- Dim the inactive filter so the active mode is obvious.
  if self.filterMode == "pvp" then
    self.pvpButton:SetAlpha(1)
    self.pveButton:SetAlpha(0.55)
  else
    self.pveButton:SetAlpha(1)
    self.pvpButton:SetAlpha(0.55)
  end
end

function UI:SetStatus(message)
  if self.frame and self.frame.status then
    self.frame.status:SetText(message or "")
  end
end

function UI:SelectIndex(index)
  self.selectedIndex = index
  local snippet = self.snippets[index]
  if snippet and self.preview then
    -- Show the body after {IF:...} expansion for the current character race.
    self.preview:SetText(Snippets:ExpandBodyForPlayer(snippet.body or ""))
  elseif self.preview then
    self.preview:SetText("")
  end

  for i, row in ipairs(self.rows) do
    if i == index then
      row:LockHighlight()
    else
      row:UnlockHighlight()
    end
  end
end

function UI:EnsureRows(count)
  while #self.rows < count do
    local index = #self.rows + 1
    local row = CreateFrame("Button", "SnippetsRow" .. index, self.content)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("LEFT", 0, 0)
    row:SetPoint("RIGHT", 0, 0)
    if index == 1 then
      row:SetPoint("TOP", 0, 0)
    else
      row:SetPoint("TOP", self.rows[index - 1], "BOTTOM", 0, 0)
    end

    row:SetNormalFontObject(GameFontHighlightSmall)
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.text:SetPoint("LEFT", 4, 0)
    row.text:SetPoint("RIGHT", -4, 0)
    row.text:SetJustifyH("LEFT")

    row:SetScript("OnClick", function()
      UI:SelectIndex(index)
    end)

    self.rows[index] = row
  end
end

function UI:Refresh()
  if not self.frame then
    return
  end

  local classFile = Snippets:GetPlayerClassFile()
  local raceFile = Snippets:GetPlayerRaceFile()
  self.frame.classLabel:SetText(
    string.format("Class / Race: %s / %s", classFile or "UNKNOWN", raceFile or "UNKNOWN")
  )
  self.filterMode = self.filterMode or "pve"
  self:UpdateFilterButtons()
  self.snippets = Snippets:GetSnippetsForPlayer(self.filterMode)
  self:EnsureRows(#self.snippets)

  for i, row in ipairs(self.rows) do
    local snippet = self.snippets[i]
    if snippet then
      row.text:SetText(snippet.name)
      row:Show()
    else
      row:Hide()
    end
  end

  local height = math.max(#self.snippets, 1) * ROW_HEIGHT
  self.content:SetHeight(height)

  if #self.snippets == 0 then
    self:SelectIndex(nil)
    self.preview:SetText("")
    self:SetStatus("No snippets registered for this class.")
  else
    self:SelectIndex(1)
    self:SetStatus(#self.snippets .. " snippet(s) available.")
  end
end

function UI:CreateSelected()
  local snippet = self.snippets[self.selectedIndex]
  if not snippet then
    self:SetStatus("Select a snippet first.")
    return
  end

  -- Create from the preview text so edits in the UI are applied.
  local draft = {
    id = snippet.id,
    name = snippet.name,
    icon = snippet.icon,
    body = self.preview and self.preview:GetText() or snippet.body,
    note = snippet.note,
  }

  local macroId, err, name = Snippets:CreateMacroFromSnippet(draft)
  if not macroId then
    self:SetStatus(err or "Failed to create macro.")
    return
  end

  self:SetStatus("Created macro: " .. (name or snippet.name))
end

function UI:Toggle()
  self:Initialize()
  if self.frame:IsShown() then
    self.frame:Hide()
  else
    self.frame:Show()
  end
end
