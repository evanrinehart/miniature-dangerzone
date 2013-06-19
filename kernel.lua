package.path = package.path .. ";zones/?.lua"

function connect_event(conn_id, addr)
  print("connect_event")
  print(conn_id)
  print(addr)
  -- set up connection
  -- install login dialog
  -- generate id
  -- send greeting
end

function control_event(conn_id, text)
  print("control_event")
  print(conn_id)
  print(text)
  -- use dialog on text
end

function disconnect_event(conn_id)
  print("disconnect_event")
  print(conn_id)
  -- notify things about this
  -- remove connection
end

function wake_event()
  -- check event queue
  return 1000000
end


