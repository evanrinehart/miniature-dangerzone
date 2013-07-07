require('commands')

local function item_match(item, text)
  local cl = item:class()
  assert(cl, "invalid item class ", item.class_name)

  if cl.single == text then
    return true, false
  elseif cl.plural == text then
    return true, true
  else
    for i, a in ipairs(cl.aliases) do
      if a == text then
        return true, false
      end
    end

    for i, a in ipairs(cl.plural_aliases) do
      if a == text then
        return true, true
      end
    end
  end

  return false, false
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
--
-- all means that the player typed "all"
-- just stick all=true in the result in this case
-- also stick all=true in there if they typed a plural alias
--
-- pick non-nil is a number which determines which
-- one they want. put it in pick= in the result so
-- the command can deal with it

function command_search(me, text, all, pick)
  local results = {
    items_held = {},
    items_here = {},
    items = {},
    creatures_or_self = {},
    creatures = {},
    players = {},
    players_here = {},
    decorations = {},
    selection = pick,
    all = all ~= nil
  }

  local here = me:location()
  local self = me:self_ref()

  local match, plural

  for item in db_item_iter(self) do
    match, plural = item_match(item, text)
    if match or text == 'all' then
      table.insert(results.items_held, item)
      table.insert(results.items, item)
      if plural then results.all = true end
    end
  end

  for item in db_item_iter(here) do
    match, plural = item_match(item, text)
    if match or text == 'all' then
      table.insert(results.items_here, item)
      table.insert(results.items, item)
      if plural then results.all = true end
    end
  end

  for cr in db_creatures_iter(here) do
    if text == cr:name() or text == 'all' then
      table.insert(results.creatures_or_self, cr)
      if cr.id ~= me.creature.id then
        table.insert(results.creatures, cr)
      end
    end
  end

  for pl in players_iter() do
    if text == pl.creature:name() then
      table.insert(results.players, pl)
      if pl.creature.location == here then
        table.insert(results.players_here, pl)
      end
    end
  end

  -- search for decorations here

  return results
end

local function check_picker(raw)
  if raw == 'all' then return 'all', true, nil end
  local arg, all, pick

  arg, pick = string.match(raw, '^([^#]*)%s+#(%d+)$')
  if arg then return arg, nil, tonumber(pick) end

  arg = string.match(raw, 'all%s+(%S.*)')
  if arg then return arg, true, nil end

  return raw, nil, nil
end


-- patterns
-- vopo
-- vxpo
-- vopx
-- vox  (verb space one-word-object space anything)
-- vo
-- vx
-- v

local function vopo(me, preps, raw)
  local left, right
  local prep_l, prep_r
  local found_prep
  for i, prep in ipairs(preps) do
    prep_l, prep_r = string.find(raw, "%s+"..prep.."%s")
    if prep_l then
      found_prep = prep
      left = string.sub(raw, 1, prep_l-1)
      right = string.sub(raw, prep_r+1, -1)
      break
    end
  end

  if left then
    local arg1, all1, pick1 = check_picker(left)
    local results1 = command_search(me, left, all1, pick1)
    local arg2, all2, pick2 = check_picker(right)
    local results2 = command_search(me, right, all2, pick2)
    return {
      arg1 = arg1,
      results1 = results1,
      arg2 = arg2,
      results2 = results2,
      prep = found_prep
    }
  else
    return nil
  end
end

local function vxpo(me, preps, raw)
  local left, right
  local prep_l, prep_r
  local found_prep
  for i, prep in ipairs(preps) do
    prep_l, prep_r = string.find(raw, "%s+"..prep.."%s")
    if prep_l then
      found_prep = prep
      left = string.sub(raw, 1, prep_l-1)
      right = string.sub(raw, prep_r+1, -1)
      break
    end
  end

  if left then
    local arg, all, pick = check_picker(right)
    local results = command_search(me, right, all, pick)
    return {
      arg1 = left,
      arg2 = right,
      results2 = results,
      prep = found_prep
    }
  else
    return nil
  end
end

local function vopx(me, preps, raw)
  local left, right
  local prep_l, prep_r
  local found_prep
  for i, prep in ipairs(preps) do
    prep_l, prep_r = string.find(raw, "%s+"..prep.."%s")
    if prep_l then
      found_prep = prep
      left = string.sub(raw, 1, prep_l-1)
      right = string.sub(raw, prep_r+1, -1)
      break
    end
  end

  if left then
    local arg, all, pick = check_picker(left)
    local results = command_search(me, arg, all, pick)
    return {
      arg1 = arg1,
      results1 = results,
      arg2 = rest,
      prep = found_prep
    }
  else
    return nil
  end
end

local function vpo(me, preps, raw)
  local right, found_prep
  for i, prep in ipairs(preps) do
    found_prep, right = string.match(raw, "^("..prep..")%s+(%S.*)")
    if found_prep then break end
  end

  if found_prep then
    local arg, all, pick = check_picker(right)
    local results = command_search(me, arg, all, pick)
    return {
      arg2 = arg,
      results2 = results,
      prep = found_prep
    }
  else
    return nil
  end
end

local function vox(me, raw)
  local left, rest = string.match(raw, "(%S+)%s+(%S.*)")
  if left then
    local arg, all, pick = check_picker(left)
    local results = command_search(me, arg, all, pick)
    return {
      arg1 = arg,
      results1 = results,
      arg2 = rest
    }
  else
    return nil
  end
end

local function vo(me, raw)
  if raw == '' then return nil end

  local arg, all, pick = check_picker(raw)
  local results, all_inducing_plural = command_search(me, arg, all, pick)

  return {
    arg1 = arg,
    results1 = results
  }
end

function pattern_match_command(me, c, text)
  local name, rest
  for i, verb in ipairs(c.verbs) do
    if verb == "'" or verb == ';' then
      name, rest = string.match(text, "^("..verb..")%s*(%S?.*)")
    else
      name, rest = string.match(text, "^("..verb..")%s+(.*)")
    end
    if name then break end
    name = string.match(text, "^"..verb.."$")
    rest = ''
    if name then break end
  end
  if not name then return 'no-match' end

  rest = trim(rest)

  local results, final_pattern
  
  for i, pattern in ipairs(c.patterns) do
    final_pattern = pattern
    if pattern == 'vopo' then
      results = vopo(me, c.preps, rest)
      if results then break end
    elseif pattern == 'vopx' then
      results = vopx(me, c.preps, rest)
      if results then break end
    elseif pattern == 'vxpo' then
      results = vxpo(me, c.preps, rest)
      if results then break end
    elseif pattern == 'vpo' then
      results = vpo(me, c.preps, rest)
      if results then break end
    elseif pattern == 'vox' then
      results = vox(me, rest)
      if results then break end
    elseif pattern == 'vo' then
      results = vo(me, rest)
      if results then break end
    elseif pattern == 'vx' then
      if rest ~= '' then
        results = {arg1 = rest}
        break
      end
    elseif pattern == 'v' then
      if rest == '' then
        results = {}
        break
      end
    else
      error("unrecognized command pattern")
    end
  end

  if results then
    results.command = name
    results.pattern = final_pattern
    return 'match', results
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
