local function target_search(loc, text)
  local pattern = string.match(text, "%S+")

  if pattern == nil then
    return nil
  end

  for cr in db_creatures_iter(loc) do
    if string.find(cr.name, pattern, 1, true) then
      return 'creature', cr
    end
  end

  return nil
end

local function get(me, text)
  local kind, target = target_search(me:location(), text)
  if kind then
    if kind == 'creature' then
      tell(me, "don't try to get "..target.name)
    elseif kind == 'item' then
      --
    else
      tell(me, "better not")
    end
  else
    tell(me, "get what?")
  end
end

local function parser(s0)
  return parse_first_word('get', {'get'}, s0)
end


return {
  effect = get,
  parser = parser
}
