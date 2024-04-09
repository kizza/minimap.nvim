local util = require("minimap.util")
local events = require("minimap.events")
local Buffer = require("minimap.components.buffer")
local M = {}

local function restore_preivous_buffer(agent, map)
  local previous_buffers = util.get_previous_buffers()
  -- print("Previous buffers " .. vim.inspect(previous_buffers))
  -- print(vim.inspect(vim.api.nvim_command_output("ls t")))
  if previous_buffers[1] ~= tostring(vim.fn.bufnr()) then
    -- TODO use nvim_win_open with split attribute when available
    local restored_buffer = Buffer({ bufnr = tonumber(previous_buffers[2]) })
    local restore_position = "topleft vertical"
    local restore_width = vim.fn.winwidth(vim.fn.winnr()) - map.width
    local restore_cmd = restore_position .. " " .. restore_width .. 'split #' .. restored_buffer.bufnr
    vim.cmd(restore_cmd)

    agent:emit(events.BufferActive, restored_buffer)
  else
    -- print("Closing")
    map:close()
  end
end

function M.register(buffer, agent, map)
  buffer:on(events.BufUnload, function()
    local current = Buffer({ bufnr = vim.fn.bufnr() })

    -- We've fallen into the minimap, open previous buffer
    if current.filetype == "minimap" then
      -- print("Current buffer is minimap")
      restore_preivous_buffer(agent, map)
    else
      -- print("Not in minimap")
      map:close()
    end
  end)
end

return M
