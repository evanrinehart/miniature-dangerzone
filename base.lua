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
  bubbles    = {}
}

local function index_on(tname, field, encode)
  return function()
    local s = {}
    for id, x in pairs(base[tname]) do
      local key = encode(x[field])
      if s[key] == nil then
        s[key] = {}
      end
      s[key][id] = true
    end
    return s
  end
end

local function unique_index_on(tname, field, encode)
  return function()
    local s = {}
    for id, x in pairs(base[tname]) do
      local key = encode(x[field])
      if s[key] == nil then
        s[key] = id
      else
        error(string.format("duplicate %s %s (%s)",tname, field, x[field]))
      end
    end
    return s
  end
end

local index_rebuild = {
  characters_in_account = index_on('characters', 'account', identity),
  creatures_in_things = index_on('creatures', 'location', identity),
  usernames = unique_index_on('accounts', 'username', identity),
  items_in_things = index_on('items', 'location', identity)
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


--- modification queue ---
local modification_queue = {}

local function enqueue_mod(action)
  table.insert(modification_queue, action)
end

local function execute_all_modifications()
  for i, action in ipairs(modification_queue) do
    action()
  end
  modification_queue = {}
end


--- debug --

local function debug_rooms()
  print('rooms:')

  local function show_exits(exits)
    local buf = {}
    for d, ref in pairs(exits) do
      table.insert(buf, d)
    end
    return table.concat(buf)
  end

  for id, room in pairs(base.rooms) do
    print(id, room.name, show_exits(room.exits))
  end
end

local function debug_creatures()
  print('creatures:')

  for id, c in pairs(base.creatures) do
    print(id, c.name, c.location)
  end
end



--- deserialization ---

-- (name, default, decoder)
local structs = {
  rooms = {
    {'name',        '', percent_decode},
    {'description', '', percent_decode},
    {'exits',       {}, identity},
    debug = debug_rooms
  },
  creatures = {
    {'name',     'unnamed', percent_decode},
    {'location', nil,       identity},
    {'form',     nil,       identity},
    debug = debug_creatures
  },
  accounts = {
    {'username', '', percent_decode},
    {'password', '', percent_decode}
  },
  characters = {
    {'name',      '', percent_decode},
    {'account',  nil, tonumber},
    {'creature', nil, tonumber}
  },
  items = {
    {'name',     '',  percent_decode},
    {'class',    '',  percent_decode},
    {'location', nil, identity}
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
      if entry[1] == fields[1] then
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
end

local serializers = {
  rooms = function(room)
    db_write("write rooms ")
    db_write(room.id, " ")
    db_write("zone=&")
    for d, ref in pairs(room.exits) do
      db_write("exits.",d,"=", ref, "&")
    end
    db_write("description=", percent_encode(room.description), "&")
    db_write("name=", percent_encode(room.name), "\n")
  end,

  creatures = function(c)
    db_write("write creatures ")
    db_write(c.id, " ")
    db_write("name=", percent_encode(c.name), "&")
    db_write("location=", c.location, "&")
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
      "name=", percent_encode(item.name), '&',
      "location=", item.location, '&',
      "class=", item.class, "\n"
    )
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

function db_dummy_creature()
  return base.creatures[2]
end


--- data modification ---

function db_commit()
  assert(database_log_file, "no database log file")
  execute_all_modifications()
  db_write("commit\n")
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
    db_write("write items ", id, ' ', "location=", loc, "\n")
  end)
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

debug_indexes()
  else
    c_log("!!! database corruption detected")
    error(result)
  end
end

