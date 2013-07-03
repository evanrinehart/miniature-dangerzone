local the_player_table = {}
local creature_lookup = {}

function debug_player_table()
  if next(the_player_table) == nil then
    print("(empty player table)")
  end

  for fd, player in pairs(the_player_table) do
    print(fd, player)
  end
end

function register_player(player)
  local fd = player.fd
  assert(player, "register player: player is nil")
  assert(the_player_table[fd] == nil, "register player: fd already in use")
  the_player_table[fd] = player
end

function register_creature(player, creature)
  creature_lookup[creature.id] = player
end

function clear_player(fd)
  assert(the_player_table[fd], "attempt to clear player, but not found here")
  local player = the_player_table[fd]
  the_player_table[fd] = nil
  if player.creature then
    creature_lookup[player.creature.id] = nil
  end
end

function lookup_player(fd)
  return (assert(the_player_table[fd], "player anomalously not found"))
end

function player_for_creature(creature_id)
  return creature_lookup[creature_id]
end

function lookup_player_maybe(fd)
  return the_player_table[fd]
end

function players_iter()
  local player, fd
  return function()
    fd, player = next(the_player_table, fd)
    if fd then
      return player
    else
      return nil
    end
  end
end
