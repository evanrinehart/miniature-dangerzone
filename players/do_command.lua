function do_command(me, text)
  local status, command, args = parse_command(me, text)

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
end
