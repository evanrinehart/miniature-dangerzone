require('commands/command_table')

local function item_match(item, text)
  if item.name == text then
    return true
  else
    local class = item_class_table[item.class]
    assert(class, "invalid item class ", item.class)
    for i, a in ipairs(class.aliases) do
      if a == text then
        return true
      end
    end
  end

  return false
end

-- after the command parser determines that
-- you want one or two things to be searched for
-- in the area, it runs this on the text for each
-- things. so put elrond in bag would do a search
-- for "elrond" and "bag" separately.
--
-- later we can add support for "bag #4" 
--
-- also we should add searching containers on you

local function command_search(me, text)
  local results = {
    items_held = {},
    items_here = {},
    items = {},
    creatures_or_self = {},
    creatures = {},
    players = {},
    players_here = {},
    decorations = {},
    selection = nil -- like {'item', 34}
  }

  local here = me:location()
  local self = me:self_ref()

  for item in db_item_iter(self) do
    if item_match(item, text) then
      table.insert(results.items_held, item)
      table.insert(results.items, item)
    end
  end

  for item in db_item_iter(here) do
    if item_match(item, text) then
      table.insert(results.items_here, item)
      table.insert(results.items, item)
    end
  end

  for cr in db_creatures_iter(here) do
    if text == cr.name then
      table.insert(results.creatures_or_self, cr)
      if cr.id ~= me.creature.id then
        table.insert(results.creatures, cr)
      end
    end
  end

  -- search for decorations here
  -- search for names of connected players

pp(results)
  return results
end
  


-- patterns
-- vopo
-- vxpo
-- vopx
-- vox  (verb space one-word-object space anything)
-- vo
-- vx
-- v

local function vopo(me, preps, arg)
  local left, right
  local results1, results2
  local prep_l, prep_r
  local found_prep
  for i, prep in ipairs(preps) do
    prep_l, prep_r = string.find(arg, "%s+"..prep.."%s")
    if prep_l then
      found_prep = prep
      left = string.sub(arg, 1, prep_l-1)
      right = string.sub(arg, prep_r+1, -1)
      break
    end
  end

  if left then
    results1 = command_search(me, left)
    results2 = command_search(me, right)
    return left, results1, right, results2, found_prep
  else
    return nil
  end
end

local function vxpo(me, preps, arg)
  local left, right
  local results2
  local prep_l, prep_r
  local found_prep
  for i, prep in ipairs(preps) do
    prep_l, prep_r = string.find(arg, "%s+"..prep.."%s")
    if prep_l then
      found_prep = prep
      left = string.sub(arg, 1, prep_l-1)
      right = string.sub(arg, prep_r+1, -1)
      break
    end
  end

  if left then
    results2 = command_search(me, right)
    return left, right, results2, prep
  else
    return nil
  end
end

local function vopx(me, preps, arg)
  local left, right
  local results1
  local prep_l, prep_r
  local found_prep
  for i, prep in ipairs(preps) do
    prep_l, prep_r = string.find(arg, "%s+"..prep.."%s")
    if prep_l then
      found_prep = prep
      left = string.sub(arg, 1, prep_l-1)
      right = string.sub(arg, prep_r+1, -1)
      break
    end
  end

  if left then
    results1 = command_search(me, left)
    return left, results1, right, prep
  else
    return nil
  end
end

local function vpo(me, preps, arg)
  local right
  local found_prep
  local results2
  for i, prep in ipairs(preps) do
    found_prep, right = string.match(arg, "^("..prep..")%s+(%S.*)")
    if found_prep then break end
  end

  if found_prep then
    results2 = command_search(me, right)
    return right, results2, found_prep
  else
    return nil
  end
end

local function vox(me, arg)
  local left, rest = string.match(arg, "(%S+)%s+(%S.*)")
  if left then
    local results = command_search(me, left)
    return left, results, rest
  else
    return nil
  end
end

function pattern_match_command(me, c, text)
  local name, rest
  for i, verb in ipairs(c.verbs) do
    name, rest = string.match(text, "^("..verb..")%s+(.*)")
    if name then break end
    name = string.match(text, "^"..verb.."$")
    rest = ''
    if name then break end
  end
  if not name then return 'no-match' end
  rest = trim(rest)

  local arg1, results1, arg2, results2, prep
  local final_pattern
  
  for i, pattern in ipairs(c.patterns) do
    if pattern == 'vopo' then
      final_pattern = pattern
      arg1, results1, arg2, results2, prep = vopo(me, c.preps, rest)
      if arg1 then break end
    elseif pattern == 'vopx' then
      final_pattern = pattern
      arg1, results1, arg2, prep = vopx(me, c.preps, rest)
      if arg1 then break end
    elseif pattern == 'vxpo' then
      arg1, arg2, results2, prep = vxpo(me, c.preps, rest)
      if arg1 then break end
    elseif pattern == 'vpo' then
      arg2, results2, prep = vpo(me, c.preps, rest)
      if arg2 then break end
    elseif pattern == 'vox' then
      arg1, results1, arg2 = vox(me, rest)
      if arg1 then break end
    elseif pattern == 'vo' then
      if rest ~= '' then
        results1 = command_search(me, rest)
        arg1 = rest
        break
      end
    elseif pattern == 'vx' then
      if rest ~= '' then
        arg1 = rest
        break
      end
    elseif pattern == 'v' then
      if rest == '' then
        return 'match', {command = name}
      else
        return 'usage'
      end
    else
      error("unrecognized command pattern")
    end
  end

  if arg1 or arg2 then
    return 'match', {
      command = name,
      pattern = final_pattern,
      prep = prep,
      arg1 = arg1,
      results1 = results1,
      arg2 = arg2,
      results2 = results2
    }
  else
    return 'usage'
  end
end

function parse_command(me, text)
  local status, args

  for command_name, command in pairs(command_table) do
    status, args = pattern_match_command(me,command,text)
    if status == 'match' then
      return 'match', command, args
    elseif status == 'usage' then
      return 'usage', command
    elseif status == 'no-match' then
      -- do nothing
    end
  end

  return 'unknown'
end
