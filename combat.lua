local combat_instance_table = {}

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

  local creatures = {}

  for i, f in ipairs(initial_fights) do
    local c1 = f.attacker
    local c2 = f.defender

    creatures[c1.id] = c1
    creatures[c2.id] = c2
  end

  return {
    fights = initial_fights,
    creatures = creatures,
    location = initial_fights[1].attacker.location,
    turn_event_id = nil
  }
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
  them.ap = d6()
end

local function play_fight(s, fight, us, them)
  -- heart of darkness
  local here = s.location

  if d6() == 1 and d6() < 6 then
    return 'ended'
  end

  us.ap = us.ap - 1
  if us.ap == 0 then
    lose_advantage(fight, us, them)
  end

  return 'continue'
end

local function combat_routine(s, event, arg1, arg2)
  if event == 'turn' then
    local end_these_fights = {}
    for i, fight in ipairs(s.fights) do
      local points
      local us, them = get_fighters(fight)
      local result = play_fight(s, fight, us, them)

      if result == 'ended' then
        table.insert(end_these_fights, i)
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
      combat_tell(s, "combat has ended!")
      return nil
    end
  elseif event == 'command' then
    -- interpret the command
    -- if no fights left, cancel turn event
    -- if no fights left, cancel turn event
    -- if fight over return nil
  else
    error("invalid combat event")
  end

  return 'ok'
end

local function join_combat(s, attacker, defender)
  tell_creature(attacker, "not implemented")
end

function start_combat(attacker, defender)
  attacker.ap = d6()
  local initial_fights = {mk_fight(attacker, defender, true)}
  local s = mk_combat_instance(initial_fights)  

  if combat_instance_table[s.location] then
    join_combat(combat_instance_table[s.location], attacker, defender)
    return
  end

  combat_instance_table[s.location] = s

  local function combat_event(now)
    local ok = combat_routine(s, 'turn')
    if ok then
      schedule_event(now+1, combat_event)
    else
      combat_instance_table[s.location] = nil
      for _, creature in pairs(s.creatures) do
        creature.in_combat = false
      end
    end
  end

  local now = c_clock()
  local eid0 = schedule_event(now, combat_event)
  s.turn_event_id = eid0

  for _, creature in pairs(s.creatures) do
    creature.in_combat = true
  end
end
