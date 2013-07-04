require('util/content')

--[[
function tell(player, content)
  tell_nonl(player, content)
  c_send(player.fd, "\n")
end

function tell_nonl(player, content)
  -- content can be a string or
  -- content can be a table of lines
  -- a line is a string or a pair (color, text)
  if type(content) == "string" then
    c_send(player.fd, content)
  elseif type(content) == "table" then
    local raw = encode_content(content)
    c_send(player.fd, raw)
  else
    error("invalid type for tell")
  end
end
--]]

function tell(player, text, ...)
  local json = json_encode(encode_content(text, {...}))
  c_send(player.fd, json)
  c_send(player.fd, "\n")
end

function tell_nonl(player, text)
  tell(player, text, 'nonl')
end

function password_mode(player)
  c_send(player.fd, json_encode({['password-mode']=true}))
  c_send(player.fd, "\n")
end

function ask()
  return coroutine.yield()
end

function disconnect(player)
  c_kick(player.fd)
end

function start_dialog(player, dialog)
  local co = coroutine.create(dialog)
  assert(coroutine.resume(co, player))
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

