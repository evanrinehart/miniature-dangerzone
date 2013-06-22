package.path = package.path .. ""

require('events')
Players = require('player')
Dialog = require('dialog')

function connect_signal(fd, addr)
  print("connect_signal")
  print(fd)
  print(addr)

  login = Dialog.new(Dialog.login)
  player = Players.new(fd, addr, login)
  Players.register(player)

Players.debug()
end

function control_signal(fd, text)
  print("control_signal")

  player = Players.lookup(fd)
  assert(player, "control_signal: unable to find player fd="..fd)
print("control", fd, text)
  player.read(text)
end

function disconnect_signal(fd)
  print("disconnect_signal")
  print(fd)

  -- notify things before
  Players.clear(fd)
  -- notify things after ?
  --
Players.debug()
end

function wake_signal(now)
  the_event_queue.each_ready_event(now, function(e)
    print("an event happened?!")
  end)

  local next_time = the_event_queue.next_time()

  if next_time then
    return math.ceil((next_time - now)*1000000);
  else
    return nil
  end
end


