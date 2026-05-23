local M = {}

M.lsp_file = ".nvim/lsp.json"
M.linter_file = ".nvim/linter.json"

--- 查找 ".nvim/lsp.json" 和 ".nvim/linter.json"
---
---@param json_file string
---@return string|nil
function M.find_local_settings_file(json_file)
  local local_settings_filepaths = vim.fs.find(json_file, {
    upward = true, -- 从 pwd 向上寻找 .nvim/settings.lua 文件.
    stop = vim.env.HOME,  -- 直到 $HOME 为止.
    type = "file",
    limit = 1, -- NOTE: 只找最近的一个文件.
  })

  if #local_settings_filepaths < 1 then
    return nil -- 文件不存在
  end

  return vim.fs.abspath(local_settings_filepaths[1])
end

--- 两个 table 中内容不相同的 key list
---
---@param t1 table|nil
---@param t2 table|nil
---@return string[]
function M.find_diff_tool(t1, t2)
  t1 = t1 or {}
  t2 = t2 or {}

  local diff_tools = {}

  -- 第一遍：遍历 t1，找缺失或变更
  for k, v in pairs(t1) do
    if t2[k] == nil then
        table.insert(diff_tools, k)  -- k 存在 t1 中, 不存在 t2 中
    elseif not vim.deep_equal(t2[k], v) then
        table.insert(diff_tools, k)  -- t1[k], t2[k] 值不同
    end
  end

  -- 第二遍：遍历 t2，找 t1 中缺失的（新增项）
  for k in pairs(t2) do
    if t1[k] == nil then
      table.insert(diff_tools, k)  -- k 存在 t2 中, 不存在 t1 中
    end
  end

  return diff_tools
end

return M
