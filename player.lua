local the_player_table = {}

-- remove trailing newline if any
local function chomp(x)
  return (string.gsub(x, "\r?\n$", ""))
end

-- returns nil if x consists of one line (no newline)
-- otherwise returns a,b where a is the first line and b is the rest
local function line(x)
  i = string.find(x, "\r?\n", 1)
  if i then
    return chomp(string.sub(x, 1, i)), string.sub(x, i+1, -1)
  else
    return nil
  end
end

-- used to produce lines from the input stream
local mk_line_parser = function()
  local buffer = ""
  return function(input)
    buffer = buffer .. input
    -- check for line
    l, rest = line(buffer)
    if l then -- a line is complete
      buffer = rest
      return l
    else
      return nil
    end
  end
end

local function dialog_environment(specials)
  local env = {
    error = error,
    assert = assert,
    ipairs = ipairs,
    pairs = pairs,
    next = next,
    select = select,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    unpack = unpack
  }

  env.string = {}
  env.table = {}
  env.math = {}

  env.string.byte = string.byte
  env.string.char = string.char
  env.string.find = string.find
  env.string.format = string.format
  env.string.gmatch = string.gmatch
  env.string.gsub = string.gsub
  env.string.len = string.len
  env.string.lower = string.lower
  env.string.match = string.match
  env.string.rep = string.rep
  env.string.reverse = string.reverse
  env.string.sub = string.sub
  env.string.upper = string.upper
  env.table.insert = table.insert
  env.table.maxn = table.maxn
  env.table.remove = table.remove
  env.table.sort = table.sort
  env.math.abs = math.abs
  env.math.abs = math.abs
  env.math.abs = math.abs
  env.math.abs = math.abs
  env.math.abs = math.abs
  env.math.abs = math.abs
  env.math.abs = math.abs
  env.math.abs = math.abs
  env.math.abs = math.abs

  for name, f in pairs(specials) do
    env[name] = f
  end

  return env
end

local function begin_dialog(fd, dialog)
  local function ask()
    return coroutine.yield()
  end

  local function tell(text)
    c_send(fd, text)
  end

  local function quit()
    c_kick(fd)
  end

  local function sleep()
    -- schedule an event
    -- disable input
    --   in the event, enable input and resume
  end

  local env = dialog_environment({
    ask = ask,
    tell = tell,
    quit = quit,
    sleep = sleep
  })

-- QUESTION
-- does this set environment on the login dialog
-- for everyone? does this affect already running dialogs
-- which (may have) descended from login
  setfenv(dialog, env)

  local co = coroutine.create(dialog)

  assert(coroutine.resume(co))

  return function(input)
    assert(coroutine.status(co) == "suspended", "tried to use a crashed dialog")
    ok, err = coroutine.resume(co, input)
    if ok then
      return nil
    else
      return err
    end
  end

end

local function login()
  tell("Miniature-Dangerzone MUD\n")
  tell("                (C) 2013\n\n")
  tell("username? ")
  username = ask()
  tell("password? ")
  password = ask()

  quit()
end

local function mk_player(fd, addr)
  local split_buffer = mk_line_parser()
  local char = {}
  local dialog = begin_dialog(fd, login)
  local player = {
    fd = fd,
    addr = addr,
    parse = function(input)
      message = split_buffer(input)
      if message then
        error_message = dialog(message)
        if error_message then
          c_send(fd, error_message)
          c_kick(fd)
        end
      end
    end
  }

  return player
end

local function debug()
  local function show(p)
    return "("..p.fd..","..p.dialog..")"
  end

  if next(the_player_table) == nil then
    print("(empty player table)")
  end
  for fd, player in pairs(the_player_table) do
    print(fd, player)
  end
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
