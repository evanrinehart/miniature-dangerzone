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

local function do_command(me, text)
  local status, command, args = parse_command(me, text)

  if status == 'unknown' then
    tell(me, "unknown command")
  elseif status == 'usage' then
    tell(me, "usage: " .. command.usage)
  elseif status == 'match' then
    local ok, err = pcall(command.effect, me, args)
    if ok then
      -- do nothing
    else
      tell(me, err)
      db_rollback()
    end
  else
    error("parse_command return value "..tostring(status))
  end
end

local function move(me, args)
  local my = me
  local kind, place = db_ref(my:location())
  local dir

  if args.arg1 then
    dir = dirs[args.arg1]
  else
    dir = dirs[args.command]
  end

  if not dir then
    tell(me, "usage: "..command_table.move.usage)
    return
  end

  if kind == 'room' then
    local dest = place.exits[dir]
    if dest then
      db_move_creature_to(me.creature, dest)
      db_commit()
      tell(me, "you move "..dir_names[dir])
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
  usage = "move <direction> or one of [neswud]",
  patterns = {'vx', 'v'},
  verbs = {
    'move',
    'e', 'w', 's', 'n', 'u', 'd',
    'east', 'west', 'south', 'north',
    'up', 'down'
  }
}
