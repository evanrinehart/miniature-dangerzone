local color_code = {
  normal  = "\27[0m",
  bold    = "\27[1m",
  black   = "\27[30m",
  red     = "\27[31m",
  green   = "\27[32m",
  yellow  = "\27[33m",
  blue    = "\27[34m",
  magenta = "\27[35m",
  cyan    = "\27[36m",
  white   = "\27[37m",
}

local cc = color_code

local color_names = {
  black   = cc.black,
  red     = cc.red,
  green   = cc.green,
  yellow  = cc.yellow,
  blue    = cc.blue,
  magenta = cc.magenta,
  cyan    = cc.cyan,
  white   = cc.white,
  ["bright-black"]   = cc.bold .. cc.black,
  ["bright-red"]     = cc.bold .. cc.red,
  ["bright-green"]   = cc.bold .. cc.green,
  ["bright-yellow"]  = cc.bold .. cc.yellow,
  ["bright-blue"]    = cc.bold .. cc.blue,
  ["bright-magenta"] = cc.bold .. cc.magenta,
  ["bright-cyan"]    = cc.bold .. cc.cyan,
  ["bright-white"]   = cc.bold .. cc.white
}
  
--[[
function encode_content(content)
  local buf = {}
  local color, text
  for i, l in ipairs(content) do
    if type(l) == "string" then
      buf[i] = l
    elseif type(l) == "table" then
      color, text = l[1], l[2]
      assert(type(text) == "string", "invalid pair in tell content")
      buf[i] = table.concat({color_names[color], text, cc.normal})
    else
      error("invalid type for line in tell content")
    end
  end
  return table.concat(buf, "\n")
end
]]--

function json_string(s)
  -- in a basic way, we just need to replace newlines with \n
  local u = string.gsub(s, "\\", "\\\\")
  u = string.gsub(u, "\n", "\\n")
  u = string.gsub(u, '"', "\\\"")
  return u
end

function json_encode(tab)
  local buf = {'{'}
  local t
  local trailing_comma = false
  for k, v in pairs(tab) do
    table.insert(buf, '"'..k..'":')
    t = type(v)
    if t == 'string' then
      table.insert(buf, '"')
      table.insert(buf, json_string(v))
      table.insert(buf, '"')
    elseif t == 'nil' then
      table.insert(buf, 'null')
    elseif v == false then
      table.insert(buf, 'false')
    elseif v == true then
      table.insert(buf, 'true')
    elseif t == 'table' then
      table.insert(buf, json_encode(v))
    elseif t == 'number' then
      table.insert(buf, v)
    else
      error("can't json encode "..t)
    end
    table.insert(buf, ',')
    trailing_comma = true
  end
  if trailing_comma then
    table.remove(buf)
  end
  table.insert(buf, '}')
  return table.concat(buf)
end

function encode_content(content, options)
  local message = {
    text = content
  }

  for i, opt in ipairs(options) do
    if opt == 'nonl' then message['nonl']=true
    elseif opt == 'bold' then message['bold']=true
    elseif opt == 'wrap' then message['wrap']=true
    else message['color']=opt
    end
  end

  return message
end
