local util = require("minimap.util")
local events = require("minimap.events")
local debug = require("minimap.debug")
local Buffer = require("minimap.components.buffer")
local Log = require("minimap.debug.log")
local M = {}

local function restore_buffer(bufnr, agent, map)
  -- TODO use nvim_win_open with split attribute when available
  local restored_buffer = Buffer({ bufnr = bufnr })
  local restore_position = "topleft vertical"
  local restore_width = vim.fn.winwidth(vim.fn.winnr()) - map.width
  local restore_cmd = restore_position .. " " .. restore_width .. 'split #' .. restored_buffer.bufnr

  local log = Log("Restore buffer")
  log:append("Restoring with " .. restore_cmd)
  vim.cmd(restore_cmd)

  -- Restore broken window elements
  vim.opt.signcolumn = "yes"
  vim.opt.number = true

  return restored_buffer
end

local function restore_preivous_buffer(unloading_buffer, agent, map)
  -- if true then return nil end
  local previous_buffers = util.get_previous_buffers()


  local log = Log("Restore previous buffer")
  log:append("Unloading of " .. unloading_buffer.bufnr)
  log:append("Previous buffers " ..
    vim.inspect(previous_buffers) .. "ls=\n" .. vim.inspect(vim.api.nvim_command_output("ls t")))

  -- Remove buffer being unloaded
  previous_buffers = vim.tbl_filter(function(buf)
    return buf ~= tostring(unloading_buffer.bufnr)
  end, previous_buffers)

  -- Find first valid previous buffer to restore
  local target_bufnr = nil
  for _, buf_str in ipairs(previous_buffers) do
    local nr = tonumber(buf_str)
    if nr and nr ~= vim.fn.bufnr() and vim.api.nvim_buf_is_valid(nr) then
      target_bufnr = nr
      break
    end
  end

  if target_bufnr then
    local restored_buffer = restore_buffer(target_bufnr, agent, map)
    log:append("Restoring buffer " .. target_bufnr)
    agent:emit(events.BufferActive, restored_buffer)
  else
    log:append("No valid buffer to restore, closing map")
    map:close()
  end

  if debug.enabled() then log:write() end
end

function M.register(buffer, agent, map)
  buffer:on(events.WinClosed, function(args)
    if args.buf == agent._.registered_buffer.bufnr then
      local visible_window_splits = util.get_visible_window_splits() -- could haev other splits open
      if #visible_window_splits == 2 then                            -- note: includes current window
        -- vim.notify("Cannot close last window", vim.log.levels.INFO, { title = "Minimap" })
        -- restore_buffer(args.buf, agent, map)
        -- map:close()
      end
    end
  end)

  buffer:on(events.BufUnload, function(unloading_buffer)
    -- Defer to after BufUnload processing completes, so Neovim's internal
    -- buffer state is consistent and we avoid E1546 "Cannot switch to a closing buffer"
    local current = Buffer({ bufnr = vim.fn.bufnr() })

    -- We've fallen into the minimap, open previous buffer
    if current.filetype == "minimap" then
      restore_preivous_buffer(unloading_buffer, agent, map)
    else
      -- We're unloading the buffer we're on
      if buffer.bufnr == current.bufnr then
        buffer:debug("Closing map for this buffer")
        map:close()
      else
        map:close()
        -- Restore whatever buffer we've landed on
        buffer:debug("Restoring fallback buffer")

        vim.schedule(function()
          agent:emit(events.BufferActive, current)
        end)
      end
    end
    -- end)
  end)
end

return M
