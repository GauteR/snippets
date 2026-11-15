-- Simple snippet browser: class-filtered list, preview, create macro.
Snippets = Snippets or {}
Snippets.UI = Snippets.UI or {}

local UI = Snippets.UI
local ROW_HEIGHT = 20
local VISIBLE_ROWS = 8
local LIST_HEIGHT = VISIBLE_ROWS * ROW_HEIGHT

-- Dark inset panel so list/preview contrast against BasicFrameTemplateWithInset.
local function CreateContrastPanel(name, parent)
  local ok, panel = pcall(CreateFrame, "Frame", name, parent, "BackdropTemplate")
  if not ok or not panel then
    panel = CreateFrame("Frame", name, parent)
  end
  if panel.SetBackdrop then
    panel:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      edgeSize = 12,
      insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    panel:SetBackdropColor(0.05, 0.06, 0.09, 0.92)
    panel:SetBackdropBorderColor(0.45, 0.45, 0.5, 0.95)
  else
    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.05, 0.06, 0.09, 0.92)
  end
  return panel
end


function UI:Initialize()
  if self.frame then
    return
  end

  local frame = CreateFrame("Frame", "SnippetsFrame", UIParent, "BasicFrameTemplateWithInset")
  frame:SetSize(420, 448)
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
  frame.title:SetText(Snippets:T("WINDOW_TITLE"))

  frame.classLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.classLabel:SetPoint("TOPLEFT", 16, -32)
  frame.classLabel:SetText(Snippets:T("CLASS_RACE_LABEL"))

  local pveButton = CreateFrame("Button", "SnippetsFilterPveButton", frame, "UIPanelButtonTemplate")
  pveButton:SetSize(60, 22)
  pveButton:SetPoint("TOPLEFT", 16, -52)
  pveButton:SetText(Snippets:T("FILTER_PVE"))
  pveButton:SetScript("OnClick", function()
    UI:SetFilter("pve")
  end)

  local pvpButton = CreateFrame("Button", "SnippetsFilterPvpButton", frame, "UIPanelButtonTemplate")
  pvpButton:SetSize(60, 22)
  pvpButton:SetPoint("LEFT", pveButton, "RIGHT", 8, 0)
  pvpButton:SetText(Snippets:T("FILTER_PVP"))
  pvpButton:SetScript("OnClick", function()
    UI:SetFilter("pvp")
  end)

  frame.listLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.listLabel:SetPoint("TOPLEFT", 16, -78)
  frame.listLabel:SetText(Snippets:T("LIST_LABEL"))


  local listPanel = CreateContrastPanel("SnippetsListPanel", frame)
  listPanel:SetPoint("TOPLEFT", 12, -90)
  listPanel:SetPoint("TOPRIGHT", -12, -90)
  listPanel:SetHeight(LIST_HEIGHT + 12)

  -- Explicit list height so the preview pane keeps usable space for multiline bodies.
  local scrollFrame = CreateFrame("ScrollFrame", "SnippetsScrollFrame", listPanel, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", 8, -6)
  scrollFrame:SetPoint("BOTTOMRIGHT", -28, 6)

  local content = CreateFrame("Frame", "SnippetsScrollChild", scrollFrame)
  content:SetSize(360, LIST_HEIGHT)
  scrollFrame:SetScrollChild(content)

  frame.previewLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.previewLabel:SetPoint("TOPLEFT", listPanel, "BOTTOMLEFT", 4, -10)
  frame.previewLabel:SetText(Snippets:T("PREVIEW_LABEL"))


  local createButton = CreateFrame("Button", "SnippetsCreateButton", frame, "UIPanelButtonTemplate")
  createButton:SetSize(140, 24)
  createButton:SetPoint("BOTTOMLEFT", 16, 12)
  createButton:SetText(Snippets:T("CREATE_MACRO"))
  createButton:SetScript("OnClick", function()
    UI:CreateSelected()
  end)

  -- Maintain: re-sync from template; only when preview matches expanded mal.
  local maintainCheck = CreateFrame("CheckButton", "SnippetsMaintainCheck", frame, "UICheckButtonTemplate")
  maintainCheck:SetPoint("BOTTOMLEFT", createButton, "TOPLEFT", -4, 6)
  maintainCheck:SetSize(24, 24)
  maintainCheck:SetChecked(false)
  maintainCheck:SetScript("OnClick", function(self)
    if not self:IsEnabled() then
      self:SetChecked(false)
    end
  end)
  local maintainLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  maintainLabel:SetPoint("LEFT", maintainCheck, "RIGHT", 2, 0)
  maintainLabel:SetText(Snippets:T("MAINTAIN_LABEL"))

  -- Status sits on the footer row next to Create Macro (not under the preview panel).
  frame.status = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.status:SetPoint("LEFT", createButton, "RIGHT", 12, 0)
  frame.status:SetPoint("RIGHT", frame, "RIGHT", -16, 0)
  frame.status:SetJustifyH("LEFT")
  frame.status:SetText("")

  local previewPanel = CreateContrastPanel("SnippetsPreviewPanel", frame)
  previewPanel:SetPoint("TOPLEFT", frame.previewLabel, "BOTTOMLEFT", -4, -4)
  -- Leave clear space for Maintain checkbox + footer button + status row.
  previewPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 72)

  local preview = CreateFrame("EditBox", "SnippetsPreviewBox", previewPanel)
  preview:SetMultiLine(true)
  preview:SetFontObject(GameFontHighlightSmall)
  preview:SetPoint("TOPLEFT", 8, -8)
  preview:SetPoint("BOTTOMRIGHT", -8, 8)
  preview:SetAutoFocus(false)
  preview:EnableMouse(true)
  preview:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
  end)
  preview:SetScript("OnTextChanged", function()
    UI:UpdateMaintainAvailability()
  end)
  preview:SetText("")


  self.frame = frame
  self.scrollFrame = scrollFrame
  self.content = content
  self.preview = preview
  self.maintainCheck = maintainCheck
  self.maintainLabel = maintainLabel
  self.pveButton = pveButton
  self.pvpButton = pvpButton
  self.rows = {}
  self.selectedIndex = nil
  self.snippets = {}
  self.canonicalPreview = ""
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
    local expanded = Snippets:ExpandBodyForPlayer(snippet.body or "")
    self.canonicalPreview = expanded
    self.preview:SetText(expanded)
  elseif self.preview then
    self.canonicalPreview = ""
    self.preview:SetText("")
  end

  for i, row in ipairs(self.rows) do
    if i == index then
      row:LockHighlight()
    else
      row:UnlockHighlight()
    end
  end

  self:UpdateMaintainAvailability()
end

-- Maintain is only available when preview matches the expanded template (no manual edits).
function UI:UpdateMaintainAvailability()
  if not self.maintainCheck then
    return
  end

  local maintainFeature = Snippets:IsMaintainEnabled and Snippets:IsMaintainEnabled()
  if not maintainFeature then
    self.maintainCheck:SetChecked(false)
    self.maintainCheck:Disable()
    self.maintainCheck:SetAlpha(0.4)
    return
  end

  local previewText = self.preview and self.preview:GetText() or ""
  local matchesCanonical = previewText == (self.canonicalPreview or "")
  if matchesCanonical and self.selectedIndex and self.snippets[self.selectedIndex] then
    self.maintainCheck:Enable()
    self.maintainCheck:SetAlpha(1)
  else
    self.maintainCheck:SetChecked(false)
    self.maintainCheck:Disable()
    self.maintainCheck:SetAlpha(0.4)
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
    Snippets:T("CLASS_RACE_FMT", classFile or Snippets:T("UNKNOWN"), raceFile or Snippets:T("UNKNOWN"))
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
    self:SetStatus(Snippets:T("STATUS_NO_SNIPPETS"))
  else
    self:SelectIndex(1)
    self:SetStatus(Snippets:T("STATUS_SNIPPETS_AVAILABLE_FMT", #self.snippets))
  end
end

function UI:CreateSelected()
  local snippet = self.snippets[self.selectedIndex]
  if not snippet then
    self:SetStatus(Snippets:T("STATUS_SELECT_FIRST"))
    return
  end

  self:UpdateMaintainAvailability()
  local wantMaintain = self.maintainCheck
    and self.maintainCheck:IsEnabled()
    and self.maintainCheck:GetChecked()
  wantMaintain = wantMaintain and Snippets:IsMaintainEnabled()

  local draft
  local opts = {}
  if wantMaintain then
    -- Maintain always syncs from the raw template; ignore preview edits.
    draft = {
      id = snippet.id,
      name = snippet.name,
      icon = snippet.icon,
      body = snippet.body,
      note = snippet.note,
    }
    opts.maintain = true
    opts.classFile = Snippets:GetPlayerClassFile()
  else
    -- Create from the preview text so edits in the UI are applied.
    draft = {
      id = snippet.id,
      name = snippet.name,
      icon = snippet.icon,
      body = self.preview and self.preview:GetText() or snippet.body,
      note = snippet.note,
    }
  end

  local macroId, err, name = Snippets:CreateMacroFromSnippet(draft, opts)
  if not macroId then
    self:SetStatus(err or Snippets:T("STATUS_CREATE_FAILED"))
    return
  end

  if wantMaintain then
    self:SetStatus(Snippets:T("STATUS_CREATED_MAINTAIN_FMT", name or snippet.name))
  else
    self:SetStatus(Snippets:T("STATUS_CREATED_FMT", name or snippet.name))
  end
  Snippets:OpenMacroFrame(macroId)
end

function UI:Toggle()
  self:Initialize()
  if self.frame:IsShown() then
    self.frame:Hide()
  else
    self.frame:Show()
  end
end
