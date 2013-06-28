function create_character_dialog(me)
  tell(me, "you are about to create a character")
  tell(me, "now what? ")
  ask()
  -- create character in database
  return -- goes back to pick_character_dialog
end

