require('commands')
require('parser')
require('players/do_command')
require('prompt')

function main_dialog(me)
  tell_nonl(me, show_prompt(me.creature))
  local message = trim(ask())
  if message ~= '' then
    do_command(me, message)
  end

  if me.connected then
    return main_dialog(me)
  end
end

