local events = require("minimap.events")

local M = {}

function M.register(buffer, _agent, map)
  buffer:on(events.BufferChanged, function()
    map:rebuild()
  end)
end

return M
