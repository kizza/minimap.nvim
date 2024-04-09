local Buffer = require("minimap.components.buffer")
local Builder = require("minimap.components.builder")
local Painter = require("minimap.components.painter")
local Dispatcher = require("minimap.events.dispatcher")
local Debounce = require("minimap.util.debounce")
local const = require("minimap.const")
local events = require("minimap.events")

---@class Split
---@field bufnr number
local Split = require("nui.split")

---@class Map
---@field bufnr number
---@field emit function
local Map = Dispatcher:extend("MinimapWindow")

function Map:init(config)
  self._ = {
    listeners = {},
    lines = {},
    builder = nil,
    painter = Painter(self, config.options.map.painters),
    namespace = vim.api.nvim_create_namespace("MinimapMap"),
    autogroup = {
      self = vim.api.nvim_create_augroup("MinimapMapEvents", { clear = true })
    },
    debouncers = {
      paint = Debounce({ delay = config.options.map.debounce.paint }),
      build = Debounce({ delay = config.options.map.debounce.build }),
    },
  }
  self.buffer = nil
  self.winid = -1
  self.width = config.options.map.width

  self:_build_split()
  self:_build_builder(config.options.map.builder)
end

function Map:build()
  self:size()
  self._.builder:build()
end

function Map:rebuild(...)
  local bufnr = vim.api.nvim_get_current_buf()
  self._.debouncers.build:run(function(...)
    if vim.api.nvim_get_current_buf() == bufnr then
      self._.builder:rebuild(...)
    end
  end)
end

-- Fixes size if/when misaligned
function Map:size()
  vim.cmd("vertical " .. self.winid .. "resize " .. self.width)
end

function Map:paint(...)
  self._.painter:paint(...)
end

function Map:repaint(reason)
  -- print("Repainting: " .. reason)
  self._.debouncers.paint:run(function()
    if self:valid() then
      self:emit(events.Repaint, self._.lines)
    end
  end)
end

function Map:_build_split()
  self._.split = Split({
    relative = "editor",
    position = "right",
    size = self.width,
    enter = false,
    buf_options = {
      bufhidden = "hide",
      buftype = "nofile",
      buflisted = false,
      filetype = const.minimap_file_type,
      swapfile = false,
      modifiable = false,
    },
    win_options = {
      number = false,
      relativenumber = false,
      fillchars = "eob: ,vert:|,fold:-,diff:-",
      listchars = "trail: ",
      wrap = false,
      signcolumn = "no",
      winhighlight = "Normal:MinimapNormal", -- ,CursorLine:MinimapCursorLine",
      scrolloff = 0,
      sidescrolloff = 0,
    }
  })
end

function Map:_build_builder(builder)
  self._.builder = Builder({ map = self, builder = builder })
  self._.builder:on(events.Built, function() self:repaint("buffer rebuilt") end)
end

function Map:_build_buffer()
  self.buffer = Buffer({ bufnr = self._.split.bufnr })
  vim.api.nvim_buf_set_name(self.buffer.bufnr, "~minimap~") -- name for convenince
end

function Map:valid()
  if not self.winid then return false end
  return vim.api.nvim_win_is_valid(self.winid) and vim.api.nvim_buf_is_valid(self.buffer.bufnr)
end

function Map:show()
  if self._.split._.mounted == true then
    self:build()
    return
  end

  self._.split:mount()
  self.winid = self._.split.winid
  self:_build_buffer()
  self:register_listeners()
  self:build()
end

function Map:hide()
  self._.split:unmount()
end

function Map:close()
  self._.split:unmount()
  self:clear_listeners()
end

function Map:set_lines(lines)
  vim.api.nvim_buf_set_option(self.buffer.bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(self.buffer.bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(self.buffer.bufnr, "modifiable", false)
  self._.lines = lines
end

function Map:get_lines()
  return self._.lines
end

function Map:set_cursor_line(line)
  vim.api.nvim_win_set_cursor(self.winid, { line, 0 })
  self:repaint("cursor line set")
end

function Map:register_listeners()
  vim.api.nvim_create_autocmd(events.VimResized, {
    callback = function() self:_handle_resize() end,
    -- buffer = self.buffer.bufnr,
    group = self._.autogroup.self,
  })

  -- vim.api.nvim_create_autocmd(events.BufDelete, {
  --   callback = function() self:_handle_buffer_deleted() end,
  --   buffer = self.buffer.bufnr,
  --   group = self._.autogroup.self,
  -- })

  -- vim.api.nvim_create_autocmd({events.WinScrolled, events.CursorMoved}, {
  --   callback = function() self:_handle_map_scroll() end,
  --   buffer = self.buffer.bufnr,
  --   group = self._.autogroup.self,
  -- })
end

-- function Map:_handle_map_scroll()
--   local current_line = self.buffer:get_cursor_line()
--   self:emit(events.RowChanged, current_line)
--   self:repaint("map scrolling")
-- end

function Map:_handle_resize()
  self:size()
  self:repaint("resized")
end

function Map:_handle_buffer_deleted()
  -- print("MY BUFFER WAS DELETED! " .. self.buffer.name)
  -- self:hide()
end

return Map
