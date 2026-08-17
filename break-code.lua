-- Soft-wrap long lines inside fenced code blocks
local MAX_COL = 100

-- Length/substring helpers counting UTF-8 codepoints, not bytes, so
-- multi-byte characters (e.g. "§", "—") don't distort the column count
-- and trigger spurious wraps that break hand-aligned ASCII art.
local function ulen(s)
  return utf8.len(s) or #s
end

local function usub(s, i, j)
  local chars = {}
  local n = 0
  for _, cp in utf8.codes(s) do
    n = n + 1
    if n >= i and (not j or n <= j) then
      chars[#chars + 1] = utf8.char(cp)
    end
  end
  return table.concat(chars)
end

local function wrap_line(line)
  if ulen(line) <= MAX_COL then
    return line
  end
  local indent = ulen(line:match("^(%s*)"))
  local cont_prefix = string.rep(" ", indent + 4)
  local parts = {}

  for _ = 1, 5 do
    if ulen(line) <= MAX_COL then
      break
    end
    -- Search backward for a space that follows a non-space character
    local cut = nil
    for i = MAX_COL, indent + 1, -1 do
      if usub(line, i, i) == " " and i > 1 and usub(line, i - 1, i - 1) ~= " " then
        cut = i
        break
      end
    end
    if not cut then
      break  -- no good break point, emit as-is
    end
    parts[#parts + 1] = usub(line, 1, cut - 1)
    local rest = usub(line, cut + 1):gsub("^%s+", "")
    if rest == "" then
      line = ""
      break
    end
    line = cont_prefix .. rest
  end

  if ulen(line) > 0 then
    parts[#parts + 1] = line
  end
  return table.concat(parts, "\n")
end

function CodeBlock(elem)
  local lines = {}
  for line in (elem.text .. "\n"):gmatch("(.-)\n") do
    lines[#lines + 1] = wrap_line(line)
  end
  elem.text = table.concat(lines, "\n")
  return elem
end
