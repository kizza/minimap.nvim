local Cache = require("minimap.util.cache")
local Dispatcher = require("minimap.events.dispatcher")
local events = require("minimap.events")

---@class Builder
---@field build function
local Builder = Dispatcher:extend("MinimapBuilder")

function Builder:init(params)
  self._ = {
    listeners = {},
    cache = Cache(),
    map = params.map,
    builder = params.builder,
  }
end

function Builder:build()
  if not self._.map:valid() then
    print("Unable to render " .. self._.map.buffer.name)
    return
  end

  self._.map:set_lines(self:_get_lines())
  self:emit(events.Built)
end

function Builder:rebuild()
  local bufnr = vim.api.nvim_get_current_buf()
  self._.cache:clear(bufnr)
  self:build()
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
  return self._.builder.build({
    width = self._.map.width,
    height = vim.fn.winheight(self._.map.winid),
  })
end

return Builder
