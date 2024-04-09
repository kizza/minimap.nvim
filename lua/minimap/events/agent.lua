local Buffer = require("minimap.components.buffer")
local Dispatcher = require("minimap.events.dispatcher")
local events = require("minimap.events")
local util = require("minimap.util")
local Agent = Dispatcher:extend("MinimapAgent")

function Agent:init(map, config)
  self._ = {
    listeners = {},
    map = map,
    registered_buffer = nil,
    autogroup = {
      buffers = vim.api.nvim_create_augroup("MinimapAgent", { clear = true })
    }
  }
  -- self:_build_highlights()
end

function Agent:register_listeners()
  vim.api.nvim_create_autocmd({ events.BufEnter, events.FileType }, {
    callback = function()
      local buffer = Buffer()
      if buffer:is_minimap() then
        self:emit(events.MinimapActive, buffer)
      else
        self:emit(events.BufferActive, buffer)
      end
    end,
    group = self._.autogroup.buffers,
  })

  vim.api.nvim_create_autocmd(events.CmdLineLeave, {
    callback = function()
      -- print("Doing the search")
      if vim.fn.expand('<afile>') == "/" or vim.fn.expand('<afile>') == "?" then
        vim.g.minimap_search_term = vim.fn.getcmdline()
      end
    end,
    group = self._.autogroup.buffers,
  })
end

function Agent:register_mapped_buffer(buffer)
  local already_registered = self._.registered_buffer and self._.registered_buffer.bufnr == buffer.bufnr
  if already_registered then
    -- print("already registered " .. buffer.name)
    if not self._.map:valid() then
      print("Yes, there is a problem, the window isn't open")
      self._.map:hide()
      self._.map:show()
    end
    return false
  end

  -- Setup buffer
  buffer:register_listeners({
    events.RowChanged,
    events.WinScrolled,
    events.BufferChanged,
    events.BufUnload,
  })

  -- Setup map
  self._.map:size()
  self._.registered_buffer = buffer
  self._.map:clear_listeners() -- ready for new painters
  return true
end

-- function Agent:sync_buffer_row(map_line)
--   local buffer_line = util.transpose_line(map_line, self._.map.buffer.bufnr, self._.registered_buffer.bufnr)
--   self._.registered_buffer:set_cursor_line(buffer_line)
-- end

return Agent
