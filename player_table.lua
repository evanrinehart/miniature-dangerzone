local the_player_table = {}

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

function clear_player(fd)
  the_player_table[fd] = nil
end

function lookup_player(fd)
  return (assert(the_player_table[fd], "player anomalously not found"))
end

function lookup_player_maybe(fd)
  return the_player_table[fd]
end
