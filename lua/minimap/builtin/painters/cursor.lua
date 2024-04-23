local events = require("minimap.events")

local M = {}

vim.cmd [[
  hi MinimapCursorLine ctermfg=cyan ctermbg=20
]]

local function build_palette(buffer)
  if not buffer.bufnr == vim.fn.bufnr() then
    return
  end

  local buffer_window = buffer:get_window()
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
    map:paint(M.name, build_palette(buffer), buffer)
  end)
end

return M
