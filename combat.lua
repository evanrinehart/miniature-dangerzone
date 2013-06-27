--[[
implementation notes

a combat instance is a coroutine.
the inputs to the yield are one of several alternatives:
  * a combat related command issued by a player
  * a player enters combat via some command
  * triggering the next turn

on a turn, the event to trigger the next turn may
be scheduled (if the combat instance didnt end).
if it is scheduled the id is saved in order to
cancel that event if the fight ends due to a command.

on each yield, the event id is returned so that
the event can be cancelled by the caller if the combat
instance crashes (due to a bug)

if an error occurs, the error is reported to all players
involved in the instance. and the turn event is cancelled.

when the combat instance is over (no fights left)
the coroutine returns normally.

]]--

local function compare_fight(f1, f2)
  -- (x,y) == (y,x)

  local a = f1.attacker.id
  local b = f1.defender.id
  local c = f2.attacker.id
  local d = f2.defender.id

  if (a==c and b==d) or (a==d and b==d) then
    return 0
  else
    return 1
  end
end


local function mk_fight(attacker, defender)
  return {
    attacker = attacker,
    defender = defender,
    advantage = 'attacker',
    distance = 2
  }
end

local function mk_combat_instance(initial_fights)
  assert(#initial_fights > 0, "attempting to create an empty combat instance")

  local players = {}
  for i, f in ipairs(initial_fights) do
    local c1 = f.attacker.id
    local c2 = f.defender.id
    local p1 = player_for_creature(c1)
    local p2 = player_for_creature(c2)

    if p1 then
      players[c1] = p1
    end

    if p2 then
      players[c2] = p2
    end
  end

  return {
    fights = initial_fights,
    location = initial_fights[1].attacker.location,
    turn_event_id = nil,
    players = players
  }
end

local function combat_routine(s)
  local event, arg1, arg2 = coroutine.yield()

  if event == 'turn' then
    print("a turn!")
    -- do a turn
    -- if fight not over schedule a turn event
    -- reset s.turn_event_id
    -- if fight over return
  elseif event == 'command' then
    -- if player not already in combat, insert him
    -- interpret the command
    -- if no fights left, cancel turn event
    -- if no fights left, cancel turn event
    -- if fight over return
  else
    error("invalid combat event")
  end

  return combat_routine(s)
end

function continue_combat(event, arg1, arg2, routine)
  -- id = resume(event, arg1, arg2)
  -- if error, cancel event, report error
  -- if ended normally, do nothing
end

combat_instance_table = {}

function start_combat(attacker, defender)
  local initial_fights = {mk_fight(attacker, defender)}
  local s = mk_combat_instance(initial_fights)  
  local co = coroutine.create(combat_routine)
  s.co = co

  assert(coroutine.resume(co, s))
  assert(
    combat_instance_table[s.location] == nil,
    "theres already a combat instance here"
  )
  combat_instance_table[s.location] = s

  local function combat_event(now)
    local ok, msg = coroutine.resume(co, 'turn')
    if ok then
      if coroutine.status(co) == 'suspended' then
        schedule_event(now+1, combat_event)
      elseif coroutine.status == 'dead' then
        -- do nothing
      else
        error("combat coroutine in anomalous status: " .. coroutine.status(co))
      end
    else
      print("combat coroutine has crashed:")
      print(msg)

      for _, player in pairs(s.players) do
        player.in_combat = false
      end
      combat_instance_table[s.location] = nil
    end
  end

  local now = c_clock()
  local eid0 = schedule_event(now, combat_event)
  s.turn_event_id = eid0

  for _, player in pairs(s.players) do
    player.in_combat = true
  end
end
