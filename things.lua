
function ref_eq(ref1, ref2)
  return ref1[1] == ref2[1] and ref1[2] == ref2[2]
end

function mk_thing_ref(kind, id)
  local ref = {kind, id}
  setmetatable(ref, {__eq = ref_eq})
  return ref
end

function mk_room_ref(id)
  return mk_thing_ref('room', id)
end

function mk_creature_ref(id)
  return mk_thing_ref('creature', id)
end

function show_thing_ref(ref)
  return ref[1]..':'..ref[2]
end
