-- Class-keyed snippet registry and pure helpers (safe to unit-test outside WoW).
Snippets = Snippets or {}
Snippets.DB = Snippets.DB or {}

local db = Snippets.DB
db.byClass = db.byClass or {}

local function normalizeToken(token)
  if type(token) ~= "string" or token == "" then
    return nil
  end
  token = string.match(token, "^%s*(.-)%s*$") or token
  if token == "" then
    return nil
  end
  return string.upper(token)
end

-- Register one snippet under a class file token (e.g. "WARRIOR").
function db:Register(classFile, snippet)
  if type(classFile) ~= "string" or classFile == "" then
    return
  end
  if type(snippet) ~= "table" or type(snippet.id) ~= "string" then
    return
  end

  local list = self.byClass[classFile]
  if not list then
    list = {}
    self.byClass[classFile] = list
  end

  list[#list + 1] = {
    id = snippet.id,
    name = snippet.name or snippet.id,
    icon = snippet.icon or "INV_Misc_QuestionMark",
    body = snippet.body or "",
    note = snippet.note or "",
  }
end

-- Return a copy of snippets for the given class file token.
function db:GetForClass(classFile)
  local source = self.byClass[classFile]
  if not source then
    return {}
  end

  local copy = {}
  for i = 1, #source do
    copy[i] = source[i]
  end
  return copy
end

-- Look up a single snippet by class and id.
function db:GetById(classFile, snippetId)
  local list = self.byClass[classFile]
  if not list then
    return nil
  end

  for i = 1, #list do
    if list[i].id == snippetId then
      return list[i]
    end
  end
  return nil
end

-- Resolve race conditionals in a template body.
-- Syntax: {IF:DWARF=/cast Stoneform|GNOME=/cast Escape Artist}
-- Matching race token (UnitRace file, uppercased) is substituted; no match removes the block.
-- Use \n inside a branch value for a line break.
function db:ExpandConditionals(body, raceFile)
  body = body or ""
  local raceKey = normalizeToken(raceFile) or ""

  local expanded = string.gsub(body, "{IF:([^{}]*)}", function(inner)
    local chosen = ""
    for branch in string.gmatch(inner .. "|", "([^|]*)|") do
      local raceToken, value = string.match(branch, "^%s*([^=]+)%s*=(.*)$")
      if raceToken and normalizeToken(raceToken) == raceKey then
        chosen = value or ""
        break
      end
    end
    chosen = string.gsub(chosen, "\\n", "\n")
    return chosen
  end)

  -- Remove blank lines left when a block expands to empty.
  expanded = string.gsub(expanded, "\n\n+", "\n")
  expanded = string.gsub(expanded, "^\n+", "")
  expanded = string.gsub(expanded, "\n+$", "")
  return expanded
end

-- Macro bodies are capped at 255 characters by the client.
function db:ClampBody(body)
  body = body or ""
  local maxLength = (Snippets.Config and Snippets.Config.MAX_BODY_LENGTH) or 255
  if #body <= maxLength then
    return body
  end
  return string.sub(body, 1, maxLength)
end

-- Build a free macro name within the 16-character UI limit.
-- existingNames is a set table: { ["Name"] = true, ... }
function db:MakeUniqueMacroName(desiredName, existingNames)
  existingNames = existingNames or {}
  local maxLength = (Snippets.Config and Snippets.Config.MAX_NAME_LENGTH) or 16
  local base = desiredName or "Snippet"
  if #base > maxLength then
    base = string.sub(base, 1, maxLength)
  end

  if not existingNames[base] then
    return base
  end

  local index = 2
  while true do
    local suffix = " " .. tostring(index)
    local room = maxLength - #suffix
    if room < 1 then
      room = 1
    end
    local truncatedBase = string.sub(base, 1, room)
    local candidate = truncatedBase .. suffix
    if not existingNames[candidate] then
      return candidate
    end
    index = index + 1
  end
end
