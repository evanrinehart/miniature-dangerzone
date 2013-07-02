local function detect(me, args)
  local raw = string.match(args.arg1, "^(-?%d+)%s+gold")
  if raw then return tonumber(raw) else return nil end
end
-- drop 9 gold in pit
local function drop(me, args)
  local count = detect(me, args)

  if not count or count <= 0 then
    tell(me, "please give a positive number")
    return
  end

  local results = command_search(me, "bag of gold")
  local mother = results.items_held[1]

  if not mother or mother.count - count < 0 then
    tell(me, "if you only had that much")
  else
    local bag = {
      class_name = 'gold_bag',
      count = count,
      location = me:location()
    }

    db_create_item(bag)
    db_modify_count(mother, -count)
    db_commit()
    tell(me, string.format("you drop a bag of %d gold coins", count))
  end
end

-- put 10 gold in box
local function put(me, args)
end

-- give 10 gold to blork
local function give(me, args)
end


gold_commands = {
  detect = detect,
  drop = drop,
  put = put,
  give = give,
}
