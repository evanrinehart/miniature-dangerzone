require ('util/tabular')

local function who(me, args)
  local cols = {
    {
      width=20,
      align='left'
    },
    {
      width=30,
      align='right'
    }
  }

  local rows = {}

  for pl in players_iter() do
    if pl.creature then
      local cr = pl.creature
      local kind, place = db_ref(cr.location)
      table.insert(rows, {
        {
          text=cr:name(),
          color=cr.color
        },
        {
          text=place.name
        }
      })
    end
  end

  local data = tabular(rows, cols)

  tell(me, "Players currently online:")
  tell(me, '')
  if #rows > 0 then
    tell_pref(me, data)
  else
    tell(me, "Nobody!")
  end
  tell(me, '')
end

return {
  effect   = who,
  usage    = "who by itself",
  patterns = {'v'},
  verbs    = {'who'}
}
