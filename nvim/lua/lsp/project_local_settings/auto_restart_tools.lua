local utils = require("lsp.project_local_settings.find_local_settings")

--- 两个 table 中内容不相同的 key list
local function find_diff_tool(t1, t2)
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

--- reload local settings when ".nvim/lsp.json" changed
local lsp_gid = vim.api.nvim_create_augroup("my_reload_local_lsp_settings", {clear=true})
vim.api.nvim_create_autocmd({'BufWritePost'}, {
  group = lsp_gid,
  pattern = { "**/" .. utils.lsp_file },
  callback = function(params)
    if vim.fs.abspath(params.file) == utils.find_local_settings_file(utils.lsp_file) then
      local p = require("lsp.lsp_config.update_config")
      local old = p.exist_settings()
      p.reload_local_settings()
      local new = p.exist_settings()

      local tools = find_diff_tool(old, new)
      p.restart_lsps(tools)
      vim.notify("restart lsp: " .. table.concat(tools, ", "))
    end
  end,
  desc = "reload local settings when '.nvim/lsp.json' changed",
})

--- reload local settings when ".nvim/linter.json" changed
local linter_gid = vim.api.nvim_create_augroup("my_reload_local_linter_settings", {clear=true})
vim.api.nvim_create_autocmd({'BufWritePost'}, {
  group = linter_gid,
  pattern = { "**/" .. utils.linter_file },
  callback = function(params)
    if vim.fs.abspath(params.file) == utils.find_local_settings_file(utils.linter_file) then
      local p = require("lsp.null_ls.sources")
      local old = p.exist_settings()
      p.reload_local_settings()
      local new = p.exist_settings()

      local tools = find_diff_tool(old, new)
      p.restart_linters(tools)
      vim.notify("restart linter: " .. table.concat(tools, ", "))
    end
  end,
  desc = "reload local settings when '.nvim/linter.json' changed",
})



