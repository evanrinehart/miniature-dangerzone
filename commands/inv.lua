local function inv(me)
  local items = {}
  for item
  in db_item_iter(mk_ref('creature', me.creature.id))
  do table.insert(items, item)
  end

  if next(items) then
    tell(me, "You are carrying:")
    for i, item in ipairs(items) do
      tell(me, item.name)
    end
  else
    tell(me, "you have nothing")
  end
end

return {
  effect = inv,
  usage = "inv or just i",
  patterns = {'v'},
  verbs = {'i', 'inv'},
}
