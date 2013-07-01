item_class_table = {}

local item_files = c_dir('items')
local builder
local item_class
for i, filename in ipairs(item_files) do
  builder, err = loadfile('items/'..filename)
  if builder then
    item_class = builder()
    item_class_table[item_class.class] = item_class
  else
    error(err)
  end
end
