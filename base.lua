-- a database

require('util/set')
require('util/percent')
require('util/misc')
require('util/password')

local database_log_file = nil
local database_log_path = nil


--- storage areas ---
local base = {
  rooms      = {},
  creatures  = {},
  accounts   = {},
  characters = {},
  items      = {},
  bubbles    = {},
  zones      = {}
}

local function multiwrite(tab, keys, value)
  local leaf = tab
  local levels = #keys - 1
  for i, k in ipairs(keys) do
    if i > levels then break end
    if leaf[k] == nil then
      leaf[k] = {}
    end
    leaf = leaf[k]
  end
  leaf[keys[#keys]] = value
end

local function multiread(tab, keys)
  local leaf = tab
  local levels = #keys - 1
  for i, k in ipairs(keys) do
    if i > levels then break end
    if leaf[k] == nil then
      return nil
    end
    leaf = leaf[k]
  end
  return leaf[keys[#keys]]
end

local function index_on(tname, fields)
  return function()
    local field = fields
    local s = {}
    for id, x in pairs(base[tname]) do
      local keys = {}
      for i, field in ipairs(fields) do
        keys[i] = x[field]
      end
      keys[#keys+1] = id

      multiwrite(s, keys, true)
    end
    return s
  end
end

local function unique_index_on(tname, fields)
  return function()
    local s = {}
    for id, x in pairs(base[tname]) do
      local keys = {}
      for i, field in ipairs(fields) do
        keys[i] = x[field]
      end

      if multiread(s, keys) then
        error(string.format("duplicate %s (%s)", tname, id))
      else
        multiwrite(s, keys, id)
      end
    end
    return s
  end
end

local index_rebuild = {
  characters_in_account = index_on('characters', {'account'}),
  creatures_in_things = index_on('creatures', {'location'}),
  usernames = unique_index_on('accounts', {'username'}),
  items_in_things = index_on('items', {'location'}),
  rooms_in_zone = index_on('rooms', {'zone'}),
  zone_names = unique_index_on('zones', {'name'}),
  room_zone_and_code = unique_index_on('rooms', {'zone','code'})
}

local indexes = {}

local function write_index(name, key, id)
  if indexes[name][key] == nil then
    indexes[name][key] = {}
  end

  indexes[name][key][id] = true
end

local function clear_index(name, key, id)
  assert(indexes[name])
  assert(indexes[name][key])
  indexes[name][key][id] = nil
end

local function debug_indexes()
  for name, index in pairs(indexes) do
    print(name..':')
    for key, set in pairs(index) do
      if type(set) == 'table' then
        local buf = {}
        for v in pairs(set) do
          table.insert(buf, v)
        end
        print(key, table.concat(buf, ','))
      else
        print(key, tostring(set))
      end
    end
  end
end

local function rebuild_indexes()
  for name, rebuild in pairs(index_rebuild) do
    ix = rebuild()
    indexes[name] = ix
  end
end


--- id generators ---

local sequences = {}

local function gen_id(kind)
  assert(sequences[kind])
  local id = sequences[kind]+1
  sequences[kind] = sequences[kind]+1
  return id
end

local function load_sequence(kind, id)
  if sequences[kind] == nil or id > sequences[kind] then
    sequences[kind] = id
  end
end

--- modification queue ---
local modification_queue = {}
local we_need_commit = false

local function enqueue_mod(action)
  table.insert(modification_queue, action)
end

local function execute_all_modifications()
  for i, action in ipairs(modification_queue) do
    action()
  end
  modification_queue = {}
end



--- deserialization ---

local item_class = function(self)
  return item_class_table[self.class_name]
end

-- (name, default, decoder)
local structs = {
  rooms = {
    {'name',        '', nil},
    {'description', '', nil},
    {'exits',       {}, nil},
    {'zone',       nil, tonumber},
    {'code',        '', identity}
  },
  creatures = {
    {'name',     'unnamed', percent_decode},
    {'location', nil,       identity},
    {'gender',   'white',   identity},
    {'color',    nil,       identity},
    {'form',     nil,       identity}
  },
  accounts = {
    {'username', '', percent_decode},
    {'password', '', percent_decode}
  },
  characters = {
    {'name',     '',  percent_decode},
    {'account',  nil, tonumber},
    {'creature', nil, tonumber}
  },
  items = {
    {'class_name', '',         identity},
    {'class',      item_class, nil},
    {'location',   nil,        identity},
    {'count',      nil,        tonumber}
  },
  zones = {
    {'name', '', identity}
  }
}

local function data_iter(raw)
  local i, j, def, field, value
  local s, e, pos
  local fields
  pos = 1
  return function()
    s, e, def = string.find(raw, "([^&]+)", pos)
    if s then
      pos = e+1
      field, value = string.match(def, "([^=]+)=([^=]*)")
      if field == nil then return nil end

      fields = {}; j = 1
      for x in string.gmatch(field, "[^.]+") do
        fields[j] = x; j=j+1
      end

      return fields, value

    else
      return nil
    end
  end
end

  
local function read_data(tname, id, raw, line_number)
  local struct = structs[tname]
  local thing
  local decoded_value

  if struct == nil then
    error("load: unknown tname " .. tostring(tname) .. " on " .. line_number)
  end

  load_sequence(tname, id)

  if base[tname][id] == nil then
    thing = {id = id}
    local default

    for i, entry in ipairs(struct) do
      if type(entry[2]) == 'table' then
        default = {}
      else
        default = entry[2]
      end

      thing[entry[1]] = default
    end

    base[tname][id] = thing
  else
    thing = base[tname][id]
  end

  for fields, value in data_iter(raw) do
    for i, entry in ipairs(struct) do
      if entry[1] == fields[1] and entry[3] then
        decoded_value = entry[3](value)
        assert(
          decoded_value ~= nil,
          "invalid value for "..fields[1].." on "..line_number
        )
        if #fields == 1 then
          thing[fields[1]] = decoded_value
        elseif #fields == 2 then
          thing[fields[1]][fields[2]] = decoded_value
        else
          error("load: too deep field name on " .. line_number)
        end
      end
    end
  end
end

local function load_database_from_log(filename)
  local words, i, committed
  local id, id_s
  local drv, tname, data
  local lcount = 1

  for line in io.lines(filename) do
    committed = false

    words = {}; i = 1
    for word in string.gmatch(line, "%S+") do
      words[i] = word; i=i+1
    end

    drv, tname, id_s, data = words[1], words[2], words[3], words[4]
    id = tonumber(id_s)

    if drv == "write" then
      assert(#words == 4, "load: wrong number of words in write directive at " .. lcount)
      if id then
        enqueue_mod(
          defer(
            function(tname, id, data, lcount)
              read_data(tname, tonumber(id), data, lcount)
            end,
            tname, id, data, lcount
          )
        )
      else
        error("load: malformed id at " .. lcount)
      end
    elseif drv == "delete" then
      assert(#words == 3, "load: wrong number of words in delete directive at " .. lcount)
      if id then
        enqueue_mod(
          defer(
            function(tname, id)
              base[tname][id] = nil
            end,
            tname, id
          )
        )
      else
        error("load: malformed id at " .. lcount)
      end
    elseif drv == "commit" then
      assert(#words == 1, "load: extra data in commit directive at " .. lcount)
      execute_all_modifications()
      committed = true
    else
      error("unrecognized directive at "..lcount)
    end

    lcount = lcount + 1
  end

  if committed then
    return "ok"
  else
    return "incomplete"
  end
end

--- serialization ---
local function db_write(...)
  for i, x in ipairs({...}) do
    database_log_file:write(x)
  end
  we_need_commit = true
end

local serializers = {
  rooms = function(room)
    db_write("write rooms ")
    db_write(room.id, " ")
    db_write("zone=", room.zone, "&")
    db_write("code=", room.code, "\n")
  end,

  creatures = function(c)
    db_write("write creatures ")
    db_write(c.id, " ")
    db_write("name=", percent_encode(c.name), "&")
    db_write("location=", c.location, "&")
    db_write("gender=", c.gender, "&")
    db_write("color=", c.color, "&")
    db_write("form=", "\n")
  end,

  accounts = function(a)
    db_write(
      "write accounts ", a.id, " ",
      "username=", percent_encode(a.username), '&',
      "password=", percent_encode(a.password), "\n"
    )
  end,

  characters = function(char)
    db_write(
      "write characters ", char.id, " ",
      "name=", percent_encode(char.name), '&',
      "account=", char.account, '&',
      "creature=", char.creature, "\n"
    )
  end,

  items = function(item)
    db_write(
      "write items ", item.id, " ",
      "location=", item.location, '&',
      "class_name=", item.class_name
    )

    if item.count then
      db_write('&count='..item.count)
    end

    db_write("\n")
  end,

  zones = function(zone)
    db_write("write zones ", zone.id, " name=", zone.name, "\n")
  end
}

local function dump_database(filename)
  assert(
    filename ~= database_log_file_path,
    "attempted to dump database into current working log file"
  )

  local real_log = database_log_file
  database_log_file = io.open(filename, "w")

  for tname, entry in pairs(structs) do
    assert(serializers[tname], "there is no serializer for "..tname)
    local dump = serializers[tname]
    for id, thing in pairs(base[tname]) do
      dump(thing)
    end
  end

  db_write("commit\n")

  database_log_file:close()
  database_log_file = real_log
end

--- data lookup ---
function db_find(tname, id)
  local t = base[tname..'s']
  assert(t, "tname " .. tostring(tname) .. " does not exist")
  return (assert(t[id], tname..' '..tostring(id)..' not found'))
end

function db_ref(loc)
  local kind, id = split_ref(loc)
  assert(kind)
  assert(id)
  return kind, db_find(kind, id)
end

function index_iter(name, id, tname)
  local thing
  local thing_id = nil
  assert(indexes[name], "index does not exist")
  assert(base[tname], "unknown tname")
  local ix = indexes[name][id] or {}

  return function()
    thing_id = next(ix, thing_id)
    if thing_id then
      thing = base[tname][thing_id]
      assert(thing, "index inconsistency")
      return thing
    else
      return nil
    end
  end
end

function db_account_characters_iter(username)
  local aid = indexes.usernames[username]
  assert(aid, "username does not exist")
  return index_iter('characters_in_account', aid, 'characters')
end

function db_creatures_iter(loc)
  return index_iter('creatures_in_things', loc, 'creatures')
end

function db_item_iter(loc)
  return index_iter('items_in_things', loc, 'items')
end

function db_account(username)
  return base.accounts[assert(indexes.usernames[username])]
end

function db_check_account_password(username, password_plain)
  local aid = indexes.usernames[username]
  if aid then
    local acc = base.accounts[aid]
    return acc and acc.password == secure_password(password_plain)
  else
    return false
  end
end

function db_find_zone_by_name(name)
  local id = indexes.zone_names[name]
  if id then
    return base.zones[id]
  else
    return nil
  end
end

function db_dummy_creature()
  return base.creatures[2]
end


--- data modification ---

local broken_linkages = {}

function db_commit()
  assert(database_log_file, "no database log file")
  execute_all_modifications()
  if we_need_commit then
    db_write("commit\n")
    database_log_file:flush()
    we_need_commit = false
  end
end

function db_rollback()
  modification_queue = {}
end

function db_move_creature_to(creature, loc)
  enqueue_mod(function()
    local prev = creature.location
    local cid = creature.id
    clear_index('creatures_in_things', prev, cid)
    write_index('creatures_in_things', loc, cid)
    creature.location = loc
    db_write("write creatures ", cid, ' ', "location=", loc, "\n")
  end)
end

function db_move_item_to(item, loc)
  enqueue_mod(function()
    local prev = item.location
    local id = item.id
    clear_index('items_in_things', prev, id)
    write_index('items_in_things', loc, id)
    item.location = loc
    db_write("write items ", id, " location=", loc, "\n")
  end)
end

function db_create_item(item)
  enqueue_mod(function()
    local id = gen_id('items')
    item.id = id
    item.class = item_class
    base.items[id] = item
    write_index('items_in_things', item.location, id)
    serializers.items(item)
  end)
end

function db_create_zone(zone)
  local id = gen_id('zones')
  zone.id = id
  enqueue_mod(function()
    base.zones[id] = zone
    indexes[zone.name] = id
    serializers.items(item)
  end)
end

function db_modify_count(item, adjustment)
  assert(item.count, "item has no count")
  enqueue_mod(function()
    local net = item.count + adjustment
    if net == 0 then
      base.items[item.id] = nil
      clear_index('items_in_things', item.location, item.id)
      db_write('delete items ', item.id, "\n")
    else
      item.count = net
      db_write('write items ', item.id, ' count=', net, "\n")
    end
  end)
end


--- caching ---

function db_cache_room(room)
  local new = room.id == nil
  local id = room.id or gen_id('rooms')
  room.id = id
  enqueue_mod(function()
    base.rooms[id] = room
    write_index('rooms_in_zone', room.zone, id)
    multiwrite(
      indexes.room_zone_and_code,
      {room.zone, room.code},
      room.id
    )
    if new then
      serializers.rooms(room)
    end
  end)
  return id
end

function db_fix_exits(room, lookup)
  enqueue_mod(function()
    for dir, record in pairs(room.exits) do
      if record.kind == 'normal' then
        room.exits[dir] = lookup[record.code]
      elseif record.kind == 'linkage' then
        local zone = db_find_zone_by_name(record.zone)
        table.insert(broken_linkages, {room, dir, record.linkage})
      end
    end
  end)
end

function db_fix_broken_linkages()
  pp(broken_linkages)
end

-- load a bunch of rooms, create some if necessary
-- and fix their exit links
function db_cache_rooms(zone, pre_rooms)
  local exit_links = {}
  for room in index_iter('rooms_in_zone', zone.id, 'rooms') do
    exit_links[room.code] = 'room:'..room.id
  end

  local rooms = {}
  for i, pre_room in ipairs(pre_rooms) do
    local _, id
    local code = pre_room.code

    if exit_links[code] then
      _, id = split_ref(exit_links[code])
    end

    local room = {
      id = id or nil,
      name = pre_room.name,
      description = pre_room.description,
      code = code,
      exits = pre_room.exits,
      zone = zone.id
    }

    id = db_cache_room(room)

    exit_links[code] = 'room:'..id
    table.insert(rooms, room)
  end

  for i, room in ipairs(rooms) do
    db_fix_exits(room, exit_links)
  end
end




--- maintenance ---

function db_checkpoint()
  c_log("checkpoint requested")
  if database_log_file then
    database_log_file:close()
  end
  local n = #c_dir("data/old/") + 1
  local latest_filename = n .. ".db"
  local latest_path = "data/old/" .. latest_filename
  dump_database(latest_path)
  os.execute("cp " .. database_log_file_path .. " data/paranoid/old-log.db")
  os.execute("cp " .. latest_path .. " " .. database_log_file_path)
  database_log_file = io.open(database_log_file_path, "a")
  c_log("checkpoint complete")
end

function db_begin(working_file)
  database_log_file_path = working_file
  local ok, result = pcall(load_database_from_log, working_file)

  if ok then
    if result == 'incomplete' then
      c_log("o_O recovering from partial writes to database")
      db_rollback()
      db_checkpoint()
    else
      assert(result == 'ok', "return value of load_database_from_log")
    end

    c_log("database loaded")
    c_log("rebuilding indexes...")
    rebuild_indexes()
    c_log("indexes done")
    database_log_file = io.open(working_file, "a")
    c_log("database ready!")

  else
    c_log("!!! database corruption detected")
    error(result)
  end
end

function debug_database()
  pp(base)
  pp(indexes)
end
