local Object = require("nui.object")
local debug = require("minimap.debug")
local Log = require("minimap.debug.log")

-- --- @class Dispatcher: Object
-- --- @field emit fun(event: any, any): nil
local Dispatcher = Object("MinimapDispatcher")

function Dispatcher:init()
  self._ = {
    listeners = {}
  }
end

local function trace(context)
  if debug.enabled() then
    Log(context)
  end
end

---@param event Event
---@param callback function
function Dispatcher:on(event, callback)
  if not self._.listeners[event] then
    self._.listeners[event] = {}
  end
  trace("Adding " .. event)
  table.insert(self._.listeners[event], callback)
end

function Dispatcher:emit(event, ...)
  if self._.listeners[event] then
    trace("Emiting " .. event)
    for _, callback in ipairs(self._.listeners[event]) do
      trace("Emiting")
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
