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


--- 将路径分割为段列表（从后往前）
--- "/a/b/c.lua" -> {"c.lua", "b", "a"}
---@param path string
---@return string[]
local function split_path_reversed(path)
  local parts = {}
  for part in path:gmatch("[^/]+") do
    --- 倒序插入
    table.insert(parts, 1, part)
  end
  return parts
end

--- 获取两个路径的最短唯一显示名
---@param path_a string
---@param path_b string
---@return string[], string[]
function M.unique_short_path(path_a, path_b)
  local parts_a = split_path_reversed(path_a)
  local parts_b = split_path_reversed(path_b)

  -- basename 不同，直接返回
  if parts_a[1] ~= parts_b[1] then
    return { parts_a[1] }, { parts_b[1] }
  end

  -- basename 相同，逐段向前对比
  local max_len = math.max(#parts_a, #parts_b)
  for i = 1, max_len do
    local seg_a = parts_a[i] or "(root)"
    local seg_b = parts_b[i] or "(root)"

    if seg_a ~= seg_b then
      -- 把从头到第 i 段拼回来（反转回正向）
      local result_a = {}  ---@type string[]
      local result_b = {}  ---@type string[]

      --- 倒序插入
      for j = i, 1, -1 do
        table.insert(result_a, parts_a[j] or "")
        table.insert(result_b, parts_b[j] or "")
      end
      return result_a, result_b
    end
  end

  -- 完全相同的路径
  return {path_a}, {path_b}
end

return M
