require('dialogs/dialog')
require('dialogs/login')
require('stream')

local function take_input(self, input)
  local message = self.input_buffer(input)
  local dialog = self.dialog
  local fd = self.fd
  if message then
    error_message = dialog(message)
    if error_message then
      c_send(fd, error_message)
      c_send(fd, "\n")
      c_kick(fd)
    end
  end
end

local function boot(self)
  self.dialog = start_dialog(self, login_dialog)
end

local function location(self)
  if self.creature then
    return self.creature.location
  else
    error("do not request location when undefined")
  end
end

function mk_player(fd, addr)
  return {
    fd = fd,
    addr = addr,
    account = nil,
    char = nil,
    creature = nil,
    dialog = nil,
    input_buffer = mk_input_buffer(),

    boot = boot,
    take_input = take_input,
    location = location
  }
end

