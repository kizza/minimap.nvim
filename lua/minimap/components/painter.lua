local Object = require("nui.object")
local range_helper = require("minimap.util.range")

---@class Painter
local Painter = Object("MinimapPainter")

function Painter:init(map, painters)
  self._ = {
    map = map,
    painters = painters,
    palettes = {},
    variants = {},
  }
end

function Painter:paint(name, palette, buffer)
  self._.palettes[name] = palette
  self:_paint(buffer)
end

function Painter:_paint(buffer)
  if not self._.map:valid() then
    -- print("Unable to paint " .. buffer.name)
    return
  end

  -- Build highlight table
  local highlights = self:_build_highlights(buffer)
  -- print(vim.inspect(highlights))
  -- self:_build_variants(highlights)

  -- Apply current viewport and cursor
  local map_current_line = vim.api.nvim_win_get_cursor(self._.map.winid)[1]
  local current_viewport = { vim.fn.line("w0"), vim.fn.line("w$") }

  for _, highlight in pairs(highlights) do
    if highlight.name ~= "MinimapCursorLine" and highlight.name ~= "MinimapViewport" and highlight.name ~= "MinimapSearch" then
      if highlight.range[1].line == map_current_line then
        highlight.name = highlight.name .. "CursorLine"
      elseif range_helper.within_range(highlight.range[1].line, self:_transpose_range_to_map(current_viewport, buffer)) then
        highlight.name = highlight.name .. "Viewport"
      end
    end
  end

  vim.fn.clearmatches(self._.map.winid)
  for _, highlight in pairs(highlights) do
    -- print("Painting " .. highlight.name .. " range " .. vim.inspect(highlight.range) .. "=".. vim.inspect(range_helper.range_to_matchpos(highlight.range)) .. " priority " .. tostring(highlight.priority))
    self:_paint_range(highlight.name, range_helper.range_to_matchpos(highlight.range), highlight.priority)
  end
end

function Painter:_build_variants(highlights)
  local cursor = vim.api.nvim_get_hl_by_name("MinimapCursorLine", false)
  local viewport = vim.api.nvim_get_hl_by_name("MinimapViewport", false)

  for _, highlight in pairs(highlights) do
    if highlight.name ~= "MinimapCursorLine" and highlight.name ~= "MinimapViewport" then
      if not self._.variants[highlight.name] then
        local styles = vim.api.nvim_get_hl_by_name(highlight.name, false)
        self:_build_variant(highlight.name .. "CursorLine", styles, cursor)
        self:_build_variant(highlight.name .. "Viewport", styles, viewport)
      end
    end
  end
end

function Painter:_build_variant(name, original, additional)
  local variant = original
  variant["ctermfg"] = original.foreground   -- to maintain cterm use
  variant["ctermbg"] = additional.background -- overlay background
  variant["background"] = original.background
  self._.variants[name] = vim.api.nvim_set_hl(0, name, variant)
end

function Painter:_build_highlights(buffer)
  local highlights = {}

  -- For each painter (in order configured)
  for priority, painter in ipairs(self._.painters) do
    -- Enumerate palette groups
    local palette = self._.palettes[painter.name] or {}
    for _, group in pairs(palette) do
      -- Enumerate line ranges
      for _, range in pairs(group.ranges) do
        -- Apply paint to mapped range
        local map_range = self:_transpose_range_to_map(range, buffer)
        -- Unpack to single lines
        if map_range[1].column == nil then
          for line = map_range[1].line, map_range[2].line do
            local line_range = { { line = line }, { line = line } }
            table.insert(
              highlights, {
                name = group.highlight,
                range = line_range,
                priority = priority,
              }
            )
          end
        else
          table.insert(
            highlights, {
              name = group.highlight,
              range = map_range,
              priority = priority,
            }
          )
        end
      end
    end
  end

  return highlights
end

function Painter:_transpose_range_to_map(range, buffer)
  return range_helper.transpose_range(range, buffer.bufnr, self._.map.buffer.bufnr)
end

function Painter:_paint_range(group, pos, priority)
  -- if group == "MinimapSearch" then
  --   -- print("Paint line " .. vim.inspect(pos) .. " with " .. group)
  -- end
  return vim.fn.matchaddpos(group, pos, priority, -1, { window = self._.map.winid })
  -- vim.fn.matchaddpos("Error", {{6, 4, 2}}, 10, -1)
end

return Painter
