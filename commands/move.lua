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

local function move(me, args)
  local my = me
  local kind, place = db_ref(my:location())
  local dir

-- parser is returning cases where you have vx and x is ''
-- it should pick v instead otherwise vx '' == "usage"

print("arg1", type(args.arg1), #args.arg1)
  if args.arg1 then
print("ok")
    dir = dirs[args.arg1]
  else
print("command: ", args.command)
    dir = dirs[args.command]
  end

  if not dir then
    tell(me, "usage: ", command_table.move.usage)
    return
  end

  if kind == 'room' then
    local dest = place.exits[dir]
    if dest then
      db_move_creature_to(me.creature, dest)
      db_commit()
      tell(me, "you move "..dir_names[dir])
      command_table.look.effect(me) -- need function for this
    else
      tell(me, "there is no way")
    end
  else
    tell(me, "hmm..")
  end
end

return {
  effect = move,
  usage = "move <direction> or one of [neswud]",
  patterns = {'vx', 'v'},
  verbs = {
    'move',
    'e', 'w', 's', 'n', 'u', 'd',
    'east', 'west', 'south', 'north',
    'up', 'down'
  }
}
