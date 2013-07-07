
local function parse_exits(raw, my_code)
  local exits = {}

  if raw == '(no exits)' then return {} end

  local lines = split_lines(raw)
  for i, line in ipairs(lines) do
    local dir, rest = string.match(line, "^([nsewud]):%s+(%S.*)")

    if not dir then error(my_code.." invalid exit line (dir)") end

    rest = trim(rest)

    local zone, linkage = string.match(rest, "^linkage (%S+) (%S+)")
    if zone then
      exits[dir] = {kind='linkage', zone=zone, linkage=linkage}
    else
      local code = string.match(rest, "^(%S+)")
      if code then
        exits[dir] = {kind='normal', code=code}
      else
        error(my_code.." invalid exit line (params)")
      end
    end
  end

  return exits
end

local function parse_description(raw)
  local raw_paragraphs = split_on(raw, "\r?\n\r?\n")
  local paragraphs = {}
  for i, rp in ipairs(raw_paragraphs) do
    local p = string.gsub(rp, "\r?\n", " ")
    table.insert(paragraphs, "  "..p)
  end
  return table.concat(paragraphs, "\n")
end

local function load_room(zone, code)
  local path = 'zones/'..zone.name..'/rooms/'..code
  local file = io.open(path)
  local raw = file:read('*a')
  file:close()
  local block_a, block_b = split(raw, "\r?\n\r?\n\r?\n")

  if not block_a then error("room file "..code.." must contain a triple newline") end

  local name, raw_description = split(block_a, "\r?\n\r?\n")

  if not block_a then error("block A must contain at least two sections") end

  description = parse_description(raw_description)

  local exits_raw, rest = split(block_b, "\r?\n\r?\n")
  
  if not exits_raw then
    exits_raw = trim(block_b)
  end

  local exits = parse_exits(exits_raw, code)

  return {
    code = code,
    zone = zone.id,
    exits = exits,
    name = name,
    description = description
  }  
end

function load_zone(name)
  local zone = db_find_zone_by_name(name)
  if not zone then
    zone = {
      name = name
    }

    db_create_zone(zone)
  end

  local rooms_path = 'zones/'..name..'/rooms/'
  local room_filenames = c_dir(rooms_path)
  local rooms = {}
  for i, filename in ipairs(room_filenames) do
    local pre_room = load_room(zone, filename)
    table.insert(rooms, pre_room)
  end

  local broken_linkages = db_cache_rooms(zone, rooms)
  return broken_linkages
end

function reload_room(room)
  local code = room.code
  local zone = db_find_zone(room.zone)
  local pre_room = load_room(zone, code)
  db_cache_rooms({pre_room})
end

local function readfile(path)
  local file = io.open(path)
  if file then
    local text = file:read('*a')
    file:close()
    return string.gsub(text, "\r?\n$", '')
  else
    return nil
  end
end

function autoload_zones()
  local zone_names = c_dir('zones/')
  for i, name in ipairs(zone_names) do
    local autoload = readfile('zones/'..name..'/config/autoload')
    if autoload == 'yes' then
      local ok, err = pcall(load_zone, name)
      if ok then
        db_commit()
      else
print("failed to autoload zone "..name..": "..err)
        db_rollback()
      end
    end
  end
end
