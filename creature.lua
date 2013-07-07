creature_class_table = {}

local creature_files = c_dir('creatures')
local builder
local creature_class
for i, filename in ipairs(creature_files) do
  builder, err = loadfile('creatures/'..filename)
  if builder then
    creature_class = builder()
    creature_class_table[creature_class.class] = creature_class
  else
    error(err)
  end
end

function mk_creature()
  return {
    name = 'unnamed',
    gender = 'none',
    health = 3,
    stamina = 3,
    food = 3,
    alcohol = 3,
    class = nil,
    form = {},
    actions = {
      {'punch'},
      {'dodge'},
      {'recover'}
    },
    in_combat = false
  }
end

function get_creature_class(self)
  assert(self.class_name)
  return creature_class_table[self.class_name]
end

function get_creature_name(self)
  if self.xname then
    return self.xname
  elseif self.class_name then
    return self:class().name
  else
    return "(no name)"
  end
end

