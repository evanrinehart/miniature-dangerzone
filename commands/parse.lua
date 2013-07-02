local function parse(me, args)
  local text = args.arg1
  local status, command, result = parse_command(me, text)
  if status == 'usage' then
    tell(me, 'usage: '..command.usage)
  elseif status == 'unknown' then
    tell(me, 'unknown command')
  else
    tell_nonl(me, pps(result))
  end
end

return {
  effect = parse,
  usage = "parse <command>",
  patterns = {'vx'},
  verbs = {'parse'}
}
