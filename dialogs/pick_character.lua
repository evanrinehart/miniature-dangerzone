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

function pick_character_dialog(me, chars)
  tell(me, "Please pick a character:")
  for n, char in ipairs(chars) do
    tell(me, string.format("%s. %s", n, char.name))
  end
  tell(me, "C.   create a new character")
  tell(me, "")

  local input = ask()
  local n = to_number_in_range(1, #chars, input)

  if n then
    local char = chars[n]
    me.char = char
    me.creature = db_find_creature(char.creature_id)
    register_creature(me, me.creature)
    return main_dialog(me)
  elseif input == 'C' then
    create_character_dialog(me)
    return pick_character_dialog(me, db_get_account_chars(me.account))
  else
    tell(me, "wrong, please try again")
    return pick_character_dialog(me, chars)
  end
end
