require('combat')
require('util/dice')

local function bloopers(me, items, decorations)
  local what
  if items[1] then
    what = items[1]:class().single
  else
    what = decorations[1].name
  end
  tell(me, "don't try to kill "..what)
end

local function kill(me, args)
  local targets = args.results1.creatures_or_self
  local decs = args.results1.decorations
  local items = args.results1.items

  if #targets > 0 then
    start_combat(me.creature, targets[1])
  elseif #items + #decs > 0 then
    bloopers(me, items, decs)
  else
    tell(me, not_found(args.arg1))
  end
end

return {
  effect = kill,
  usage = "kill <target>",
  patterns = {'vo'},
  verbs = {'kill'}
}
