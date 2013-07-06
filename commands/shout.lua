local function shout(me, args)
  local here = me:location()
  local cr = me.creature
  local color = cr.color
  local text = args.arg1
  local msg = cr.name..' shouts, "'..text..'"'

  for player in players_iter() do
    if player ~= me then
      tell(player, msg, color, 'bold')
    end
  end

  tell(me, 'you shout, "'..text..'"', color, 'bold')
end

return {
  effect = shout,
  usage = "(sh)out <text>",
  patterns = {'vx'},
  verbs = {'shout', 'sh'}
}
