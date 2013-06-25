
local function blank(s)
  return not not string.match(s, "^%s*$")
end

local function text(t)
  return function(s0)
    local s1 = string.match(s0, "^"..t.."(.*)")
    if s1 then
      return t, s1
    else
      error('parse error')
    end
  end
end

local function space(s0)
  local s1 = string.match(s0, "%s+(.*)")
  if s1 then
    return nil, s1
  else
    error('parse error')
  end
end

local function alternative(s0, alts)
  for i, parser in ipairs(alts) do
    local ok, x, s1 = pcall(parser, s0)
    if ok then
      return x, s1
    end
  end

  error('parse error')
end

local function end_of_input(s0)
  if #s0 == 0 then
    return nil, s0
  else
    error('parse error')
  end
end

local function the_rest(s0)
  return s0, ''
end

local function space_then_rest(s0)
  return alternative(s0, {
    end_of_input,
    function(s0)
      local _, s1 = space(s0)
      return the_rest(s1)
    end
  })
end

local function word_plus(word, words, s0)
  local alts = {}
  for i, w in ipairs(words) do
    alts[i] = text(w)
  end
  local x, s1 = alternative(s0, alts)
  local rest = space_then_rest(s1)
  return {word, rest}, ''
end

local function look(s0)
  return word_plus('look', {'look at', 'look', 'l'}, s0)
end

local function kill(s0)
  return word_plus('kill', {'kill', 'k'}, s0)
end

local function command_parser(s0)
  return alternative(s0, {
    look,
    kill
  })
end

function parse(input, parser)
  local ok, x, rest = pcall(parser, input)
  if ok and #rest == 0 then
    return x
  else
    return nil
  end
end

function parse_command(message)
  return parse(message, command_parser)
end
