local M = {}


--- 找出 value 在 list 中的 index
---
--- @generic T
--- @param list T[]
--- @param val T
--- @return integer|nil
function M.list_index_value(list, val)
  for i, v in ipairs(list) do
    if v == val then
      return i
    end
  end
end


return M
