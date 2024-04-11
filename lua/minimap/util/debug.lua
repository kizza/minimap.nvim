local M = {}

function M.enable()
  vim.g.minimap_debug = true
end

function M.disable()
  vim.g.minimap_debug = false
end

function M.enabled()
  return vim.g.minimap_debug == true
end

function M.print(...)
  if M.enabled() then
    return vim.g.minimap_debug == true
  end
end

return M
