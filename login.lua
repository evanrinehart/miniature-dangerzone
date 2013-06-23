require('base')
require('dialog')

local function main_dialog(me)
  tell(me, "youre in the main dialog loop\n")
  ask()
  return main_dialog(me)
end

function login_dialog(me)
  tell(me, "Miniature-Dangerzone MUD\n")
  tell(me, "                (C) 2013\n\n")
  tell(me, "username? ")
  username = ask()
  tell(me, "password? ")
  password = ask()

  if db_check_account_password(username, password) then
    -- load character
    main_dialog(me)
  else
    tell(me, "WRONG\n")
    disconnect(me)
  end
end
