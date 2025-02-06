local Agent = require("minimap.events.agent")
local Config = require("minimap.config")
local Map = require("minimap.components.map")
local events = require("minimap.events")
local debug = require("minimap.debug")
local Log = require("minimap.debug.log")

local M = {}

function M.setup(options)
  if not vim.g.loaded_minimap then
    vim.g.loaded_minimap = true
    M.initialize(options or {})
  end
end

function M.initialize(options)
  local config = Config(options)
  local map = Map(config)
  local agent = Agent(map, config)
  agent:register_listeners()

  -- To clear
  vim.api.nvim_create_user_command("MinimapClearSearch", function()
    vim.g.minimap_search_term = nil
    map:repaint()
  end, {})

  vim.api.nvim_create_user_command("MinimapOpen", function()
    map:show()
  end, {})

  vim.api.nvim_create_user_command("MinimapClose", function()
    map:hide()
  end, {})

  -- To debug
  vim.api.nvim_create_user_command("MinimapDebug", function()
    debug.enable()
    vim.api.nvim_create_augroup("DebugGroup", { clear = true })
    for _, autocmd in pairs(
      { "WinNew", "BufWinEnter", "WinEnter", "BufEnter", "BufAdd", "BufWinLeave", "WinLeave", "WinClosed", "BufUnload", "BufDelete", "VimResized", "BufWrite" }
    ) do
      vim.api.nvim_create_autocmd(autocmd, { group = "DebugGroup", callback = function() debug.autocmd(autocmd) end })
    end
  end, {})

  agent:on(events.BufferActive, function(buffer)
    if config:ignored(buffer) then
      -- No action yet
      return
    end

    if agent:register_mapped_buffer(buffer) then
      for _, painter in ipairs(config.options.painters) do
        painter.register(buffer, map)
      end

      map:show()

      for _, behavior in ipairs(config.options.behaviors) do
        behavior.register(buffer, agent, map)
      end
    end
  end)

  agent:on(events.MinimapActive, function(buffer)
    -- No action yet
  end)

  agent:try_show_map()
end

function M.create_default_highlights()
  vim.cmd [[
    hi MinimapNormal ctermfg=7
  ]]
end

return M
