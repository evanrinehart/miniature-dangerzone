local function gossip(me, args)
  local here = me:location()
  local color = creature_color(me.creature)
  local cr = me.creature
  local text = args.arg1
  local msg = cr.name..': '..text

  for player in players_iter() do
    tell(player, text, color)
  end
end

return {
  effect = gossip,
  usage = "gossip <text>",
  patterns = {'vx'},
  verbs = {'gossip', 'gos', ';'}
}
