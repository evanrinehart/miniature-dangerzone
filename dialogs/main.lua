require('commands/command_table')
require('commands/parser')

function main_dialog(me)
  tell_nonl(me, "fine/ready> ")

  local message = ask()

  local status, command, args = parse_command(me, message)

  if status == 'unknown' then
    tell(me, "unknown command")
  elseif status == 'usage' then
    tell(me, "usage: " .. command.usage)
  elseif status == 'match' then
    local ok, err = pcall(command.effect, me, args)
    if ok then
      -- do nothing
    else
      tell(me, err)
      db_rollback()
    end
  else
    error("parse_command return value "..tostring(status))
  end

  return main_dialog(me)
end

