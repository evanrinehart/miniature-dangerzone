local function kill(me, target)
  -- me is a creature
  -- if target is nil, change to kill mode
  -- otherwise start a fight with target
end

local function parser(s)
  return parse_first_word('kill', {'kill', 'k'}, s)
end

return {
  effect = kill,
  parser = parser
}
