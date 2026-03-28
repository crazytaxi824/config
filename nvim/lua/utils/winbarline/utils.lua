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
---
--- @param path string
--- @return string[]
local function split_path_reversed(path)
  local parts = {}
  for part in path:gmatch("[^/]+") do
    --- 倒序插入
    table.insert(parts, 1, part)
  end
  return parts
end

--- 获取多个路径各自的最短唯一显示名
---@param paths string[]
---@return string[][]
function M.unique_short_paths(paths)
  local all_parts = {}
  for _, path in ipairs(paths) do
    all_parts[#all_parts + 1] = split_path_reversed(path)
  end

  local results = {}

  for i, parts_a in ipairs(all_parts) do
    local max_depth = 1

    for j, parts_b in ipairs(all_parts) do
      if i ~= j then
        local max_len = math.max(#parts_a, #parts_b)
        for k = 1, max_len do
          if parts_a[k] ~= parts_b[k] then
            if k > max_depth then
              max_depth = k
            end
            break
          end
        end
      end
    end

    -- 直接返回 slice，从 max_depth 到 1（正向顺序）
    local result = {}
    for k = math.min(max_depth, #parts_a), 1, -1 do
      result[#result + 1] = parts_a[k]
    end

    -- 如果需要的深度超过实际段数，说明路径更短，在最前面补 ""
    if max_depth > #parts_a then
      table.insert(result, 1, "")
    end

    results[#results + 1] = result
  end

  return results
end


--- @return integer TopRight_win_id
function M:get_top_right_win()
  local best_win
  local best_col = -1
  local best_row = math.huge

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local pos = vim.api.nvim_win_get_position(win)  -- {row, col}
    local row, col = pos[1], pos[2]

    if col > best_col or (col == best_col and row < best_row) then
      best_col = col
      best_row = row
      best_win = win
    end
  end

  return best_win
end


return M
