package.path = package.path .. ""

require('events')

function connect_signal(conn_id, addr)
  print("connect_signal")
  print(conn_id)
  print(addr)
  -- set up connection
  -- install login dialog
  -- generate id
  -- send greeting
end

function control_signal(conn_id, text)
  print("control_signal")
  print(conn_id)
  print(text)
  -- use dialog on text
end

function disconnect_signal(conn_id)
  print("disconnect_signal")
  print(conn_id)
  -- notify things about this
  -- remove connection
end

function wake_signal()
  -- check event queue
  return 1000000
end


