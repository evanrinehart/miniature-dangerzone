-- a database

-- rooms      (id, zone, exits, description, name)
-- bubbles    (id, contents, description, location)
-- creatures  (id, form, names, location)
-- characters (id, names, account, status, creature)
-- accounts   (username, password, disabled)
-- items      (id, class, properties, location)
-- cities     (id, location, size, names, status)
-- countries  (id, name, capital, ruler, status, lingo)
-- world      (coord, terrain, status, country, special)
-- structures (id, location, portal)
-- history    (seq, date, description)
-- zones      (id, author, description)

-- indexes
-- account -> characters

require('util/set')

local rooms = {
  [1] = {
    id = 1,
    zone = nil,
    exits = {
      e = {'room', 2}
    },
    description = "A blank room with nothing all around.",
    name = "Dummy Room"
  },
  [2] = {
    id = 2,
    zone = nil,
    exits = {
      w = {'room', 1}
    },
    name = "The Other Room",
    description = "This is the room besides the dummy room."
  }
}

local std = require('actions')

local creatures = {
  [1] = {
    id = 1,
    form = {},
    name = 'barfos',
    location = {'room', 1},
    advantage = 0,
    actions = {
      std.punch(),
      std.punch(),
      std.block(),
      std.recover(),
      std.counter()
    }
  },
  [2] = {
    id = 2,
    form = {},
    name = 'dummy',
    location = {'room', 1},
    advantage = 0,
    actions = {
      std.punch(),
      std.punch(),
      std.block(),
      std.recover(),
      std.counter()
    }
  }
}

local characters = {
  [1] = {
    id = 1,
    name = 'barfos',
    account = 'barfos',
    status = nil,
    creature_id = 1
  },
  [2] = {
    id = 2,
    name = 'dummy',
    account = 'barfos',
    status = nil,
    creature_id = 2
  }
}

local accounts = {
  barfos = {
    username = 'barfos',
    password = 'pass'
  }
}

local characters_in_account = {
  barfos = mk_set({1, 2})
}

local creatures_in_things_index = {
  ["room:1"] = mk_set({1, 2}),
  ["room:2"] = mk_set({})
}

function show_thing_ref(ref)
  return ref[1]..':'..ref[2]
end

local function use_index(index, target, key)
  local results = {}
  local i = 1
  for id in pairs(index[key]) do
    results[i] = target[id]
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
  local sref = show_thing_ref(loc)
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

function db_move_creature_to(creature, loc)
  local prev = creature.location
  local cid = creature.id
  creatures_in_things_index[show_thing_ref(prev)][cid] = nil
  creatures_in_things_index[show_thing_ref(loc)][cid] = true
  creature.location = loc
end
