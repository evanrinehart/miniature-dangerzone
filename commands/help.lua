function help_about(me, topic)
  tell(me, "help about "..topic)
end

function help(me, args)
  if args.pattern == 'v' then
    help_topic(me, "help")
  else
    help_topic(me, args.arg1)
  end
end

return {
  effect = help,
  usage = "help, help <topic>",
  patterns = {'v', 'vx'},
  verbs = {'help'}
}

