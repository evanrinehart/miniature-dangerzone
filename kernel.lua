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
  local now = c_clock()

  the_event_queue.each_ready_event(now, function(e)
    print("an event happened?!")
  end)

  return the_event_queue.next_time()
end


