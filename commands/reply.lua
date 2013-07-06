local function reply(me, args)
  local here = me:location()
  local text = args.arg1
  local cr = me.creature
  local color = cr.color

end

return {
  effect = reply,
  usage = "(re)ply <message>",
  patterns = {'vx'},
  verbs = {'reply', 're'}
}
