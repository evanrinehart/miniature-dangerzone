function percent_encode(s)
  return string.gsub(s, "[^A-Za-z0-9:-_~.]", function(c)
    return string.format("%%%02x", string.byte(c,1))
  end)
end

function percent_decode(s)
  return string.gsub(s, "%%(%x%x)", function(xx)
    return string.char(tonumber(xx, 16))
  end)
end
