local function mono_command_parser(word)
  return function(s0)
    return parse_first_word(word, {word}, s0)
  end
end

return {
  effect = function(me)
    db_checkpoint()
  end,
  parser = mono_command_parser('checkpoint')
}
