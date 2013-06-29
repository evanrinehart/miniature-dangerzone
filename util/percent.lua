function percent_encode(s)
  return string.gsub(s, "[^A-Za-z0-9]", function(c)
    return string.format("%%%02x", c)
  end)
end

function percent_decode(s)
  return string.gsub(s, "%%(%x%x)", function(xx)
    return string.char(tonumber(xx, 16))
  end)
end
