require('base')
require('dialog')

require('commands/command_table')
require('commands/parser')


local function main_dialog(me)
  -- do a look command
  -- while true
  --   show the prompt
  --   parse a command
  -- end
  tell(me, "fine/ready> ")
  local message = ask()
  local command = parse_command(message)
  if not command then
    tell(me, "unknown command\n")
    return main_dialog(me)
  else
    command_table[command[1]].effect(me, command[2])
  end

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

local function create_character_dialog(me)
  tell(me, "you are about to create a character\n")
  tell(me, "now what? ")
  ask()
  -- create character in database
  return -- goes back to pick_character_dialog
end

local function pick_character_dialog(me, chars)
  tell(me, "Please pick a character:\n")
  for n, char in ipairs(chars) do
    tell(me, string.format("%s. %s\n", n, char.name))
  end
  tell(me, "C.   create a new character\n")
  tell(me, "\n")

  local input = ask()
  local n = to_number_in_range(1, #chars, input)

  if n then
    local char = chars[n]
    me.char = char
    me.creature = db_find_creature(char.creature_id)
    return main_dialog(me)
  elseif input == 'C' then
    create_character_dialog(me)
    return pick_character_dialog(me, db_get_account_chars(me.account))
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
    me.account = username
    chars = db_get_account_chars(username)
    return pick_character_dialog(me, chars)
  else
    tell(me, "WRONG\n")
    disconnect(me)
  end
end
