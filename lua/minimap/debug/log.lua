local Object = require("nui.object")
local Log = Object("MinimapLog")

local log_path = vim.fn.stdpath("cache") .. "/minimap.log"

function Log:init(initial_content)
  self._ = {
    lines = {}
  }

  if type(initial_content) == "table" then
    self._.lines = initial_content
  elseif type(initial_content) == "string" then
    self:append(initial_content)
  end
end

function Log:path()
  return log_path
end

function Log:append(appendable)
  if type(appendable) == "table" then
    for _, line in pairs(appendable:lines()) do
      table.insert(self._.lines, "- " .. line)
    end
  else
    table.insert(self._.lines, appendable)
  end
end

function Log:lines()
  return self._.lines
end

function Log:write()
  vim.fn.writefile({ "---" }, log_path, "a")
  vim.fn.writefile(self._.lines, log_path, "a")
end

function Log:new()
  vim.fn.writefile(self._.lines, log_path)
end

return Log
