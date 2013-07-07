require('util/content')

local function raw_msg(player, json)
  c_send(player.fd, json)
  c_send(player.fd, "\n")
end

local function enc(text, opts)
  return json_encode(encode_content(text, opts))
end

local function discriminate(cr_me, cr_them)
  return function(cr)
    local player = player_for_creature(cr)
    if player then
      if cr.id == cr_me.id then return player, 'me'
      elseif cr.id == cr_them.id then return player, 'them'
      else return player, 'else'
      end
    end
  end
end

function mk_msg(text, ...)
  return enc(text, {...})
end

function tell(player, text, ...)
  raw_msg(player, enc(text, {...}))
end

function tell_nonl(player, text)
  tell(player, text, 'nonl')
end

function tell_room(loc, msg)
  tell_many(
    db_creatures_iter(loc),
    function(cr)
      return player_for_creature(cr), 'me'
    end,
    msg
  )
end

function tell_room_except(loc, not_me, msg)
  tell_many(
    db_creatures_iter(loc),
    function(cr)
      if not_me.id == cr.id then
        return nil
      else
        return player_for_creature(cr), 'me'
      end
    end,
    msg
  )
end

function tell_room2(loc, me, msg_me, msg_else)
  tell_many(
    db_creatures_iter(loc),
    function(cr)
      local player = player_for_creature(cr)
      if cr.id == me.id then return player, 'me'
      else return player, 'else'
      end
    end,
    msg_me,
    nil,
    msg_else
  )
end

function tell_room3(loc, me, them, msg_me, msg_them, msg_else)
  tell_many(
    db_creatures_iter(loc),
    discriminate(me, them),
    msg_me, msg_them, msg_else
  )
end

function tell_creature(cr, text, ...)
  local player = player_for_creature(cr)
  if player then
    local msg = enc(text, {...})
    raw_msg(player, msg)
  end
end

function tell_many(iter, discriminator, msg_me, msg_them, msg_else)
  for cr in iter do
    local pl, which = discriminator(cr)
    if pl then
      if which == 'me' then raw_msg(pl, msg_me)
      elseif which == 'them' then raw_msg(pl, msg_them)
      elseif which == 'else' then raw_msg(pl, msg_else)
      else error('invalid discriminator')
      end
    end
  end
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

