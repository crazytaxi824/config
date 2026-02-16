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

local proj_local_settings = require("lsp.plugins.load_proj_settings")

local M = {}

--- diagnostics_opts 用于下面的 sources diagnostics 设置 ------------------------------------------- {{{
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
  -- diagnostics_postprocess = function(diagnostic)
  --   --- 会导致所有 error msg 都是设置的 severity level, ERROR(1) | WARN(2) | INFO(3) | HINT(4)
  --   diagnostic.severity = vim.diagnostic.severity.WARN
  --
  --   --- 相当于重新设置 diagnostics_format.
  --   diagnostic.message = diagnostic.message .. ' [null-ls]'
  -- end,
}
-- }}}

--- linters 设置 -----------------------------------------------------------------------------------
M.local_linter_key = "linter"
M.local_code_actions_key = "code_actions"
-- M.local_formatter_key = "format"

local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions
-- local formatting = null_ls.builtins.formatting

--- VVI: 这里使用函数来返回 table, 而不是直接定义一个 table 的原因是:
--- 直接定义一个 table 的问题是: module 在第一次 require() 之后 table 中的内容就缓存了.
--- 而调用函数返回 table 的好处是: 每次执行函数时 table 中的内容都会重新生成.
M.sources =  {
  [M.local_linter_key] = {
    --- go:golangci-lint 配置文件位置自动查找 ---------------------------------- {{{
    --- DOCS: https://golangci-lint.run/usage/configuration/#linters-configuration
    --- golangci-lint 会自动寻找 '.golangci.yml', '.golangci.yaml', '.golangci.toml', '.golangci.json'.
    --- GolangCI-Lint also searches for config files in all directories from the directory of
    --- the first analyzed path up to the root.
    -- -- }}}
    golangci_lint = function()
      return diagnostics.golangci_lint.with(proj_local_settings.tools_keep_extend(M.local_linter_key, 'golangci_lint',
        require("lsp.plugins.null_ls.tools.golangci_lint"),  -- NOTE: 加载单独设置 null_ls/tools/golangci_lint.lua
        diagnostics_opts))
    end,

    --- protobuf: buf
    --- NOTE: 同一个工具可能有好几种不同的用途, 需要分开设置, eg: `buf`
    --- - null_ls.builtins.diagnostics.buf  linter protobuf
    --- - null_ls.builtins.formatting.buf   format protobuf
    buf = function()
      return diagnostics.buf.with(proj_local_settings.tools_keep_extend(M.local_linter_key, 'buf', diagnostics_opts))
    end,

    --- gdscript: gdlint
    diagnostics.gdlint,

    --- python: using 'ruff' lsp instead
  },

  --- code action ----------------------------------------------------------------------------------
  [M.local_code_actions_key] = {
    code_actions.gomodifytags,
    -- code_actions.impl,  -- BUG
  },

  --- NOTE: 目前使用 Conform, Deprecated formatter & code_actions -------------- {{{
  -- [M.local_formatter_key] = {
  --   prettier = function()
  --     return formatting.prettier.with(proj_local_settings.keep_extend(M.local_formatter_key, 'prettier',
  --       require("lsp.plugins.null_ls.tools.prettier")))  -- NOTE: 加载单独设置 null_ls/tools/prettier.lua
  --   end,
  --
  --   --- go: goimports, goimports_reviser, gofmt, gofumpt
  --   --- go 需要在这里使用 'goimports', 因为 gopls 默认不会处理 "source.organizeImports",
  --   --- 但是需要 gopls 格式化 go.mod 文件.
  --   goimports = function()
  --     return formatting.goimports.with(proj_local_settings.keep_extend(M.local_formatter_key, 'goimports', {}))
  --   end,
  --
  --   --- goimports_reviser 只是对 import (...) 排序, 无法进行 format 操作.
  --   --- BUG: 目前 goimports_reviser 和 goimports 执行顺序上有问题. 导致 goimports_reviser 无法排序.
  --   --- 目前在 'auto_format.lua' 的 autocmd BufWritePost 中执行.
  --   --goimports_reviser = null_ls.builtins.formatting.goimports_reviser,
  --
  --   --- sh shell: shfmt
  --   shfmt = function()
  --     return formatting.shfmt.with(proj_local_settings.keep_extend(M.local_formatter_key, 'shfmt', {}))
  --   end,
  --
  --   --- protobuf: buf
  --   buf = function()
  --     return formatting.buf.with(proj_local_settings.keep_extend(M.local_formatter_key, 'buf', {}))
  --   end,
  -- },
  -- -- }}}
}

return M
