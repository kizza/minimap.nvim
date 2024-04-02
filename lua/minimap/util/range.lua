local M = {}

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
            line = line_num,
            col_start = match_start,
            col_end = match_end,
          })
        start_pos = match_end
      else
        break
      end
    end
  end

  return matches
end

function M.get_matched_ranges(text, bufnr)
  local matches = find_matches(text, bufnr)
  -- local
  -- print(vim.inspect(lines))
end

return M
