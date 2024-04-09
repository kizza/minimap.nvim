local Agent = require("minimap.events.agent")
local Config = require("minimap.config")
local Map = require("minimap.components.map")
local events = require("minimap.events")

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
      for _, painter in ipairs(config.options.map.painters) do
        painter.register(buffer, map)
      end

      map:show()

      for _, behavior in ipairs(config.options.behaviors) do
        behavior.register(buffer, agent, map)
      end
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
