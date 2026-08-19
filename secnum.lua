-- secnum.lua: automatic section numbering + resolved {.secref} links.
--
-- Headings in the source carry no number (e.g. "## Hardware background
-- {#hardware-background-why-this-is-hard}"). This filter:
--   1. computes "1", "9.1", etc. from heading nesting (level 2 = major,
--      level 3 = minor) and prepends it to the heading's rendered text
--   2. resolves every `[](#id){.secref}` link left by convert_secrefs.py
--      into a real, clickable link reading "§<live number>"
--
-- Runs as two full-document passes (returned as a list): the first must
-- finish building the identifier -> number table before the second
-- resolves links, since a §-reference can point at a heading that comes
-- later in the document.

local sec_numbers = {}   -- identifier -> "9.1"

local level2 = 0
local level3 = 0
local level4 = 0

local AssignNumbers = {
  Header = function(el)
    local num
    if el.level == 2 then
      level2 = level2 + 1
      level3 = 0
      level4 = 0
      num = tostring(level2)
    elseif el.level == 3 then
      level3 = level3 + 1
      level4 = 0
      num = string.format("%d.%d", level2, level3)
    elseif el.level == 4 then
      level4 = level4 + 1
      num = string.format("%d.%d.%d", level2, level3, level4)
    else
      return nil
    end
    sec_numbers[el.identifier] = num
    table.insert(el.content, 1, pandoc.Space())
    table.insert(el.content, 1, pandoc.Str(num))
    return el
  end
}

local ResolveSecrefs = {
  Link = function(el)
    if not el.classes:includes("secref") then
      return nil
    end
    local id = el.target:gsub("^#", "")
    local num = sec_numbers[id]
    if not num then
      io.stderr:write("secnum.lua: WARNING unresolved secref target #" .. id .. "\n")
      num = "?"
    end
    el.content = {pandoc.Str("§" .. num)}
    return el
  end
}

return {AssignNumbers, ResolveSecrefs}
