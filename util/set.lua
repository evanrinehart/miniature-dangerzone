function mk_set(list)
  local s = {}
  for i, x in ipairs(list) do
    s[x] = true
  end
  return s
end
