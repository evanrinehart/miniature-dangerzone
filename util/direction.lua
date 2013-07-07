local dirs = {
  e = 'e',
  east = 'e',
  w = 'w',
  west = 'w',
  n = 'n',
  north = 'n',
  s = 's',
  south = 's',
  u = 'u',
  up = 'u',
  d = 'd',
  down = 'd'
}

local dir_names = {
  e = 'east',
  w = 'west',
  u = 'up',
  d = 'down',
  n = 'north',
  s = 'south'
}

local negate = {
  e = 'w',
  w = 'e',
  n = 's',
  s = 'n',
  u = 'd',
  d = 'u'
}

function normalize_dir(s)
  return dirs[s]
end

function dir_name(d)
  return dir_names[d]
end

function opposite_dir(d)
  return negate[d]
end
