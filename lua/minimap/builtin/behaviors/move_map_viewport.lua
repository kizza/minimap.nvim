local range_helper = require("minimap.util.range")
local events = require("minimap.events")

local M = {}

function M.register(buffer, agent, map)
  buffer:on(events.RowChanged, function(row)
    if not map:valid() then
      -- print("RowChanged from buffer " .. buffer.name .. ", but map is not valid")
      return
    end

    map:set_cursor_line(
      range_helper.transpose_position(row, buffer.bufnr, map.buffer.bufnr).line
    )
  end)

  buffer:on(events.WinScrolled, function()
    map:repaint("scrolled")
  end)
end

return M
