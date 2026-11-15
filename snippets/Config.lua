-- Feature flag and shared addon settings for WoW Forever.
Snippets = Snippets or {}

Snippets.Config = {
  -- Set to false to disable slash command and UI without removing the addon.
  ENABLED = true,
  -- true = character macros; false = general account macros.
  PER_CHARACTER = true,
  MAX_BODY_LENGTH = 255,
  MAX_NAME_LENGTH = 16,
  ADDON_NAME = "Snippets",
  -- Shown in Options when TOC ## Version: @project-version@ is not packaged yet.
  VERSION = "1.1.0",
  SLASH_COMMAND = "/snippets",
  -- Active list filter on login: "pve" or "pvp".
  DEFAULT_FILTER = "pve",
}

