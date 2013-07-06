local function tell_cmd(me, args)
  local here = me:location()
  local text = args.arg2
  local cr = me.creature
  local color = cr.color

  local players_here = args.results1.players_here
  local players = args.results1.players
  local creatures = args.results1.creatures_or_self

  if #players > 0 then
    local msg_them = cr.name..' tells you, "'..text..'"'
    tell(players[1], msg_them, color, 'bold')
    tell(me,
      'you tell '..players[1].creature.name..', "'..text..'"',
      color, 'bold'
    )
    me.reply_to = players[1]
  elseif #creatures > 0 then
    tell(me, 'you tell '..creatures[1].name..', "'..text..'"',color,'bold')
    me.reply_to = nil
  else
    tell(me, args.arg1..' not found')
  end
end

return {
  effect = tell_cmd,
  usage = "(t)ell <someone> <message>",
  patterns = {'vox'},
  verbs = {'tell', 't', 'whisper', 'wh'}
}
