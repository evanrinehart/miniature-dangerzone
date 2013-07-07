require('zone')

local function zone_cmd(me, args)
  local zone_name = args.arg1
  load_zone(zone_name) -- need to pcall this
  db_commit()
debug_database()
end


return {
  effect = zone_cmd,
  usage = "zone <zonename>",
  patterns = {'vx'},
  verbs = {'zone'}
}
