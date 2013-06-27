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


local rooms = {
  [1] = {
    id = 1,
    zone = nil,
    exits = {},
    description = "A blank room with nothing all around.",
    name = "Dummy Room"
  }
}

local std = require('actions')

local creatures = {
  [1] = {
    id = 1,
    form = {},
    name = 'barfos',
    location = {'room', 1},
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
  }
}

local accounts = {
  barfos = {
    username = 'barfos',
    password = 'pass'
  }
}

local characters_in_account = {
  barfos = {1}
}

local things_in_things_index = {
}

local function use_index(index, target, key)
  local results = {}
  for k, v in ipairs(index[key]) do
    results[k] = target[v]
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
