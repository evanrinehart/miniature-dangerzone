local function help_about(me, topic)
  local file = io.open('help/'..topic, 'r')
  if file then
    tell(me, '')
    for l in file:lines() do
      tell(me, l)
    end
    tell(me, '')
    file:close()
  else
    tell(me, "no help found on that topic")
  end
end

local function help(me, args)
  if args.pattern == 'v' then
    help_about(me, "help")
  else
    help_about(me, args.arg1)
  end
end

return {
  effect = help,
  usage = "help, help <topic>",
  patterns = {'v', 'vx'},
  verbs = {'help'}
}

