
-- remove trailing newline if any
local function chomp(x)
  return (string.gsub(x, "\r?\n$", ""))
end

-- returns nil if x consists of one line (no newline)
-- otherwise returns a,b where a is the first line and b is the rest
local function line(x)
  i = string.find(x, "\r?\n", 1)
  if i then
    return chomp(string.sub(x, 1, i)), string.sub(x, i+1, -1)
  else
    return nil
  end
end

-- used to produce lines from the input stream
function mk_input_buffer()
  local buffer = ""
  return function(input)
    buffer = buffer .. input
    -- check for line
    l, rest = line(buffer)
    if l then -- a line is complete
      buffer = rest
      return l
    else
      return nil
    end
  end
end
