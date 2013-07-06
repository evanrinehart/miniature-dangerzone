require('util/misc')

local function look_around(me, args)
  local loc = me:location()
  local kind, id = split_ref(loc)

  if kind == 'room' then
    local room = db_find('room', id)
    tell(me, room.name, 'yellow')
    tell(me, room.description, 'wrap')

    for cr in db_creatures_iter(loc) do
      if cr.id ~= me.creature.id then
        tell(me, cr.name .. " is here.", cr.color)
      end
    end

    local item_groups = {}
    for item in db_item_iter(loc) do
      local cl = item:class()
      local single = cl.single
      local plural = cl.plural
      local key = single..','..plural
      local rec = item_groups[key]
      if rec then
        rec.counter = rec.counter + 1
      else
        item_groups[key] = {
          counter = 1,
          class = cl
        }
      end
    end

    for k, rec in pairs(item_groups) do
      local text
      if rec.counter == 1 then
        text = rec.class.single
      else
        text = show_number(rec.counter, 27) .. ' ' .. rec.class.plural
      end
      tell(me, text, 'gray')
    end
  end
end

local function look_at(me, args)
  local items = args.results2.items
  local creatures = args.results2.creatures_or_self
  local decorations = args.results2.decorations
  if next(items) then
    tell(me, "it is " .. items[1]:class().single)
  elseif next(creatures) then
    tell(me, "it is "..creatures[1].name)
  elseif next(decorations) then
    tell(me, "you look at it")
  else
    tell(me, not_found(args.arg2))
  end
end

local function look_in(me, args)
  -- FIXME
  tell(me, "don't look in that")
end

local function look(me, args)
  tell(me, '')
  if args.arg2 then
    if args.prep == 'at' then
      look_at(me, args)
    elseif args.prep == 'in' then
      look_in(me, args)
    else
      error(tostring(args.prep) .. '?')
    end
  else
    look_around(me, args)
  end
  tell(me, '')
end

return {
  effect = look,
  usage = "look, look at <something>, look in <something>",
  patterns = {'vpo', 'v'},
  verbs = {'l', 'look'},
  preps = {'at', 'in'}
}
