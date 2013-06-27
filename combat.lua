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


local function mk_fight(attacker, defender, two_sided)
  return {
    attacker = attacker,
    defender = defender,
    advantage = 'attacker',
    two_sided = two_sided,
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

local function combat_tell(s, text)
  for_each_creature_in(s.location, function(creature)
    local watcher = player_for_creature(creature.id)
    if watcher then
      tell(watcher, text)
    end
  end)
end

local function combat_tell3(
  s,
  from_creature, to_creature,
  between_them_text, at_you_text, from_you_text
)

  local from_player = player_for_creature(from_creature.id)
  local to_player = player_for_creature(to_creature.id)

  for_each_creature_in(s.location, function(creature)
    local watcher = player_for_creature(creature.id)
    if watcher then
      if watcher == from_player then
        tell(watcher, from_you_text)
      elseif watcher == to_player then
        tell(watcher, at_you_text)
      else
        tell(watcher, between_them_text)
      end
    end
  end)
end

local function get_fighters(fight)
  if fight.advantage == 'attacker' then
    return fight.attacker, fight.defender
  elseif fight.advantage == 'defender' then
    return fight.defender, fight.attacker
  else
    error("fight advantage flag is invalid")
  end
end

local function opposite_advantage(a)
  if a == 'attacker' then return 'defender' end
  if a == 'defender' then return 'attacker' end
  error("invalid advantage code")
end

local function lose_advantage(fight, us, them)
  fight.advantage = opposite_advantage(fight.advantage)
  them.advantage_points = d6()
end

local function play_fight(s, fight, us, them)
  -- heart of darkness
  combat_tell3(s, us, them,
    "someone does something to someone!\n",
    "someone does something to you!\n",
    "you do something to someone!\n"
  )

  if d6() == 1 and d6() < 6 then
    return 'ended'
  end

  us.advantage_points = us.advantage_points - 1
  if us.advantage_points == 0 then
    return 'lost-advantage'
  else
    return 'continue'
  end
end

local function combat_routine(s)
  local event, arg1, arg2 = coroutine.yield()

  if event == 'turn' then
    local end_these_fights = {}
    for i, fight in ipairs(s.fights) do
      local points
      local us, them = get_fighters(fight)
      local result = play_fight(s, fight, us, them)

      if result == 'ended' then
        table.insert(end_these_fights, i)
      elseif result == 'lost-advantage' then
        lose_advantage(fight, us, them)
      elseif result == 'continue' then
        -- do nothing
      else
        error("invalid fight result")
      end

    end

    for _, i in ipairs(end_these_fights) do
      table.remove(s.fights, i)
    end

    if #(s.fights) == 0 then -- battle is over
      combat_tell(s, "combat has ended!\n")
      return
    end
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
  attacker.advantage_points = d6()
  local initial_fights = {mk_fight(attacker, defender, true)}
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
      elseif coroutine.status(co) == 'dead' then
        -- do nothing
      else
        error("combat coroutine in anomalous status: " .. coroutine.status(co) .. "\n")
      end
    else
      for _, player in pairs(s.players) do
        tell(player, "combat coroutine has crashed:\n")
        tell(player, msg)
        tell(player, "\n")
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
