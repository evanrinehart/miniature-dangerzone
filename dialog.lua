function tell(player, text)
  c_send(player.fd, text)
end

function ask()
  return coroutine.yield()
end

function disconnect(player)
  c_kick(player.id)
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

