package.path = package.path .. ""

require('players/player')
require('players/player_table')
require('events/event_queue')

require('util/debug')

require('items')

require('zone')

function boot_signal()
  db_begin("data/world.db")
  autoload_zones()
end

function connect_signal(fd, addr)
  local player = mk_player(fd, addr)
  register_player(player)
  player:boot()
end

function control_signal(fd, text)
  local player = lookup_player(fd)
  assert(player, "control_signal: unable to find player fd="..fd)
  player:take_input(text)
end

function disconnect_signal(fd)
  local player = lookup_player(fd)
  assert(player, "control_signal: unable to find player fd="..fd)
  clear_player(fd)

  if player.creature then
    tell_room_except(
      player:location(),
      player.creature,
      mk_msg(player.creature.name.." disconnected")
    )
  end
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


