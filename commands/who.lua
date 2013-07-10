require ('util/tabular')

local function who(me, args)
  local cols = {
    {
      width=60,
      align='left'
    },
    {
      divider='|',
      width=10,
      align='right'
    }
  }

  local rows = {
    {{text='abc'},{text='123'}},
    'divider',
    {{text='ooo'},{text='5', color='red'}},
    {{text='1234567'},{text='33'}}
  }

  local data = tabular(rows, cols)

  tell_pref(me, data)
end

return {
  effect   = who,
  usage    = "who by itself",
  patterns = {'v'},
  verbs    = {'who'}
}
