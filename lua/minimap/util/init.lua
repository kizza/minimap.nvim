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

function M.trim_trailing_whitespace(text)
  return string.gsub(text, "([^%s]+)%s*$", "%1")
end

function M.merge_tables(first_table, second_table)
  for k, v in pairs(second_table) do
    if type(v) == "table" then
      first_table[k] = M.merge_tables(first_table[k], v)
    else
      first_table[k] = v
    end
  end
  return first_table
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
