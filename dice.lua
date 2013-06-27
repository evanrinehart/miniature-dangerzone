function d6()
  return math.random(6)
end

function yacht()
  local dice = {d6(), d6(), d6(), d6(), d6()}
  local s2 = table.concat(dice)
  local score = 0
  for i, x in ipairs(dice) do
    if x >= 5 then
      score = score + 1
    end
  end
  local s1
  if score == 0 then
    s1 = '-----'
  elseif score == 1 then
    s1 = '+----'
  elseif score == 2 then
    s1 = '++---'
  elseif score == 3 then
    s1 = '+++--'
  elseif score == 4 then
    s1 = '++++-'
  elseif score == 5 then
    s1 = '+++++'
  else
    error("dice bug")
  end

  return score, s1, s2
end
