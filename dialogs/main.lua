require('commands/command_table')
require('commands/parser')
require('players/do_command')

function main_dialog(me)
  tell_nonl(me, "fine/ready> ")
  do_command(me, ask())
  return main_dialog(me)
end

