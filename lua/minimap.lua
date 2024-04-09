local Agent = require("minimap.events.agent")
local Config = require("minimap.config")
local Buffer = require("minimap.components.buffer")
local Map = require("minimap.components.map")
local events = require("minimap.events")
local util = require("minimap.util")

local M = {}

function M.setup(options)
  if not vim.g.loaded_minimap then
    vim.g.loaded_minimap = true
    M.run(options or {})
  end
end

function M.run(options)
  local config = Config(options)
  local map = Map(config)
  local agent = Agent(map, config)
  agent:register_listeners()

  -- To clear
  vim.api.nvim_create_user_command("MinimapClearSearch", function()
    vim.g.minimap_search_term = nil
    map:repaint()
  end, {})

  agent:on(events.BufferActive, function(buffer)
    if config:ignored(buffer) then
      -- map:hide()
      return
    end

    if agent:register_mapped_buffer(buffer) then
      buffer:register_listeners({
        events.RowChanged,
        events.WinScrolled,
        events.RebuildRequired,
        events.BufUnload,
      })

      map:show()

      buffer:on(events.RebuildRequired, function()
        map:rebuild()
      end)

      buffer:on(events.WinScrolled, function()
        map:repaint("scrolled")
      end)

      buffer:on(events.BufUnload, function()
        local current = Buffer({ bufnr = vim.fn.bufnr() })

        -- We've fallen into the minimap, open previous buffer
        if current.filetype == "minimap" then
          -- print("Current buffer is minimap")
          agent:restore_preivous_buffer()
        else
          -- print("Not in minimap")
          map:close()
        end
      end)

      buffer:on(events.RowChanged, function(row)
        if not map:valid() then
          print("Rowchanged in scrolling, but map is not valid")
          return
        end

        map:set_cursor_line(
          util.transpose_position(row, buffer.bufnr, map.buffer.bufnr).line
        )
      end)
    end
  end)

  agent:on(events.MinimapActive, function(buffer)
    if #vim.api.nvim_list_wins() == 1 then
      -- print("Minimap last window!")
      -- vim.cmd("quit")
    end
  end)
end

function M.create_default_highlights()
  vim.cmd [[
    hi MinimapNormal ctermfg=7
  ]]
end

return M
