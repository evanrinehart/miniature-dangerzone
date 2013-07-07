local function stats(me, args)
  local cr = me.creature

  tell(me, "=Character=")
  tell(me, '')
  tell(me, "Name: ", 'nonl')
  tell(me, cr:name())
  tell(me, '')

  tell(me, 'Health:   ', 'nonl')
  tell(me, cr.health, 'nonl')
  tell(me, "/3")

  tell(me, 'Stamina:  ', 'nonl')
  tell(me, cr.stamina, 'nonl')
  tell(me, "/3")

  tell(me, 'Food:   ', 'nonl')
  tell(me, cr.food, 'nonl')
  tell(me, "/3")

  tell(me, 'Alcohol:  ', 'nonl')
  tell(me, cr.alcohol, 'nonl')
  tell(me, "/3")

  tell(me, '')
  
end

return {
  effect = stats,
  usage = "stats by itself",
  patterns = {'v'},
  verbs = {'stats', 'st'}
}

--[[
=Character=

Name:
Class:
Score:

Health:     3/3 fine      Alignment:
Stamina:    3/3 ready     Fame:
Food:       3/3           Noriety:
Alcohol:    3/3 ok

Form:
size+2
wings+2
beam attack
claws
tail+2
quadrapedal
long neck
fanged jaws
flying
armored skin+2
--]]
