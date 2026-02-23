--- null-ls 提供的各种 builtin tools 的加载和设置
--- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/MAIN.md  -- runtime_condition function 中的 params
--- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/CONFIG.md    -- setup 设置
--- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md  -- formatter & linter 列表
--- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md  -- with() 设置
--- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/HELPERS.md -- $FILENAME, $DIRNAME, $ROOT ...

local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

--- 加载 local settings
local project_local_settings = require("lsp.project_local_settings")

--- cache local linter settings
local local_linter_settings = nil

--- diagnostics_opts 用于下面的 sources diagnostics 设置 --- {{{
--- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
local diagnostics_opts = {
  --method = null_ls.methods.DIAGNOSTICS_ON_SAVE,  -- `lua vim.print(require('null-ls').methods)`
  --timeout = 3000,  -- 单独给 linter 设置超时时间. 全局设置了 default_timeout.
  --diagnostics_format = "#{m} [null-ls:#{s}]",  -- 单独给 linter 设置 diagnostics_format.

  --- VVI: 耗资源, 每次运行 linter 前都要运行该函数, 不要进行复杂运算.
  runtime_condition = function(params)
    --- DO NOT lint readonly files, readonly 包括了 'go env GOROOT GOMODCACHE'
    if vim.bo.readonly then
      return false  -- false 不执行 lint
    end
    return true
  end,

  --- NOTE: Post Hook, 会导致 diagnostics_format 设置失效. 可以单独给 linter 设置 post hook.
  --- This option is not compatible with 'diagnostics_format'.
  -- diagnostics_postprocess = function(diagnostic, opts)
  --   --- 会导致所有 error msg 都是设置的 severity level, ERROR(1) | WARN(2) | INFO(3) | HINT(4)
  --   -- diagnostic.severity = vim.diagnostic.severity.WARN
  --
  --   --- 相当于重新设置 diagnostics_format.
  --   -- diagnostic.message = diagnostic.message .. ' [null-ls]'
  -- end,
}
-- }}}

local M = {}

--- linter (diagnostics) tools
local diagnostics = null_ls.builtins.diagnostics
M.linter = {
  --- go:golangci-lint 配置文件位置自动查找 ---------------------------------- {{{
  --- DOCS: https://golangci-lint.run/usage/configuration/#linters-configuration
  --- golangci-lint 会自动寻找 '.golangci.yml', '.golangci.yaml', '.golangci.toml', '.golangci.json'.
  --- GolangCI-Lint also searches for config files in all directories from the directory of
  --- the first analyzed path up to the root.
  -- -- }}}
  golangci_lint = function()
    local global_settings = require("lsp.null_ls.tools.golangci_lint")

    --- 加载 global_settings & opts
    local opts = vim.tbl_deep_extend('force', diagnostics_opts, global_settings)

    --- 加载 project_local_settings
    if local_linter_settings and local_linter_settings["golangci_lint"] then
      opts = vim.tbl_deep_extend('force', opts, local_linter_settings["golangci_lint"])
    end

    return diagnostics.golangci_lint.with(opts)
  end,

  --- protobuf: buf
  --- NOTE: 同一个工具可能有好几种不同的用途, 需要分开设置, eg: `buf`
  --- - null_ls.builtins.diagnostics.buf  linter protobuf
  --- - null_ls.builtins.formatting.buf   format protobuf
  diagnostics.buf.with(diagnostics_opts),

  --- gdscript: gdlint
  diagnostics.gdlint,

  --- python: using 'ruff' lsp instead
}

--- code_actions tools
local code_actions = null_ls.builtins.code_actions
M.code_actions = {
  --- go json tags
  code_actions.gomodifytags,

  --- BUG: cwd 必须在 bufnr 所在文件夹下才能使用.
  --code_actions.impl,
}

---重新读取 project local settings 文件
M.reload_local_settings = function()
  local_linter_settings = project_local_settings.get_local_linter_settings()
end

---返回当前本地 linter 设置
---@return table|nil
M.exist_local_settings = function()
  return local_linter_settings
end

---返回一个 list sources
---@return table
M.sources = function()
  local sources_list = {}
  vim.list_extend(sources_list, vim.tbl_values(M.linter))
  vim.list_extend(sources_list, vim.tbl_values(M.code_actions))
  return sources_list
end

---重启 linters
M.restart_linters = function(linter_tools)
  local tools = {}
  for _, linter_tool in ipairs(linter_tools) do
    if M.linter[linter_tool] then
      null_ls.disable(linter_tool)  -- 清除 diagnostic messages & signs
      null_ls.deregister(linter_tool)  -- 注销, 删除原服务.
      null_ls.register(M.linter[linter_tool]())  -- 重新注册. register 后, 自动 enable.
      table.insert(tools, linter_tool)
    end
  end
  if #tools > 0 then
    vim.notify("restart linter: " .. table.concat(tools, ", "))
  end
end

return M
