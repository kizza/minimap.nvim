local M = {}

--- @param command table
function M.get_command_output_async(command, success, fail)
  print("Doing it here")
  local foo = vim.system(command, { text = true },
    function(result)
      print("Exit code = " .. result.code)
      print("result " .. vim.inspect(result))
      -- if result.code ~= 0 then
      --   return fail(table.concat(result.std_error, " "))
      -- end
      -- success(results)
    end
  )

  print("Job is " .. vim.inspect(foo))
  -- vim.cmd("let g:_minimap_data = execute(\"" .. command .. "\")")
  -- return vim.g._minimap_data
end

--- @param command string
function M.get_command_output(command)
  vim.cmd("let g:_minimap_data = execute(\"" .. command .. "\")")
  return vim.g._minimap_data
end

--- @return number
function M.longest_line()
  return M.get_command_output(
    "w !awk 'length > max_length { max_length = length; longest_line = $0 } END { print length(longest_line) }'"
  )
end

--- @param text string
--- @param width number
--- @return string[]
function M.as_padded_lines(text, width)
  local lines = {}
  for line in text:gmatch("[^\r\n]+") do
    line = line .. string.rep(" ", width - (#line / 3))
    table.insert(lines, line)
  end
  return lines
end

return M
