local dirs = {
  e = 'e',
  east = 'e',
  w = 'w',
  west = 'w',
  n = 'n',
  north = 'n',
  s = 's',
  south = 'south',
  u = 'u',
  up = 'u',
  d = 'd',
  down = 'd'
}

local function move(me, where)
  tell(me, "not yet\n")
end

local function parser(s0)
  local s1 = trim(s0)
  local result = parse_first_word('move', {'move'}, s0)
  local d1 = dirs[s1]
  if result then
    local rest = result[2]
    local d2 = dirs[trim(rest)]
    if d2 then
      return {'move', d2}
    else
      return {'error', "move which way? (nsewup)\n"}
    end
  elseif d1 then
    return {'move', d1}
  else
    return nil
  end
end


return {
  effect = move,
  parser = parser
}
