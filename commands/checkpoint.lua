return {
  effect = function(me)
    db_checkpoint()
  end,
  usage = "checkpoint (one word)",
  patterns = {'v'},
  verbs = {'checkpoint'}
}
