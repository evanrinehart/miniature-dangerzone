local function dialog_environment(specials)
  local env = {
    error = error,
    assert = assert,
    ipairs = ipairs,
    pairs = pairs,
    next = next,
    select = select,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    unpack = unpack
  }

  env.string = {}
  env.table = {}
  env.math = {}

  env.string.byte = string.byte
  env.string.char = string.char
  env.string.find = string.find
  env.string.format = string.format
  env.string.gmatch = string.gmatch
  env.string.gsub = string.gsub
  env.string.len = string.len
  env.string.lower = string.lower
  env.string.match = string.match
  env.string.rep = string.rep
  env.string.reverse = string.reverse
  env.string.sub = string.sub
  env.string.upper = string.upper
  env.table.insert = table.insert
  env.table.maxn = table.maxn
  env.table.remove = table.remove
  env.table.sort = table.sort
  env.math.abs = math.abs
  env.math.abs = math.abs
  env.math.abs = math.abs
  env.math.abs = math.abs
  env.math.abs = math.abs
  env.math.abs = math.abs
  env.math.abs = math.abs
  env.math.abs = math.abs
  env.math.abs = math.abs

  for name, f in pairs(specials) do
    env[name] = f
  end

  return env
end

local function start(fd, dialog)
  local function ask()
    return coroutine.yield()
  end

  local function tell(text)
    c_send(fd, text)
  end

  local function quit()
    c_kick(fd)
  end

  local function sleep(time_diff)
    -- schedule an event
    -- disable input
    --   in the event, enable input and resume
  end

  local env = dialog_environment({
    ask = ask,
    tell = tell,
    quit = quit,
    sleep = sleep
  })

  setfenv(dialog, env)

  local co = coroutine.create(dialog)

  assert(coroutine.resume(co))

  return function(input)
    assert(coroutine.status(co) == "suspended", "tried to use a crashed dialog")
    ok, err = coroutine.resume(co, input)
    if ok then
      return nil
    else
      return err
    end
  end

end

return {
  start = start
}
