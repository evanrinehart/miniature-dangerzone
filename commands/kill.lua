require('combat')
require('dice')

local function target_match(me, s)
  return {'creature', db_dummy_creature()}
end

local function kill(me, target_string)
  -- me is a creature
  -- if target is nil, change to kill mode
  -- otherwise start a fight with target


  local target = target_match(me, target_string)
  local creature = target[2]

  start_combat(me.creature, creature)
end

local function parser(s)
  return parse_first_word('kill', {'kill', 'k'}, s)
end

return {
  effect = kill,
  parser = parser
}
