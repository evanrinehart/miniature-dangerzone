local dirs = {
  e = 'e',
  east = 'e',
  w = 'w',
  west = 'w',
  n = 'n',
  north = 'n',
  s = 's',
  south = 's',
  u = 'u',
  up = 'u',
  d = 'd',
  down = 'd'
}

local dir_names = {
  e = 'east',
  w = 'west',
  u = 'up',
  d = 'down',
  n = 'north',
  s = 'south'
}

local function move(me, where)
  local my = me
  local kind, place = db_ref(my:location())
  if kind == 'room' then
    local dest = place.exits[where]
    if dest then
      db_move_creature_to(my.creature, dest)
      db_commit()
      tell(me, "you move "..dir_names[where])
      command_table.look.effect(me, '') -- need function for this
    else
      tell(me, "there is no way")
    end
  else
    tell(me, "hmm..")
  end
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
      return {'error', "move which way? (nsewup)"}
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
