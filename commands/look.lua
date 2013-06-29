require('util/misc')

local function location_look(loc, buf)
  local class, id = split_ref(loc)

  if class == 'room' then
    local room = db_find('room', id)
    push(buf, {'yellow', room.name})
    push(buf, room.description)

    for cr in db_creatures_iter(loc) do
      push(buf, {'green', cr.name .. " is here."})
    end
  end
end

local function look(my, target)
  local buf = {}
  location_look(my:location(), buf)
  tell(my, buf)
end

local function parser(s)
  return parse_first_word('look', {'look at', 'look', 'l'}, s)
end

return {
  effect = look,
  parser = parser
}
