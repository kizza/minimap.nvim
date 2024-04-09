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
  -- for k, v in pairs(second_table) do first_table[k] = v end
  for k, v in pairs(second_table) do
    if type(v) == "table" then
      -- first_table[k] = first_table[k] or {}
      first_table[k] = M.merge_tables(first_table[k], v)
    else
      first_table[k] = v
    end
  end
  return first_table
end

function M.within_range(i, range)
  return i >= range[1].line and i <= range[2].line
end

function M.round(number)
  return math.floor(number + 0.5)
end

function M.range_to_matchpos(range)
  local start = range[1]
  local stop = range[2]
  if start.column == nil then
    -- Just a line
    return { start.line }
  else
    -- line, column start, length (does not support multiple line positions)
    return { { start.line, start.column, (stop.column - start.column) } }
  end
end

local function parse_position(position)
  local entire_line = { line = position }
  if type(position) ~= "table" then return entire_line end
  if #position == 1 then return entire_line end
  return { line = position[1], column = position[2] }
end

local function get_line_length(bufnr, line_number)
  -- nvim_buf_get_lines is 0-indexed for line numbers, so subtract 1 from the line_number
  local lines = vim.api.nvim_buf_get_lines(bufnr, line_number - 1, line_number, false)
  -- Check if the line was successfully retrieved
  if lines[1] then
    return string.len(M.trim_trailing_whitespace(lines[1]))
  else
    return 0
  end
end

local function transpose_line(line, source, destination)
  local source_line_count = vim.api.nvim_buf_line_count(source)
  local source_scroll_ratio = line / source_line_count

  local destination_line_count = vim.api.nvim_buf_line_count(destination)
  local transposed = source_scroll_ratio * destination_line_count

  if line > source_line_count then
    return destination_line_count
  else
    return math.ceil(transposed)
  end
end

local function round_down_to_nearest(number, factor)
  return math.floor(number / factor) * factor
end

local function round_up_to_nearest(number, factor)
  return math.ceil(number / factor) * factor
end

local function transpose_column(column, source, source_line, destination, destination_line, purpose)
  local source_line_length = get_line_length(source, source_line)
  local source_ratio = column / source_line_length

  local destination_line_length = get_line_length(destination, destination_line) --/ 3 -- remember font chars
  local transposed = source_ratio * destination_line_length
  local rounded = M.round(transposed)
  if purpose == "start" then
    rounded = math.max(1, round_down_to_nearest(transposed, 3))
  else
    rounded = math.min(destination_line_length, round_up_to_nearest(math.ceil(transposed), 3))
  end

  local debug = {
    "column=" .. column,
    "source_line_length=" .. source_line_length,
    "source_ratio=" .. source_ratio,
    "destination_line_length=" .. destination_line_length,
    "transposed=" .. transposed,
    "rounded=" .. rounded,
    "purpose=" .. purpose,
  }
  -- if purpose == "stop" then
  -- print("Debug column: " .. table.concat(debug, ", "))
  -- end

  if column > source_line_length then
    return destination_line_length
  else
    return rounded
  end
end

function M.transpose_position(raw_position, source, destination, purpose)
  local position = parse_position(raw_position)
  local transposed_line = transpose_line(position.line, source, destination)

  if position.column == nil then
    return { line = transposed_line, column = position.column }
  end

  -- Ensure we pass in the *original* (not transposed) line
  local transposed_column = transpose_column(position.column, source, position.line, destination, transposed_line,
    purpose)
  return { line = transposed_line, column = transposed_column }
end

-- Takes a line from one buffer, and transponses it's appropriate location on another
-- function M.transpose_line(row, source, destination)
--   local source_line_count = vim.api.nvim_buf_line_count(source)
--   local source_scroll_ratio = row / source_line_count

--   local destination_line_count = vim.api.nvim_buf_line_count(destination)
--   local destination_row_result = source_scroll_ratio * destination_line_count

--   if row > source_line_count then
--     return parse_position(destination_line_count)
--   else
--     return parse_position(math.ceil(destination_row_result))
--   end
-- end

function M.transpose_range(range, source, destination)
  return {
    M.transpose_position(range[1], source, destination, "start"),
    M.transpose_position(range[2], source, destination, "stop"),
  }
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
