function mk_action(name, kind, say)
  return function()
    return {
      name = name,
      kind = kind,
      say = say,
      ready = true
    }
  end
end

return {
  punch = mk_action('punch', 'attack', 'punches'),
  block = mk_action('block', 'block', 'blocks'),
  dodge = mk_action('dodge', 'dodge', 'dodges'),
  move = mk_action('move', 'move', 'moves'),
  fake = mk_action('fake', 'fake', 'fakes'),
  counter = mk_action('counter', 'counter', 'counters'),
  recover = mk_action('recover', 'recover', 'recovers')
}
