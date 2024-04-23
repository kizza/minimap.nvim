local events = require("minimap.events")

local M = {}

vim.api.nvim_set_hl(0, "MinimapViewport", { ctermfg = 7, ctermbg = 19 })

local function build_palette(buffer_window_id)
  return {
    {
      highlight = "MinimapViewport",
      ranges = {
        { vim.fn.line("w0", buffer_window_id), vim.fn.line("w$", buffer_window_id) },
      }
    },
  }
end

M.name = "viewport"

function M.register(buffer, map)
  map:on(events.Repaint, function()
    map:paint(M.name, build_palette(buffer:get_window()), buffer)
  end)
end

return M
