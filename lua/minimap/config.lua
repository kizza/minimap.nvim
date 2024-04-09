local Object = require("nui.object")
local Config = Object("MinimapConfig")
local util = require("minimap.util")

local defaults = {
  map = {
    width = 10,
    painters = {
      require("minimap.builtin.painters.viewport"),
      require("minimap.builtin.painters.cursor"),
      require("minimap.builtin.painters.git"),
      require("minimap.builtin.painters.search"),
    },
    debounce = {
      build = 1000,
      paint = 50,
    }
  },
  ignored = {
    buf_types = { "nofile", "nowrite", "quickfix", "terminal", "help", "prompt", "NvimTree" },
    file_types = { "diff", "fugitive", "fzf", "telescope", "gitrebase", "gitcommit", "NvimTree" },
  }
}

function Config:init(options)
  self.options = util.merge_tables(defaults, options)
end

function Config:ignored(buffer)
  local ignored_by_buf_type = util.contains(self.options.ignored.buf_types, buffer.buftype)
  local ignored_by_file_type = util.contains(self.options.ignored.file_types, buffer.filetype)
  local directory = vim.fn.isdirectory(buffer.name) == 1
  local empty = buffer.name == "" and buffer.buftype == "" and buffer.filetype == ""

  return ignored_by_buf_type or ignored_by_file_type or directory or empty
end

return Config
