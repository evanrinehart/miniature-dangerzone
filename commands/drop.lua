require('gold')

local function drop(me, args)
  if args.pattern == 'vo' then
    if gold_commands.detect(me, args) then
      gold_commands.drop(me, args)
      return
    end

    local items = args.results1.items_held
    local here = me:location()
    if #items == 0 then
      tell(me, "you don't have it")
    else
      local drops
      if args.results1.all then
        drops = items
      else
        drops = {items[1]}
      end
      for i, item in ipairs(drops) do
        db_move_item_to(item, here)
        tell(me, item:class().single.." dropped")
      end
      db_commit()
    end
  else
    tell(me, "not implemented")
  end
end

return {
  effect   = drop,
  usage    = "drop <something>, drop <something> in/on/off <something>",
  patterns = {'vopo', 'vo'},
  verbs    = {'drop'},
  preps    = {'in', 'on', 'off'}
}
