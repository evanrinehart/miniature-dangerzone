require('util/misc')

local function location_look(loc, buf)
  local class, id = loc[1], loc[2]

  if class == 'room' then
    local room = db_find_room(id)
    push(buf, {'yellow', room.name})
    push(buf, room.description)

    for_each_creature_in(loc, function(c)
      push(buf, {'green', c.name .. " is here."})
    end)
  elseif class == 'bubble' then
  else
  end
end

local function look(my, target)
  local buf = {}
  location_look(my:location_ref(), buf)
  tell(my, buf)
end

local function parser(s)
  return parse_first_word('look', {'look at', 'look', 'l'}, s)
end

return {
  effect = look,
  parser = parser
}
