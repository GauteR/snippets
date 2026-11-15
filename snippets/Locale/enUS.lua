-- English (enUS) UI strings. Spell names in Data/*.lua stay as Forever client names.
Snippets = Snippets or {}
local L = {}
Snippets.L = L

L.ADDON_NAME = "Snippets"
L.CHAT_PREFIX = "|cff33ff99Snippets|r: "

L.WINDOW_TITLE = "Snippets"
L.CLASS_RACE_LABEL = "Class / Race:"
L.CLASS_RACE_FMT = "Class / Race: %s / %s"
L.UNKNOWN = "UNKNOWN"
L.LIST_LABEL = "Snippets"
L.FILTER_PVE = "PvE"
L.FILTER_PVP = "PvP"
L.PREVIEW_LABEL = "Preview"
L.CREATE_MACRO = "Create Macro"
L.MAINTAIN_LABEL = "Maintain (re-sync from template)"

L.STATUS_NO_SNIPPETS = "No snippets registered for this class."
L.STATUS_SNIPPETS_AVAILABLE_FMT = "%d snippet(s) available."
L.STATUS_SELECT_FIRST = "Select a snippet first."
L.STATUS_CREATE_FAILED = "Failed to create macro."
L.STATUS_CREATED_FMT = "Created macro: %s"
L.STATUS_CREATED_MAINTAIN_FMT = "Created maintained macro: %s"

L.ERR_IN_COMBAT = "Cannot create macros while in combat."
L.ERR_NO_SNIPPET = "No snippet selected."
L.ERR_EMPTY_BODY = "Snippet body is empty."
L.ERR_CREATE_FAILED = "CreateMacro failed."
L.ERR_SLOTS_FULL = "Macro slots may be full."
L.ERR_BODY_TOO_LONG = "Macro body exceeds %d characters (including #showtooltip)."
L.ERR_MAINTAIN_FAILED = "Failed to update maintained macro: %s"


L.CHAT_DISABLED = "Addon is disabled."
L.CHAT_LOADED = "Loaded. Type /snippets to open the snippet browser."

L.OPTIONS_VERSION_FMT = "Version %s"
L.OPTIONS_HELP =
  "Browse class macro templates with /snippets, filter PvE or PvP, hover for descriptions, then Create Macro."
L.OPTIONS_OPEN = "Open Snippets"

-- Resolve a locale key; optional format args.
function Snippets:T(key, ...)
  local text = (self.L and self.L[key]) or key
  if select("#", ...) > 0 then
    return string.format(text, ...)
  end
  return text
end
