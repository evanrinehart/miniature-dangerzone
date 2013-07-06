local function say(me, args)
  local here = me:location()
  local text = args.arg1
  local cr = me.creature
  local color = cr.color

  tell_room2(here, me.creature,
    mk_msg("you say, \""..text.."\"", color),
    mk_msg(cr.name.." says, \""..text.."\"", color)
  )
end

return {
  effect = say,
  usage = "say <text>",
  patterns = {'vx'},
  verbs = {'say', "'"}
}
