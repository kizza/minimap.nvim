local events = require("minimap.events")

local M = {}

-- Create highlight groups used by this painter
vim.cmd [[
  hi MatrixGreen ctermfg=black ctermbg=green
]]

-- Name the painter (used for internal debugging)
M.name = "leonardo"

-- Function called to register the painter
function M.register(buffer, map)

  -- Listen to events (usually the Repaint event)
  map:on(events.Repaint, function()

    -- Create a palette (colours and ranges
    local palette = {
      {
        highlight = "MatrixGreen",
        ranges = {
          { 1, 1 } -- Lines 1 to 1 (ie. first line)
        }
      },
    }

    -- Paint the map with your palette
    map:paint(M.name, palette, buffer)
  end)
end

return M
