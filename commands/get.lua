local function target_search(loc, text)
  local pattern = trim(text)

  if pattern == '' then
    return nil
  end

  for item in db_item_iter(loc) do
    if pattern == item.name then
      return 'item', item
    end
  end

  for cr in db_creatures_iter(loc) do
    if string.find(cr.name, pattern, 1, true) then
      return 'creature', cr
    end
  end

  return nil
end

local function get(me, text)
  local kind, thing = target_search(me:location(), text)
  if kind then
    if kind == 'creature' then
      tell(me, "don't try to get "..thing.name)
    elseif kind == 'item' then
      db_move_item_to(thing, mk_ref('creature', me.creature.id))
      db_commit()
      tell(me, "taken")
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
