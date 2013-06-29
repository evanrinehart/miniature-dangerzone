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
