local util = require("minimap.util")
local events = require("minimap.events")
local debug = require("minimap.debug")
local Buffer = require("minimap.components.buffer")
local Log = require("minimap.debug.log")
local M = {}

local function restore_preivous_buffer(agent, map)
  -- if true then return nil end
  local previous_buffers = util.get_previous_buffers()

  local log = Log("Restore previous buffer")
  log:append("Previous buffers " ..
    vim.inspect(previous_buffers) .. "\n" .. vim.inspect(vim.api.nvim_command_output("ls t")))

  if previous_buffers[1] ~= tostring(vim.fn.bufnr()) then
    -- TODO use nvim_win_open with split attribute when available
    local restored_buffer = Buffer({ bufnr = tonumber(previous_buffers[2]) })
    local restore_position = "topleft vertical"
    local restore_width = vim.fn.winwidth(vim.fn.winnr()) - map.width
    local restore_cmd = restore_position .. " " .. restore_width .. 'split #' .. restored_buffer.bufnr
    log:append("Restoring with " .. restore_cmd)
    vim.cmd(restore_cmd)

    -- Restore broken window elements
    vim.opt.signcolumn = "yes"
    vim.opt.number = true

    agent:emit(events.BufferActive, restored_buffer)
  else
    log:append("Closing map")
    map:close()
  end

  if debug.enabled() then log:write() end
end

function M.register(buffer, agent, map)
  buffer:on(events.BufUnload, function()
    local current = Buffer({ bufnr = vim.fn.bufnr() })

    -- We've fallen into the minimap, open previous buffer
    if current.filetype == "minimap" then
      restore_preivous_buffer(agent, map)
    else
      -- We're unloading, the buffer we're on
      if buffer.bufnr == current.bufnr then
        buffer:debug("Closing map for this buffer")
        map:close()
      else
        -- Restore whatever buffer we've landed on
        buffer:debug("Restoring fallback buffer")
        vim.schedule_wrap(function()
          agent:emit(events.BufferActive, current)
        end)
      end
    end
  end)
end

return M
