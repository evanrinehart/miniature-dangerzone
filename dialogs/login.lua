require('base')
require('dialog')
require('dialogs/pick_character')
require('dialogs/new_character')

function login_dialog(me)
  tell(me, "Miniature-Dangerzone MUD")
  tell(me, "                (C) 2013")
  tell(me, "")
  tell_nonl(me, "username? ")
  username = ask()
  tell_nonl(me, "password? ")
  password_mode(me)
  password = ask()

  if db_check_account_password(username, password) then
    local account = db_account(username)
    me.account = account.id
    return pick_character_dialog(me, username)
  else
    tell(me, "WRONG")
    disconnect(me)
  end
end
