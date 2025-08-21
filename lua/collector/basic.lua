local BB = {}

function BB.crapHash(cardName)
  -- local sep = "\\."
  -- local letters = {}
  --  if sep == nil then
  --     sep = "%s"
  --  end
  --  local t={}
  --  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
  --     table.insert(t, str)
  --  end
  --  return t

  local letters = {}
  for i = 1, #cardName do
    letters[i] = string.byte(cardName:sub(i, i))
  end

  return "."..table.concat(letters, "")
end

function BB.cleanUnicodeWeirdness(str)
  local replaced = {}
  -- local current_match = ""
  -- current_match = string.gmatch(str, "—")
  str = string.gsub(str, "—", "-")

  return str
end

function BB.tableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function BB.split(input, delimiter)
    if delimiter == nil then
        delimiter = "%s"  -- Default to whitespace
    end
    local result = {}
    for match in (input .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

function BB.removeBlanks(str)
  str = string.gsub(str, "%s+", "")
  return str
end

function BB.trimr(str)
  -- [%s%S]+
  return string.gsub(str, "%s+$", "", 1)
end

function BB.trim(s)
  local l = 1
  while strsub(s,l,l) == ' ' do
    l = l+1
  end
  local r = strlen(s)
  while strsub(s,r,r) == ' ' do
    r = r-1
  end
  return strsub(s,l,r)
end

return BB
