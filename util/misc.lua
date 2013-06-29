function push(t, x)
  t[#t + 1] = x
end

function increment(t, field)
  if t[field] == nil then
    t[field] = 1
  else
    t[field] = t[field] + 1
  end
end

function identity(x)
  return x
end

function mk_ref(x, y)
  return x .. ':' .. y
end

function split_ref(ref)
  local kind, id = string.match(ref, "([^:]+):(%d+)")
  return kind, tonumber(id)
end

function defer(f, ...)
  local args = {...}
  return function()
    return f(unpack(args))
  end
end