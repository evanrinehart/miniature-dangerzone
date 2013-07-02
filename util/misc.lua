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

function trim(s0)
  local s1 = string.gsub(s0, "^%s+", "")
  return string.gsub(s1, "%s+$", "")
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

function show_number(n, max)
  if n < 10 then
    return ({
      'one', 'two', 'three', 'four', 'five',
      'six', 'seven', 'eight', 'nine'
    })[n]
  elseif n > max then
    return 'a lot of'
  else
    return n
  end
end

function not_found(what)
  return "I do not see "..what.." here"
end

function creature_color(cr)
  if cr.gender == 'none' then return 'green' end
  if cr.gender == 'female' then return 'magenta' end
  if cr.gender == 'male' then return 'cyan' end
  if cr.gender == 'root' then return 'yellow' end
  return 'white'
end
