local range_helper = require("minimap.util.range")
local events = require("minimap.events")

local M = {}

function M.register(buffer, _agent, map)
  map:on(events.RowChanged, function(row)
    if not map:valid() then
      return
    end

    buffer:set_cursor_line(
      range_helper.transpose_position(row, map.buffer.bufnr, buffer.bufnr).line
    )

    map:repaint("map line moved")
  end)
end

return M
