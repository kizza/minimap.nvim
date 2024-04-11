local Dispatcher = require("minimap.events.dispatcher")
local Buffer = Dispatcher:extend("MinimapBuffer")
local const = require("minimap.const")
local events = require("minimap.events")
local util = require("minimap.util")
local debug = require("minimap.util.debug")

--- @class Buffer
--- @field bufnr number
--- @field name string
--- @field filetype string
--- @field buftype string
function Buffer:init(options)
  options = options or {}
  local bufnr = options.bufnr or vim.api.nvim_get_current_buf()

  self._ = {
    listeners = {},
    last_cursor_y = -1,
  }

  self.bufnr = bufnr
  self.buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
  self.filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  self.name = vim.api.nvim_buf_get_name(bufnr)
end

function Buffer:register_listeners(augroup_name, listeners)
  local augroup = vim.api.nvim_create_augroup(augroup_name, { clear = true })

  if util.contains(listeners, events.RowChanged) then
    vim.api.nvim_create_autocmd({ events.CursorMoved, events.CursorMovedI }, {
      callback = function() self:_row_changed_handler() end,
      buffer = self.bufnr,
      group = augroup,
    })
  end

  if util.contains(listeners, events.WinScrolled) then
    vim.api.nvim_create_autocmd(events.WinScrolled, {
      callback = function() self:emit(events.WinScrolled, self) end,
      buffer = self.bufnr,
      group = augroup,
    })
  end

  if util.contains(listeners, events.BufferChanged) then
    vim.api.nvim_create_autocmd({ events.TextChanged, events.TextChangedI, events.InsertLeave }, {
      callback = function() self:emit(events.BufferChanged, self) end,
      buffer = self.bufnr,
      group = augroup,
    })
  end

  if util.contains(listeners, events.BufUnload) then
    vim.api.nvim_create_autocmd(events.BufUnload, {
      callback = function() self:emit(events.BufUnload, self) end,
      buffer = self.bufnr,
      group = augroup,
    })
  end
end

function Buffer:_row_changed_handler()
  local cursor_y = vim.fn.line(".") -- self:get_cursor_line()
  if self._.last_cursor_y == cursor_y then return end

  self._.last_cursor_y = cursor_y
  self:emit(events.RowChanged, cursor_y)
end

function Buffer:is_minimap()
  return self.filetype == const.minimap_file_type
end

function Buffer:get_cursor_line()
  local window = self:get_window()
  if not window then return -1 end

  return vim.api.nvim_win_get_cursor(window)[1]
end

function Buffer:get_window()
  local windows_for_buffer = {}
  local all_windows = vim.api.nvim_list_wins()
  for _, win_id in ipairs(all_windows) do
    if vim.api.nvim_win_get_buf(win_id) == self.bufnr then
      table.insert(windows_for_buffer, win_id)
    end
  end
  return windows_for_buffer[1]
end

function Buffer:debug(message)
  if not debug.enabled() then return nil end

  local logs = {
    "bufnr=" .. self.bufnr,
    "buftype=" .. self.buftype,
    "filetype=" .. self.filetype,
    "name=" .. self.name,
  }
  print((message or "Debug buffer") .. ": " .. table.concat(logs, ", "))
end

return Buffer
