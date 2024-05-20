local events = require("minimap.events")
local util = require("minimap.util")

local M = {}

-- Create the highlight groups used by this painter
vim.api.nvim_set_hl(0, "MatrixGreen", { fg = "green", bg = "black" })
-- When in cursor line...
util.merge_hl_groups("MatrixGreenCursorLine", { fg = "MatrixGreen", bg = "MinimapCursorLine" })
-- When within viewport...
util.merge_hl_groups("MinimapAddedViewport", { fg = "MatrixGreen", bg = "MinimapViewport" })

-- Name the painter (used for internal debugging)
M.name = "neo"

-- Function called to register the painter
function M.register(buffer, map)
  -- Listen to events (usually the Repaint event)
  map:on(events.Repaint, function()
    -- Create a palette (colours and ranges)
    local palette = {
      {
        highlight = "MatrixGreen",
        ranges = {
          { 1, 1 } -- Lines 1 to 1 (ie. first line)
        }
      },
    }

    -- Paint the map with above palette
    map:paint(M.name, palette, buffer)
  end)
end

return M
