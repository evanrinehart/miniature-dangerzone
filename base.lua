-- a database

require('util/set')
require('util/percent')
require('util/misc')

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

local function index_on(t1, field, encode)
  return function()
    local s = {}
    for id, x in pairs(base[t1]) do
      local key = encode(x[field])
      if s[key] == nil then
        s[key] = {}
      end
      s[key][id] = true
    end
    return s
  end
end

local index_rebuild = {
  characters_in_account = index_on('characters', 'account', identity),
  creatures_in_things = index_on('creatures', 'location', show_ref)
}

local indexes = {}

local function debug_indexes()
  for name, index in pairs(indexes) do
    print(name..':')
    for key, set in pairs(index) do
      local buf = {}
      for v in pairs(set) do
        table.insert(buf, v)
      end
      print(key, table.concat(buf, ','))
    end
  end
end

local function rebuild_indexes()
  for name, rebuild in pairs(index_rebuild) do
    ix = rebuild()
    indexes[name] = ix
  end
end

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
    print(id, c.name, show_ref(c.location))
  end
end



--- deserialization ---

local function decode_ref(raw)
  local kind, id = string.match(raw, "([^_]+)_(%d+)")
  if kind and id then
    return {kind, id}
  else
    error("load: decode ref failure")
  end
end

-- (name, default, decoder)
local structs = {
  rooms = {
    {'name',        '', percent_decode},
    {'description', '', percent_decode},
    {'exits',       {}, decode_ref},
    debug = debug_rooms
  },
  creatures = {
    {'name',     'unnamed', percent_decode},
    {'location', nil,       decode_ref},
    {'form',     nil,       identity},
    debug = debug_creatures
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
        if #fields == 1 then
          thing[fields[1]] = entry[3](value)
        elseif #fields == 2 then
          thing[fields[1]][fields[2]] = entry[3](value)
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
        read_data(tname, tonumber(id), data, lcount)
      else
        error("load: malformed id at " .. lcount)
      end
    elseif drv == "delete" then
      assert(#words == 3, "load: wrong number of words in delete directive at " .. lcount)
      if id then
        base[tname][id] = nil
      else
        error("load: malformed id at " .. lcount)
      end
    elseif drv == "commit" then
      assert(#words == 1, "load: extra data in commit directive at " .. lcount)
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

local function encode_ref(ref)
  return ref[1] .. "_" .. ref[2]
end

local function write_room(room)
  db_write("write rooms ")
  db_write(room.id, " ")
  db_write("zone=&")
  for d, ref in pairs(room.exits) do
    db_write("exits.",d,"=", encode_ref(ref), "&")
  end
  db_write("description=", percent_encode(room.description), "&")
  db_write("name=", percent_encode(room.name), "\n")
end

local function write_creature(c)
  db_write("write creatures ")
  db_write(c.id, " ")
  db_write("name=", percent_encode(c.name), "&")
  db_write("location=", encode_ref(c.location), "&")
  db_write("form=", "\n")
end

local function dump_database(filename)
  assert(
    filename ~= database_log_file_path,
    "attempted to dump database into current working log file"
  )

  local real_log = database_log_file
  database_log_file = io.open(filename, "w")

  for _, x in pairs(base.rooms)     do write_room(x)     end
  for _, x in pairs(base.creatures) do write_creature(x) end
  db_write("commit\n")

  database_log_file:close()
  database_log_file = real_log
end

--- data lookup ---
local function use_index(index, target, key)
  local results = {}
  local i = 1
  for id in pairs(indexes[index][key]) do
    results[i] = base[target][id]
    i = i + 1
  end
  return results
end

function db_check_account_password(username, password)
  acc = accounts[username]
  return acc and acc.password == password
end

function db_get_account_chars(username)
  return use_index(characters_in_account, characters, username)
end

function db_find_creature(id)
  return (assert(creatures[id], "creature "..id.." not found"))
end

function db_find_room(id)
  return (assert(rooms[id], "room not found"))
end

function db_dummy_creature()
  return creatures[2]
end

function for_each_creature_in(loc, f)
  local sref = encode_ref(loc)
  local creature_ids_set = creatures_in_things_index[sref]
  for id in pairs(creature_ids_set) do
    f(db_find_creature(id))
  end
end

function db_lookup_location(loc)
  local kind, id = loc[1], loc[2]
  local thing

  if kind == 'room' then thing = db_find_room(id)
  elseif kind == 'bubble' then thing = db_find_bubble(id)
  elseif kind == 'creature' then thing = db_find_creature(id)
  else error('invalid location type '..tostring(kind))
  end

  return kind, thing
end


--- data modification ---
function db_move_creature_to(creature, loc)
  local prev = creature.location
  local cid = creature.id
  creatures_in_things_index[encode_ref(prev)][cid] = nil
  creatures_in_things_index[encode_ref(loc )][cid] = true
  creature.location = loc
end

function db_commit()
  assert(database_log_file, "no database log file")
  -- for this to help us at runtime, we need to be able to rollback
  database_log_file.write("commit\n")
end




--- maintenance ---

function db_begin(working_file)
  database_log_file_path = working_file
  local ok, result = pcall(load_database_from_log, working_file)

  if ok then
    if result == 'incomplete' then
      c_log("o_O recovering from partial writes to database\n")
      checkpoint()
    else
      assert(result == 'ok', "return value of load_database_from_log")
    end

    c_log("database loaded\n")
    c_log("rebuilding indexes...\n")
    rebuild_indexes()
    c_log("indexes done\n")
    database_log_file = io.open(working_file, "a")
    c_log("database ready!\n")
  else
    c_log("!!! database corruption detected\n")
    error(result)
  end
end

function checkpoint()
  if database_log_file then
    database_log_file:close()
  end
  local n = #c_dir("data/old/") + 1
  local latest_filename = n .. ".db"
  local latest_path = "data/old/" .. latest_filename
  dump_database(latest_path)
  os.execute("cp data/world.db data/paranoid/old-log.db")
  os.execute("cp " .. latest_path .. " data/world.db")
  database_log_file = io.open("data/world.db", "a")
end
