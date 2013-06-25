require('commands/command_table')

function parse_command(text)
  local result
  for i, c in pairs(command_table) do
    result = c.parser(text)
    if result then
      return result
    end
  end
  return nil
end

function parse_first_word(word, alts, s)
  local rest
  for i, w in ipairs(alts) do
    rest = string.match(s, '^'..w..'%s+(.*)$')
    if rest then
      return {word, rest}
    elseif s == w then
      return {word, ''}
    end
  end
  return nil
end

function trim(s0)
  local s1 = string.gsub(s0, "^%s+", "")
  return string.gsub(s1, "%s+$", "")
end
