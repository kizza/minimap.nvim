local Object = require("nui.object")

--- @class Dispatcher
--- @param extend function
local Dispatcher = Object("MinimapDispatcher")

function Dispatcher:init()
  self._ = {
    listeners = {}
  }
end

function Dispatcher:on(event, callback)
  if not self._.listeners[event] then
    self._.listeners[event] = {}
  end
  table.insert(self._.listeners[event], callback)
end

function Dispatcher:emit(event, ...)
  if self._.listeners[event] then
    for _, callback in ipairs(self._.listeners[event]) do
      callback(...)
    end
  end
end

function Dispatcher:clear_listeners(listeners)
  if listeners then
    for _, event in pairs(listeners) do
      self._.listeners[event] = {}
    end
  else
    self._.listeners = {}
  end
end

return Dispatcher
