local M = {}

function M.map(iterable, func)
  local mapped = {}
  for i, v in ipairs(iterable) do
    mapped[i] = func(v)
  end
  return mapped
end

function M.contains(tbl, x)
  local found = false
  for _, v in pairs(tbl) do
    if v == x then
      found = true
    end
  end
  return found
end

function M.split(text)
  return text:gmatch("[^\r\n]+")
end

function M.trim_trailing_whitespace(text)
  return string.gsub(text, "([^%s]+)%s*$", "%1")
end

function M.merge_tables(first_table, second_table)
  return vim.tbl_deep_extend("force", first_table, second_table)
end

function M.merge_hl_groups(new_hl_group, opts)
  local merged = {}

  local fg = vim.api.nvim_get_hl_by_name(opts.fg, true).foreground
  if fg then merged.fg = string.format("#%06x", fg) end

  local bg = vim.api.nvim_get_hl_by_name(opts.bg, true).background
  if bg then merged.bg = string.format("#%06x", bg) end

  vim.api.nvim_set_hl(0, new_hl_group, merged)
end

function M.round(number)
  return math.floor(number + 0.5)
end

function M.get_previous_buffers()
  local buffers = vim.api.nvim_command_output("ls t")
  local bufnrs = {}
  for line in buffers:gmatch("[^\r\n]+") do
    local iterator = line:gmatch("[^ ]+")
    table.insert(bufnrs, iterator())
  end
  return bufnrs
end

return M
