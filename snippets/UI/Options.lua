-- Options → AddOns → Snippets: about panel with open-window action.
Snippets = Snippets or {}
Snippets.Options = Snippets.Options or {}

local Options = Snippets.Options
local ADDON_FOLDER = "snippets"

local function GetMeta(field, fallback)
  local value
  if C_AddOns and C_AddOns.GetAddOnMetadata then
    value = C_AddOns.GetAddOnMetadata(ADDON_FOLDER, field)
  elseif GetAddOnMetadata then
    value = GetAddOnMetadata(ADDON_FOLDER, field)
  end
  if value == nil or value == "" then
    return fallback
  end
  return value
end

-- TOC keeps ## Version: @project-version@ for packager; show Config.VERSION until substituted.
local function GetDisplayVersion()
  local meta = GetMeta("Version", nil)
  if meta and not string.find(meta, "@", 1, true) then
    return meta
  end
  if Snippets.Config and Snippets.Config.VERSION then
    return Snippets.Config.VERSION
  end
  return "?"
end


function Options:Initialize()
  if self.registered then
    return
  end
  if not Settings or not Settings.RegisterCanvasLayoutCategory then
    return
  end

  local panel = CreateFrame("Frame", "SnippetsOptionsPanel")
  panel.name = GetMeta("Title", Snippets:T("ADDON_NAME"))
  panel:Hide()

  -- Required by the Settings canvas layout even when unused.
  function panel:OnCommit()
  end
  function panel:OnDefault()
  end
  function panel:OnRefresh()
  end

  local icon = panel:CreateTexture(nil, "ARTWORK")
  icon:SetSize(48, 48)
  icon:SetPoint("TOPLEFT", 16, -16)
  icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")

  local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("LEFT", icon, "RIGHT", 12, 8)
  title:SetText(panel.name)

  local version = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  version:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
  version:SetText(Snippets:T("OPTIONS_VERSION_FMT", GetDisplayVersion()))


  local help = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  help:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -20)
  help:SetWidth(520)
  help:SetJustifyH("LEFT")
  help:SetJustifyV("TOP")
  help:SetWordWrap(true)
  help:SetText(Snippets:T("OPTIONS_HELP"))

  local openButton = CreateFrame("Button", "SnippetsOptionsOpenButton", panel, "UIPanelButtonTemplate")
  openButton:SetSize(160, 24)
  openButton:SetPoint("TOPLEFT", help, "BOTTOMLEFT", 0, -24)
  openButton:SetText(Snippets:T("OPTIONS_OPEN"))
  openButton:SetScript("OnClick", function()
    if SettingsPanel and HideUIPanel then
      HideUIPanel(SettingsPanel)
    end
    Snippets:ToggleWindow()
  end)

  local ok, category = pcall(Settings.RegisterCanvasLayoutCategory, panel, panel.name)
  if not ok or not category then
    return
  end
  category.ID = panel.name
  local registeredOk = pcall(Settings.RegisterAddOnCategory, category)
  if not registeredOk then
    return
  end

  self.panel = panel
  self.category = category
  self.registered = true
end
