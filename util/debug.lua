function pp(v)
  local pt
  local pv

  pv = function(l, v)
    local my_type = type(v)
    if my_type == 'table' then
      if next(v) then
        pt(l, v)
      else
        io.write("{}")
      end
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
      io.write(tostring(k))
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

