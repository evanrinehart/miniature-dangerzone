local Dialog = require('dialog')
local Stream = require('stream')

local the_player_table = {}

local function debug()
  if next(the_player_table) == nil then
    print("(empty player table)")
  end
  for fd, player in pairs(the_player_table) do
    print(fd, player)
  end
end

local function mk_login()
  local function login()
    tell("Miniature-Dangerzone MUD\n")
    tell("                (C) 2013\n\n")
    tell("username? ")
    username = ask()
    tell("password? ")
    password = ask()

    if Auth.check(username, password) then
      tell("\n\n\n")
      return login()
    else
      tell("WRONG\n")
      quit()
    end
  end

  return login
end

local function read(fd, split_buffer, dialog)
  return function(input)
    message = split_buffer(input)
    if message then
      error_message = dialog(message)
      if error_message then
        c_send(fd, error_message)
        c_kick(fd)
      end
    end
  end
end

local function mk_player(fd, addr)
  local split_buffer = Stream.mk_split_buffer()
  local char = {}
  local dialog = Dialog.start(fd, mk_login())
  local player = {
    fd = fd,
    addr = addr,
    read = read(fd, split_buffer, dialog)
  }

  return player
end

return {
  new = mk_player,
  register = function(player)
    local fd = player.fd
    assert(player, "register player: player is nil")
    assert(the_player_table[fd] == nil, "register player: fd already in use")
    the_player_table[fd] = player
  end,
  clear = function(fd)
    the_player_table[fd] = nil
  end,
  lookup = function(fd)
    return the_player_table[fd]
  end,
  debug = debug
}
