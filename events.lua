local Queue = require('queue')

local function mk_event(time, payload, id)
  return {
    id = id,
    time = time,
    data = payload
  }
end

local function compare_event(e2, e1)
  return e2.time - e1.time
end

local function show_event(e)
  return table.concat({"event(",e.id,",",e.time,",","(data)",")"})
end

local function event_id(e)
  return e.id
end

local queue = Queue.new(compare_event, event_id, show_event)
local id_counter = 0

local function next_time()
  local e = queue.peek()
  if e == nil then
    return nil
  else
    return e.time
  end
end

local function each_ready_event(now, f)
  local t = next_time
  if t and t <= now then
    local e = queue.take()
    f(e)
    each_ready_event(now, f)
  end
end

local function schedule(data, time)
  local e = mk_event(time, data, id)
  id = id + 1
  queue.insert(e)
end

local function debug()
  queue.debug()
end

the_event_queue = {
  next_time = next_time,
  each_ready_event = each_ready_event,
  schedule = schedule,
  debug = debug
}
