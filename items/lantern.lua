return {
  class = "lantern",
  single = "a lantern",
  plural = "lanterns",
  aliases = {'lantern', 'lamp'},
  plural_aliases = {'lanterns', 'lamps'},
  use = function(me)
    tell(me, "you hold up the lantern to get a better look")
  end
}
