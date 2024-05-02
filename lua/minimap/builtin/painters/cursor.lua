local events = require("minimap.events")
local util = require("minimap.util")

local M = {}

util.merge_hl_groups("MinimapCursorLine", {fg = "Type", bg = "PmenuSel"})

local function build_palette(buffer_window)
  local current_line = vim.api.nvim_win_get_cursor(buffer_window)[1]

  return {
    {
      highlight = "MinimapCursorLine",
      ranges = {
        { current_line, current_line },
      }
    },
  }
end

M.name = "cursor"

function M.register(buffer, map)
  map:on(events.Repaint, function()
    -- Current buffer may have changed (since scheduled)
    if not buffer.bufnr == vim.fn.bufnr() then return end

    -- Window may have closed (since scheduled)
    local buffer_window = buffer:get_window()
    if not buffer_window then return end

    map:paint(M.name, build_palette(buffer_window), buffer)
  end)
end

return M
