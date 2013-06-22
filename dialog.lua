
-- things to note:
-- dialogs are going to need access to the "my" player
-- dialogs will be more convenient if they have "ask" and "tell"
--   functions installed in their environment by mk_dialog
--   ask:  coroutine.yield
--   tell: c_send to "my" player

local function mk_dialog(f)
  local co = coroutine.create(f)
  assert(coroutine.resume(co, id), "mk_dialog: failed to boot the coroutine")
  return function(input)
    ok, msg = coroutine.resume(co, input)
    if not ok then
      error(msg)
    end
  end
end

local function dummy()
  message = coroutine.yield()
  -- do nothing
  return dummy()
end

local function login()
  -- "name?"
  print("begin login dialog")
  name = coroutine.yield()
print("name = "..name)
  -- "pass?"
  pass = coroutine.yield()
print("pass = "..pass)
  return login()
end

local function debug()
  error("dialog debug currently unimplemented")
end

return {
  new = mk_dialog,
  dummy = dummy,
  login = login,
  debug = debug
}
