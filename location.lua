-- {'room', 4}
-- {'bubble', 98}
-- {'creature', 5}


function show_location(loc)
  return loc[1]..':'..loc[2]
end

function db_lookup_location(loc)
  local kind, id = loc[1], loc[2]
  local thing

  if kind == 'room' then thing = db_lookup_room(id)
  elseif kind == 'bubble' then thing = db_lookup_bubble(id)
  elseif kind == 'creature' then thing = db_lookup_creature(id)
  else error('invalid location type '..tostring(kind))
  end

  return kind, thing
end
