return {
  effect = function(me, args)
    if args.command == 'quit' then
      tell(me, "ok")
      c_kick(me.fd)
      -- careful, no more messages may be sent to player
      me.connected = false
    else
      tell(me, "please spell out the whole quit command to really quit")
    end
  end,
  usage = "quit by itself, spelled out completely",
  patterns = {'v'},
  verbs = {'quit', 'q'}
}
