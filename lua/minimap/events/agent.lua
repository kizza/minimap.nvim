local Buffer = require("minimap.components.buffer")
local Dispatcher = require("minimap.events.dispatcher")
local events = require("minimap.events")
local util = require("minimap.util")
local Agent = Dispatcher:extend("MinimapAgent")

function Agent:init(map, config)
  self._ = {
    listeners = {},
    map = map,
    painters = config.options.map.painters,
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

  -- self._.map:on(events.Repaint, function()
  --   -- print("Applying paint")
  --   self:_repaint()
  -- end)
end

function Agent:restore_preivous_buffer()
  local previous_buffers = util.get_previous_buffers()
  -- print("Previous buffers " .. vim.inspect(previous_buffers))
  -- print(vim.inspect(vim.api.nvim_command_output("ls t")))
  if previous_buffers[1] ~= tostring(vim.fn.bufnr()) then
    -- TODO use nvim_win_open with split attribute when available
    local restored_buffer = Buffer({ bufnr = tonumber(previous_buffers[2]) })
    local restore_position = "topleft vertical"
    local restore_width = vim.fn.winwidth(vim.fn.winnr()) - self._.map.width
    local restore_cmd = restore_position .. " " .. restore_width .. 'split #' .. restored_buffer.bufnr
    vim.cmd(restore_cmd)

    self:emit(events.BufferActive, restored_buffer)
  else
    -- print("Closing")
    self._.map:close()
  end
end

function Agent:_register_painters()
  for _, painter in ipairs(self._.painters) do
    painter.register(self._.registered_buffer, self._.map)
  end
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

  self._.map:size()
  self._.registered_buffer = buffer
  self._.map:clear_listeners()
  self:_register_painters()
  self._.map:on(events.RowChanged, function(line) self:sync_buffer_row(line) end)
  return true
end

-- function Agent:sync_buffer_row(map_line)
--   local buffer_line = util.transpose_line(map_line, self._.map.buffer.bufnr, self._.registered_buffer.bufnr)
--   self._.registered_buffer:set_cursor_line(buffer_line)
-- end

return Agent
