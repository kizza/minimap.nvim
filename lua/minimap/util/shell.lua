local M = {}

function M.get_command_output(command)
  vim.cmd("let g:_minimap_data = execute(\"" .. command .. "\")")
  return vim.g._minimap_data
end

function M.longest_line()
  return M.get_command_output(
    "w !awk 'length > max_length { max_length = length; longest_line = $0 } END { print length(longest_line) }'"
  )
end

function M.as_padded_lines(text, width)
  local lines = {}
  for line in text:gmatch("[^\r\n]+") do
    line = line .. string.rep(" ", width - (#line / 3))
    table.insert(lines, line)
  end
  return lines
end

return M
