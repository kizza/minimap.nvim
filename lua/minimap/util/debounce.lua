local Object = require("nui.object")
local Debounce = Object("MinimapCache")

function Debounce:init()
  self._ = {
    timer = vim.uv.new_timer(),
    first_run = true,
  }
end

function Debounce:run(delay, callback)
  if self._.first_run then
    callback()
  else
    self._.timer:start(delay, 0, vim.schedule_wrap(callback))
    self._.first_run = false
  end
end

function Debounce:cancel()
  return self._.timer:stop()
end

return Debounce
