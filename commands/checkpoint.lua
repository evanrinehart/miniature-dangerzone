return {
  effect = function(me)
    db_checkpoint()
    tell(me, "done")
  end,
  usage = "checkpoint (one word)",
  patterns = {'v'},
  verbs = {'checkpoint'}
}
