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

M.debug = function()
  for lnum, expr in pairs(cache) do
    print("lnum:", lnum, "expr:", expr)
  end
end

return M
