require('dialog')
require('stream')
require('login')

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

function mk_player(fd, addr)
  return {
    fd = fd,
    addr = addr,
    char = nil,
    dialog = nil,
    input_buffer = mk_input_buffer(),

    boot = boot,
    take_input = take_input
  }
end

