local Object = require("nui.object")
local Cache = Object("MinimapCache")

function Cache:init()
  self._ = {
    cache = {}
  }
end

function Cache:set(key, value)
  self._.cache[key] = value
end

function Cache:get(key)
  return self._.cache[key]
end

function Cache:clear(key)
  self._.cache[key] = nil
end

function Cache:clear_all()
  self._.cache = {}
end

return Cache
