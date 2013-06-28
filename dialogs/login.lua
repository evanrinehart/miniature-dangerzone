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
  password = ask()

  if db_check_account_password(username, password) then
    me.account = username
    chars = db_get_account_chars(username)
    return pick_character_dialog(me, chars)
  else
    tell(me, "WRONG")
    disconnect(me)
  end
end
