local shell = require("minimap.util.shell")

local M = {}

local function _calc_aspect_width()
  local longest_line = shell.longest_line()
  local aspect_width = math.max(longest_line, 20) -- a single character, becomes a dot
  aspect_width = math.min(aspect_width, 300)      -- prevent outrageously huge line
  return aspect_width
end

function M.build(params)
  local width = params.width
  local height = params.height

  local aspect_width = _calc_aspect_width()
  local horizontal_scale = 2.0 * width / aspect_width
  local vertical_scale = 4.0 * height / vim.fn.line('$')

  local command = "w !code-minimap -H " .. horizontal_scale .. " -V " .. vertical_scale
  local raw = shell.get_command_output(command)
  return shell.as_padded_lines(raw, width)
end

return M
