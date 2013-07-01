require('util/misc')

local function location_look(loc, args)
  local class, id = split_ref(loc)

  if class == 'room' then
    local room = db_find('room', id)
    push(buf, {'yellow', room.name})
    push(buf, room.description)

    for cr in db_creatures_iter(loc) do
      push(buf, {'green', cr.name .. " is here."})
    end

    for item in db_item_iter(loc) do
      push(buf, {'bright-black', item.name, " is here."})
    end
  end
end

local function look(me, args)
  local buf = {}
--  location_look(me:location(), buf)
--  tell(me, buf)
end

return {
  effect = look,
  usage = "look, look at <something>, look in <something>",
  patterns = {'vpo', 'v'},
  verbs = {'l', 'look'},
  preps = {'at', 'in'}
}
