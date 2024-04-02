local Cache = require("minimap.util.cache")
local Dispatcher = require("minimap.events.dispatcher")
local Debounce = require("minimap.util.debounce")
local events = require("minimap.events")
local Builder = Dispatcher:extend("MinimapBuilder")

local function get_command_output(command)
  vim.cmd("let g:_minimap_data = execute(\"" .. command .. "\")")
  return vim.g._minimap_data
end

local function longest_line()
  return get_command_output(
    "w !awk 'length > max_length { max_length = length; longest_line = $0 } END { print length(longest_line) }'"
  )
end

local function as_padded_lines(text, width)
  local lines = {}
  for line in text:gmatch("[^\r\n]+") do
    line = line .. string.rep(" ", width - (#line / 3))
    table.insert(lines, line)
  end
  return lines
end

function Builder:init(params)
  self._ = {
    listeners = {},
    cache = Cache(),
    debouncer = Debounce(),
    window = params.window,
  }
end

function Builder:build()
  if not self._.window:valid() then
    print("Unable to render " .. self._.window.buffer.name)
    return
  end

  self._.window:set_lines(self:_get_lines())
  self:emit(events.Built)
end

function Builder:rebuild()
  local bufnr = vim.api.nvim_get_current_buf()
  self._.cache:clear(bufnr)

  self._.debouncer:run(10, function()
    if vim.api.nvim_get_current_buf() == bufnr then
      self:build()
    end
  end)
end

-- Note, is of the current buffer
function Builder:_get_lines()
  local bufnr = vim.api.nvim_get_current_buf()
  local cached = self._.cache:get(bufnr)
  if cached then
    -- print("using cached map")
    return cached
  end

  -- print("building map")
  local generated = self:_generate_lines()
  self._.cache:set(bufnr, generated)
  return generated
end

function Builder:_generate_lines()
  local aspect_width = math.max(longest_line(), 20) -- a single character, becomes a dot
  local horizontal_scale = 2.0 * self._.window.width / aspect_width
  local window_height = vim.fn.winheight(self._.window.winid)
  local vertical_scale = 4.0 * window_height / vim.fn.line('$')

  local command = "w !code-minimap -H " .. horizontal_scale .. " -V " .. vertical_scale
  local raw = get_command_output(command)
  return as_padded_lines(raw, self._.window.width)
end

return Builder
