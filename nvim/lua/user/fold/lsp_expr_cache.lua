local M = {}

local cache = {}  -- table, { lnum: expr }

M.init = function()
  cache = {}
end

M.get = function(lnum)
  return cache[lnum] or "0"
end

M.set = function(lnum, v)
  cache[lnum] = v
end

return M
