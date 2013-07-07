local function dig(me, args)
  local dir, name = split(args.arg1, '%s+')
  dir = normalize_direction(dir)

  local here = me:location()
  local there = {
    name = name,
    zone = nil,
    exits = {}
  }

  db_create_room(there)
  db_link_room(here, dir, there)
  db_link_room(there, opposite_direction(dir), here)
  db_commit()

  do_command(me, dir)
end

return {
  effect = dig,
  usage = "dig <direction> <room name>",
  patterns = {'vx'},
  verbs = {'dig'}
}
