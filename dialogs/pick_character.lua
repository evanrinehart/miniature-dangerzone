require('base')
require('dialogs/main')

local function to_number_in_range(a, b, s)
  n = tonumber(s)
  if n and n >= a and n <= b then
    return n
  else
    return nil
  end
end

function pick_character_dialog(me, username)
  tell(me, "Please pick a character:")
  local i = 1
  local chars = {}
  for char in db_account_characters_iter(username) do
    tell(me, string.format("%s. %s", i, char.name))
    chars[i] = char
    i = i + 1
  end
  tell(me, "C.   create a new character")
  tell(me, "")

  local input = ask()
  local n = to_number_in_range(1, #chars, input)

  if n then
    local char = chars[n]
    me.char = char
    me.creature = db_find('creature', char.creature)
    register_creature(me, me.creature)
    tell_room_except(
      player:location(),
      player.creature,
      mk_msg(player.creature.name.." connects")
    )
    do_command(me, 'look')
    return main_dialog(me)
  elseif input == 'C' then
    create_character_dialog(me)
    return pick_character_dialog(me, username)
  else
    tell(me, "wrong, please try again")
    return pick_character_dialog(me, username)
  end
end
