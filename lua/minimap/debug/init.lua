local Log = require("minimap.debug.log")
local M = {}

function M.autocmd(autocmd)
  local log = Log("Recieved " .. autocmd .. " @" .. os.date("%Y-%m-%d %H:%M:%S"))
  log:append("autocmd window: " .. vim.fn.expand("<awin>"))
  log:append("autocmd file: " .. vim.fn.expand("<afile>"))
  log:append("autocmd match: " .. vim.fn.expand("<amatch>"))
  log:append("autocmd buffer: " .. vim.fn.expand("<abuf>"))
  log:append(M.list_windows())
  log:write()
end

function M.current_state()
  return Log({
    "Current window " .. vim.fn.win_getid(),
    "Current buffer (" .. vim.fn.bufnr() .. ") " .. vim.api.nvim_buf_get_name(vim.fn.bufnr())
  })
end

function M.list_windows()
  local windows = vim.api.nvim_list_wins()
  local current_window = vim.fn.win_getid()
  local current_buffer = vim.fn.bufnr()
  local log = Log()
  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)
    local short_buf_name = vim.fn.fnamemodify(buf_name, ":.:r")
    local window = "Window(" .. win .. ") " .. vim.inspect(vim.api.nvim_win_get_config(win))
    local buffer = "Buffer(" .. buf .. "): " .. short_buf_name
    if win == current_window then window = "Current " .. window end
    if buf == current_buffer then buffer = "Current " .. buffer end
    log:append(window .. " -> " .. buffer)
  end
  return log
end

function M.enable()
  vim.g.minimap_debug = true
  Log("New log"):new()
  print("Logs written to " .. Log():path())
end

function M.disable()
  vim.g.minimap_debug = false
end

function M.enabled()
  return vim.g.minimap_debug == true
end

return M
