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


local rooms = {
  [1] = {
    id = 1,
    zone = nil,
    exits = {},
    description = "A blank room with nothing all around.",
    name = "Dummy room"
  }
}

local creatures = {
  [1] = {
    id = 1,
    form = {},
    names = {'creature'},
    location = {'room', 1}
  }
}

local characters = {
  [1] = {
    id = 1,
    names = {'barfos'},
    account = 'barfos',
    status = nil,
    creature = 1
  }
}

local accounts = {
  barfos = {
    username = 'barfos',
    password = 'pass'
  }
}

local tables = {
  rooms = rooms,
  creatures = creatures,
  characters = characters,
  accounts = accounts
}

function db_find(tab, key)
  return (assert(tables[tab][key], "data anomaly, record not found, "..tab..':'..key))
end

function db_check_account_password(username, password)
  acc = accounts[username]
  return acc and acc.password == password
end
    

