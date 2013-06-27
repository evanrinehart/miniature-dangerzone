local function location_look(loc)
  local class, id = loc[1], loc[2]

  if class == 'room' then
    local room = db_find_room(id)
    return table.concat({
      room.name,"\n",
      room.description,"\n"
      
    })
  elseif class == 'bubble' then
    return "bubble\n"
  else
    return "unknown location type\n"
  end
end

local function look(me, target)
  --
  -- if target is blank
  tell(me, location_look(me:location()))
end

local function parser(s)
  return parse_first_word('look', {'look at', 'look', 'l'}, s)
end

return {
  effect = look,
  parser = parser
}
