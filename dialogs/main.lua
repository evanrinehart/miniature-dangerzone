require('commands/command_table')
require('commands/parser')

function main_dialog(me)
  -- do a look command
  -- while true
  --   show the prompt
  --   parse a command
  -- end
  tell_nonl(me, "fine/ready> ")
  local message = ask()
  local command = parse_command(message)
  if not command then
    tell(me, "unknown command")
  elseif command[1] == 'error' then
    tell(me, command[2])
    db_rollback()
  else
    command_table[command[1]].effect(me, command[2])
  end

  return main_dialog(me)
end

