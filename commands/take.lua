local function take_here(me, args)
  local items = args.results1.items_here
  if args.results1.all then
    for i, item in ipairs(items) do
      db_move_item_to(item, me:self_ref())
      tell_room2(
        me:location(),
        me.creature,
        mk_msg("taken ("..item:class().single..")"),
        mk_msg(string.format("%s takes %s", me.creature:name(), item:class().single))
      )
    end
    db_commit()
  else
    local item = items[1]
    local item_count = #items
    db_move_item_to(item, me:self_ref())
    db_commit()
    if item_count > 1 then
      tell_room2(
        me:location(),
        me.creature,
        mk_msg("taken ("..item:class().single..")"),
        mk_msg(string.format("%s takes %s", me.creature:name(), item:class().single))
      )
    else
      tell_room2(
        me:location(),
        me.creature,
        mk_msg("taken"),
        mk_msg(string.format("%s takes %s", me.creature:name(), item:class().single))
      )
    end
  end
end

local function take_from_container(me, args)
  tell(me, "not yet implemented")
end

local function take_bloopers(me, args)
  local cr = args.results1.creatures_or_self[1]
  if cr.id == me.creature.id then
    tell(me, "you don't get yourself")
  else
    tell(me, "don't try to get "..cr:name())
  end
end

local function take(me, args)
  if args.arg2 then
    take_from_container(me, args)
  elseif #args.results1.items_here > 0 then
    take_here(me, args)
  elseif #args.results1.creatures_or_self > 0 then
    take_bloopers(me, args)
  else
    tell(me, not_found(args.arg1))
  end
end

return {
  effect   = take,
  usage    = "take/get <something>, take/get <something> from <something>",
  patterns = {'vopo', 'vo'},
  verbs    = {'take', 'get'},
  preps    = {'from', 'out of'}
}
