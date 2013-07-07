local function stats(me, args)
  local cr = me.creature
  local lines = {
    {{text="=Character="}},
    {},
    {{text="Name: "},{text=cr:name()}},
    {},
    {{text="Health:   "},{text=tostring(cr.health)},{text="/3"}},
    {{text="Stamina:  "},{text=tostring(cr.stamina)},{text="/3"}},
    {{text="Food:     "},{text=tostring(cr.food)},{text="/3"}},
    {{text="Alcohol:  "},{text=tostring(cr.alcohol)},{text="/3"}}
  }

  tell_pref(me, lines)
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
