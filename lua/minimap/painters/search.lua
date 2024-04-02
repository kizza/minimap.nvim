local events = require("minimap.events")

local M = {}

vim.cmd [[
  hi MinimapSearch ctermfg=white ctermbg=magenta
]]

local find = string.find

local function find_matches(text, bufnr)
  local matches = {}
  if text == "" then return matches end

  -- local save_cursor = vim.api.nvim_win_get_cursor(bufnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  for line_num = 1, line_count do
    local line = vim.api.nvim_buf_get_lines(bufnr, line_num - 1, line_num, false)[1]
    local start_pos = 0
    while true do
      local match_start, match_end = find(line, text, start_pos + 1)
      if match_start ~= nil then
        table.insert(matches,
          {
            { line_num, match_start },
            { line_num, match_end },
            -- col_start = match_start,
            -- col_end = match_end,
          })
        start_pos = match_end
      else
        break
      end
    end
  end

  return matches
end

local function build_palette(buffer)
  local search_term = vim.g.minimap_search_term
  if not search_term then
    return {}
  end

  -- print("Searching for " .. search_term)
  -- return {}
  return {
    {
      highlight = "MinimapSearch",
      ranges = find_matches(search_term, buffer.bufnr),
      -- ranges = {
      --   { { 1, 2 }, { 1, 4 } },
      --   -- { { current_line, 2 }, { current_line, 4 } },
      -- }
    },
  }
end

M.name = "search"

function M.register(buffer, map)
  map:on(events.Repaint, function()
    -- print("Search palette " .. vim.inspect(build_palette(buffer)))
    map:paint(M.name, build_palette(buffer), buffer)
  end)
end

return M
