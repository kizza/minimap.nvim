local events = require("minimap.events")

local M = {}

vim.api.nvim_set_hl(0, "MinimapViewport", { ctermfg = 7, ctermbg = 18 })

local function build_palette()
  return {
    {
      highlight = "MinimapViewport",
      ranges = {
        { vim.fn.line("w0"), vim.fn.line("w$") },
      }
    },
  }
end

M.name = "viewport"

function M.register(buffer, map)
  map:on(events.Repaint, function()
    map:paint(M.name, build_palette(), buffer)
  end)
end

return M
