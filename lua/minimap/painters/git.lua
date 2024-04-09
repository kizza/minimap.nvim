local gitsigns = require("gitsigns")
local M = {}

vim.cmd [[
  hi MinimapAdded ctermfg=green
  hi MinimapChanged ctermfg=magenta
  hi MinimapRemoved ctermfg=red

  hi MinimapAddedViewport ctermfg=green ctermbg=18
  hi MinimapChangedViewport ctermfg=magenta ctermbg=18
  hi MinimapRemovedViewport ctermfg=red ctermbg=18

  hi MinimapAddedCursorLine ctermfg=green ctermbg=19
  hi MinimapChangedCursorLine ctermfg=magenta ctermbg=19
  hi MinimapRemovedCursorLine ctermfg=red ctermbg=19
]]

local function build_git_palette(hunks)
  local palette = {}

  -- Enumerate gitsign hunks and map into palettes
  for _, hunk in pairs(hunks) do
    if (hunk.type == "add") then
      table.insert(palette, {
        highlight = "MinimapAdded",
        ranges = {
          { hunk.added.start, hunk.added.start + hunk.added.count - 1 },
        }
      })
    elseif (hunk.type == "delete") then
      table.insert(palette, {
        highlight = "MinimapRemoved",
        ranges = {
          { hunk.removed.start, hunk.removed.start },
        }
      })
    elseif (hunk.type == "change") then
      local start = math.min(hunk.added.start, hunk.removed.start)
      local count = hunk.added.count - 1

      table.insert(palette, {
        highlight = "MinimapChanged",
        ranges = {
          { start, start + count }
        }
      })
    end
  end
  return palette
end

local git_painter_group = vim.api.nvim_create_augroup("MinimapGitsigns", { clear = true })

M.name = "git"

function M.register(buffer, map)
  vim.api.nvim_create_autocmd('User', {
    pattern = 'GitSignsUpdate',
    group = git_painter_group,
    callback = function(args)
      if args.data and args.data.buffer == buffer.bufnr then
        local hunks = gitsigns.get_hunks(buffer.bufnr) or {}
        local palette = build_git_palette(hunks)
        map:paint(M.name, palette, buffer)
      end
    end
  })
end

return M
