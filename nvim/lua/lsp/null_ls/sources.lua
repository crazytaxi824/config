--- null-ls 提供的各种 builtin tools 的加载和设置

local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

local proj_local_settings = require("lsp._load_proj_settings")

local M = {}

--- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
--- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics
--- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/code_actions
local code_actions = null_ls.builtins.code_actions

--- diagnostics_opts 用于下面的 sources diagnostics 设置
local diagnostics_opts = {
  --- 只在 save 的时候执行 diagnostics.
  --- 其他 methods ------------------------------------------------------------- {{{
  --- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/master/lua/null-ls/methods.lua
  -- local internal_methods = {
  --     --- for code_actions
  --     CODE_ACTION = "NULL_LS_CODE_ACTION",
  --
  --     --- for linter diagnostics
  --     DIAGNOSTICS = "NULL_LS_DIAGNOSTICS",
  --     DIAGNOSTICS_ON_OPEN = "NULL_LS_DIAGNOSTICS_ON_OPEN",
  --     DIAGNOSTICS_ON_SAVE = "NULL_LS_DIAGNOSTICS_ON_SAVE",
  --
  --     --- for formatter
  --     FORMATTING = "NULL_LS_FORMATTING",
  --     RANGE_FORMATTING = "NULL_LS_RANGE_FORMATTING",
  --
  --     --- for hover
  --     HOVER = "NULL_LS_HOVER",
  --
  --     --- for COMPLETION
  --     COMPLETION = "NULL_LS_COMPLETION",
  -- }
  --- --}}}
  method = null_ls.methods.DIAGNOSTICS_ON_SAVE,

  --- VVI: 耗资源, 每次运行 linter 前都要运行该函数, 不要进行复杂运算.
  runtime_condition = function(params)
    --- DO NOT lint readonly files
    if vim.bo.readonly then
      return false  -- false 不执行 lint
    end

    --- ignore 文件夹中的文件不进行 lint
    local ignore_lint_folders = {"node_modules"}  -- readonly 中包括了 'go env GOROOT GOMODCACHE'
    for _, ignored in ipairs(ignore_lint_folders) do
      if string.match(params.bufname, ignored) then
        return false  -- false 不执行 lint
      end
    end

    return true
  end,

  --timeout = 3000,   -- 单独给 linter 设置超时时间. 全局设置了 default_timeout.
  --diagnostics_format = "#{m} [null-ls:#{s}]",  -- 单独给 linter 设置 diagnostics_format.

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

--- NOTE: root_dir 中有 eslintrc.* 配置文件的情况下启动 eslint
local eslint_opts = {
  condition = function(utils)
    --- `:help match()`, `:help pattern`, '-' 需要 escape '%-'
    return utils.root_has_file_matches("eslintrc")

    --- 也可以使用:
    --return utils.root_has_file({ "eslintrc.json", "eslintrc-ts.json", "eslintrc-js.json", "eslintrc-react.json" })
  end
}

--- linter / formatter / code action 设置 ----------------------------------------------------------
--- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/MAIN.md  -- runtime_condition function 中的 params
--- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/CONFIG.md    -- setup 设置
--- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md  -- formatter & linter 列表
--- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md  -- with() 设置
--- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/HELPERS.md -- $FILENAME, $DIRNAME, $ROOT ...
--- linters 设置 -----------------------------------------------------------------------------------
M.local_linter_key = "linter"
M.local_formatter_key = "formatter"
M.local_code_actions_key = "code_actions"

--- VVI: 这里使用函数来返回 table, 而不是直接定义一个 table 的原因是:
--- 直接定义一个 table 的问题是: module 在第一次 require() 之后 table 中的内容就缓存了.
--- 而调用函数返回 table 的好处是: 每次执行函数时 table 中的内容都会重新生成.
M.sources =  {
  [M.local_linter_key] = {
    --- golangci-lint 配置文件位置自动查找 ------------------------------------- {{{
    --- DOC: https://golangci-lint.run/usage/configuration/#linters-configuration
    --- golangci-lint 会自动寻找 '.golangci.yml', '.golangci.yaml', '.golangci.toml', '.golangci.json'.
    --- GolangCI-Lint also searches for config files in all directories from the directory of
    --- the first analyzed path up to the root.
    -- -- }}}
    golangci_lint = function()
      return diagnostics.golangci_lint.with(proj_local_settings.keep_extend(M.local_linter_key, 'golangci_lint',
        require("lsp.null_ls.tools.golangci_lint"),  -- NOTE: 加载单独设置 null_ls/tools/golangci_lint.lua
        diagnostics_opts))
    end,

    --- eslint 分别对不同的 filetype 做不同的设置. ----------------------------- {{{
    --- eslint 运行必须有配置文件, 如果没有配置文件则 eslint 运行错误.
    --- VVI: eslint 运行所需的插件下载时会生成 package.json 文件, package.json 文件必须和 .eslintrc.* 文件在同一个文件夹中.
    --- 否则 eslint 无法找到运行所需的插件.
    --- eslint 会自动寻找 .eslintrc.* 文件, '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.yaml', '.eslintrc.yml', '.eslintrc.json'.
    --- eslint will searches for directory of the file and successive parent directories all the way up to the root directory.
    --- 可以使用 '--config /xxx' 指定配置文件位置.
    --- https://eslint.org/docs/user-guide/configuring/configuration-files
    -- -- }}}
    eslint = function()
      return diagnostics.eslint.with(proj_local_settings.keep_extend(M.local_linter_key, 'eslint',
        eslint_opts, diagnostics_opts))
    end,

    --- python: flake8, mypy
    flake8 = function()
      return diagnostics.flake8.with(proj_local_settings.keep_extend(M.local_linter_key, 'flake8', diagnostics_opts))
    end,

    mypy = function()
      return diagnostics.mypy.with(proj_local_settings.keep_extend(M.local_linter_key, 'mypy', {
        extra_args = {"--follow-imports=silent", "--ignore-missing-imports"},
      }, diagnostics_opts))
    end,

    --- protobuf: buf
    buf = function()
      return diagnostics.buf.with(proj_local_settings.keep_extend(M.local_linter_key, 'buf', diagnostics_opts))
    end,
  },

  [M.local_formatter_key] = {
    prettier = function()
      return formatting.prettier.with(proj_local_settings.keep_extend(M.local_formatter_key, 'prettier',
        require("lsp.null_ls.tools.prettier")))  -- NOTE: 加载单独设置 null_ls/tools/prettier.lua
    end,

    --- python: autopep8, black, YAPF
    autopep8 = function()
      return formatting.autopep8.with(proj_local_settings.keep_extend(M.local_formatter_key, 'autopep8', {}))
    end,

    --- go: goimports, goimports_reviser, gofmt, gofumpt
    --- go 需要在这里使用 'goimports', 因为 gopls 默认不会处理 "source.organizeImports",
    --- 但是需要 gopls 格式化 go.mod 文件.
    goimports = function()
      return formatting.goimports.with(proj_local_settings.keep_extend(M.local_formatter_key, 'goimports', {}))
    end,

    --- goimports_reviser 只是对 import (...) 排序, 无法进行 format 操作.
    --- BUG: 目前 goimports_reviser 和 goimports 执行顺序上有问题. 导致 goimports_reviser 无法排序.
    --- 目前在 'auto_format.lua' 的 autocmd BufWritePost 中执行.
    --goimports_reviser = null_ls.builtins.formatting.goimports_reviser,

    --- sh shell: shfmt
    shfmt = function()
      return formatting.shfmt.with(proj_local_settings.keep_extend(M.local_formatter_key, 'shfmt', {}))
    end,

    --- protobuf: buf
    buf = function()
      return formatting.buf.with(proj_local_settings.keep_extend(M.local_formatter_key, 'buf', {}))
    end,
  },

  [M.local_code_actions_key] = {
    --- NOTE: null-ls 不是 autostart 的, 需要触发操作后才会加载.
    --- eslint 等工具启动速度慢, 会拖慢第一次使用 code action 的时间.
    eslint = function()
      return code_actions.eslint.with(proj_local_settings.keep_extend(M.local_code_actions_key, 'eslint', eslint_opts))
    end,
  },
}

return M
