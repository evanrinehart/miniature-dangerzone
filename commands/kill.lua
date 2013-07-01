require('combat')
require('util/dice')

local function kill(me, args)
  -- me is a creature
  -- if target is nil, change to kill mode
  -- otherwise start a fight with target
--  local target, creature = target_match(me, target_string)
--  start_combat(me.creature, creature)
end

return {
  effect = kill,
  usage = "kill <target>",
  patterns = {'vo'},
  verbs = {'kill'}
}
