package.path = package.path .. ""

require('players/player')
require('players/player_table')
require('events/event_queue')

function connect_signal(fd, addr)
  player = mk_player(fd, addr)
  register_player(player)
  player:boot()
end

function control_signal(fd, text)
  player = lookup_player(fd)
  assert(player, "control_signal: unable to find player fd="..fd)
  player:take_input(text)
end

function disconnect_signal(fd)
  -- notify things before
  clear_player(fd)
  -- notify things after ?
  --
end

function wake_signal(now)
  the_event_queue.each_ready_event(now, function(e)
    local f = e.data
    f(e.time)
  end)

  local next_time = the_event_queue.next_time()

  if next_time then
    return math.ceil((next_time - now)*1000000);
  else
    return nil
  end
end


