local gitsigns = require("gitsigns")
local util = require("minimap.util")
local M = {}

-- Default highlights
vim.api.nvim_set_hl(0, "MinimapAdded", { link = "DiffAdd" })
vim.api.nvim_set_hl(0, "MinimapChanged", { link = "DiffChange" })
vim.api.nvim_set_hl(0, "MinimapRemoved", { link = "DiffDelete" })

-- When in cursor line
util.merge_hl_groups("MinimapAddedCursorLine", { fg = "MinimapAdded", bg = "MinimapCursorLine" })
util.merge_hl_groups("MinimapChangedCursorLine", { fg = "MinimapChanged", bg = "MinimapCursorLine" })
util.merge_hl_groups("MinimapRemovedCursorLine", { fg = "MinimapRemoved", bg = "MinimapCursorLine" })

-- When within viewport
util.merge_hl_groups("MinimapAddedViewport", { fg = "MinimapAdded", bg = "MinimapViewport" })
util.merge_hl_groups("MinimapChangedViewport", { fg = "MinimapChanged", bg = "MinimapViewport" })
util.merge_hl_groups("MinimapRemovedViewport", { fg = "MinimapRemoved", bg = "MinimapViewport" })

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
      table.insert(palette, {
        highlight = "MinimapAdded",
        ranges = {
          { hunk.added.start, hunk.added.start + hunk.added.count - 1 }
        }
      })

      table.insert(palette, {
        highlight = "MinimapChanged",
        ranges = {
          {
            -- Removal cannot be earlier than add
            math.max(hunk.added.start, hunk.removed.start),
            -- Removal cannot extend beyond add
            math.min(
              hunk.added.start + hunk.added.count - 1,
              hunk.removed.start + hunk.removed.count - 1
            ),
          }
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
