require('base')
require('dialog')

local function main_dialog(me)
  tell(me, "youre in the main dialog loop\n")
  ask()
  return main_dialog(me)
end

local function to_number_in_range(a, b, s)
  n = tonumber(s)
  if n and n >= a and n <= b then
    return n
  else
    return nil
  end
end

local function pick_character_dialog(me, chars)
  for n, char in ipairs(chars) do
    tell(me, string.format("%s. %s\n", n, char.name))
  end
  tell(me, "\n")

  local n = to_number_in_range(1, #chars, ask())

  if n then
    local char = chars[n]
    me.char = char
    me.creature = db_find_creature(char.creature_id)
    return main_dialog(me)
  else
    tell(me, "wrong, please try again\n\n")
    return pick_character_dialog(me, chars)
  end
end

function login_dialog(me)
  tell(me, "Miniature-Dangerzone MUD\n")
  tell(me, "                (C) 2013\n\n")
  tell(me, "username? ")
  username = ask()
  tell(me, "password? ")
  password = ask()

  if db_check_account_password(username, password) then
    chars = db_get_account_chars(username)
    return pick_character_dialog(me, chars)
  else
    tell(me, "WRONG\n")
    disconnect(me)
  end
end
