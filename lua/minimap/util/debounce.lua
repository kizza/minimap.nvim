local Object = require("nui.object")

--- @class Debounce
local Debounce = Object("MinimapCache")

function Debounce:init(options)
  self._ = {
    timer = vim.uv.new_timer(),
    delay = options.delay or 500,
    first_run = true,
  }
end

function Debounce:run(callback)
  if self._.first_run == true then
    self._.first_run = false
    callback()
  else
    self._.timer:start(self._.delay, 0, vim.schedule_wrap(callback))
  end
end

function Debounce:cancel()
  return self._.timer:stop()
end

return Debounce
