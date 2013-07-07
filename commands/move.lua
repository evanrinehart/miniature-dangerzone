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

  if args.arg1 then
    dir = dirs[args.arg1]
  else
    dir = dirs[args.command]
  end

  direction = dir_names[dir]

  if not dir then
    tell(me, "usage: "..command_table.move.usage)
    return
  end

  if kind == 'room' then
    local from = me:location()
    local dest = place.exits[dir]
    local to = dest
    if dest then
      db_move_creature_to(me.creature, dest)
      db_commit()
      tell_room(from, string.format("%s goes %s", me.creature:name(), direction))
      tell_room_except(to,
        me.creature,
        mk_msg(me.creature:name()..' arrives')
      )
      do_command(me, "look")
    else
      tell(me, "there is no way")
    end
  else
    tell(me, "hmm..")
  end
end

return {
  effect = move,
  usage = "move/go <direction> or one of [neswud]",
  patterns = {'vx', 'v'},
  verbs = {
    'move', 'go',
    'e', 'w', 's', 'n', 'u', 'd',
    'east', 'west', 'south', 'north',
    'up', 'down'
  }
}
