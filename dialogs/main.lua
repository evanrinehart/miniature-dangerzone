require('commands')
require('parser')
require('players/do_command')

function main_dialog(me)
  tell_nonl(me, "fine/ready> ")
  local message = trim(ask())
  if message ~= '' then
    do_command(me, message)
  end
  return main_dialog(me)
end

