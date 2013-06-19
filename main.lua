package.path = package.path .. ";zones/?.lua"

function connect_event(conn_id, addr)
  # set up connection
  # install login dialog
  # generate id
  # send greeting
end

function control_event(conn_id, text)
  # use dialog on text
end

function disconnect_event(conn_id)
  # notify things about this
  # remove connection
end

function watchdog_event()
  # check event queue
end


