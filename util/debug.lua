function pp(v)
  local pt
  local pv

  pv = function(l, v)
    if type(v) == 'table' then
      if next(v) then
        pt(l, v)
      else
        io.write("{}")
      end
    elseif type(v) == 'string' and tonumber(v) ~= nil then
      io.write('"'..tostring(v)..'"')
    else
      io.write(tostring(v))
    end
  end

  pt = function(l, t)
    local indent0 = string.rep('  ', l-1)
    local indent = indent0 .. '  '
    io.write("{\n")
    for k, v in pairs(t) do
      io.write(indent)
      if(type(k) == 'string' and tonumber(k) ~= nil) then
        io.write('"'..tostring(k)..'"')
      else
        io.write(tostring(k))
      end
      io.write(' => ')
      pv(l+1, v)
      io.write("\n")
    end
    io.write(indent0)
    io.write('}')
  end

  pv(1, v)
  io.write("\n")

end

function pps(v)
  local pt
  local pv
  local buf = {}
  local write = function(x)
    table.insert(buf, x)
  end

  pv = function(l, v)
    local my_type = type(v)
    if my_type == 'table' then
      if next(v) then
        pt(l, v)
      else
        write("{}")
      end
    else
      write(tostring(v))
    end
  end

  pt = function(l, t)
    local indent0 = string.rep('  ', l-1)
    local indent = indent0 .. '  '
    write("{\n")
    for k, v in pairs(t) do
      write(indent)
      write(tostring(k))
      write(' => ')
      pv(l+1, v)
      write("\n")
    end
    write(indent0)
    write('}')
  end

  pv(1, v)
  write("\n")

  return table.concat(buf)
end
