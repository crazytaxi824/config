local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

--- 检查 null-ls 所需 tools ------------------------------------------------------------------------ {{{
local null_tools = {
  ["golangci-lint"] = "go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest",
  ["goimports"] = "    go install golang.org/x/tools/cmd/goimports@latest",
  ["buf"] = "          go install github.com/bufbuild/buf/cmd/buf@latest",

  prettier = " brew info prettier",
  stylua = "   brew info stylua",
  shfmt = "    brew info shfmt",

  mypy = "     pip3 install mypy",  -- mypy-extensions, mypy 插件, experimental extensions
  flake8 = "   pip3 install flake8",
  autopep8 = " pip3 install autopep8",

  eslint = "   npm install -g eslint",
}

Check_cmd_tools(null_tools, {title= "check null-ls tools"})
-- -- }}}

--- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
--- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics
--- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/code_actions
--- NOTE: null-ls 不是 autostart 的, 需要触发操作后才会加载. 会导致第一次 code action 的时候速度慢.
--local code_actions = null_ls.builtins.code_actions

--- diagnostics_opts 用于下面的 sources diagnostics 设置 ------------------------------------------- {{{
--- https://github.com/jose-elias-alvarez/null-ls.nvim -> lua/null-ls/methods.lua
-- local internal_methods = {
--     CODE_ACTION = "NULL_LS_CODE_ACTION",  --- NOTE: for code_actions
--
--     DIAGNOSTICS = "NULL_LS_DIAGNOSTICS",  --- NOTE: for linter diagnostics
--     DIAGNOSTICS_ON_OPEN = "NULL_LS_DIAGNOSTICS_ON_OPEN",
--     DIAGNOSTICS_ON_SAVE = "NULL_LS_DIAGNOSTICS_ON_SAVE",
--
--     FORMATTING = "NULL_LS_FORMATTING",  --- NOTE: for formatter
--     RANGE_FORMATTING = "NULL_LS_RANGE_FORMATTING",
--
--     HOVER = "NULL_LS_HOVER",  --- NOTE: for hover
--
--     COMPLETION = "NULL_LS_COMPLETION",  --- NOTE: for COMPLETION
-- }
local diagnostics_opts = {
  --- 只在 save 的时候执行 diagnostics.
  method = null_ls.methods.DIAGNOSTICS_ON_SAVE,

  --- NOTE: 耗资源, 每次运行 linter 前都要运行该函数, 不要做太复杂的运算.
  runtime_condition = function(params)
    --- DO NOT lint readonly files
    if vim.bo.readonly then
      return false  -- false 不执行 lint
    end

    --- NOTE: ignore 文件夹中的文件不进行 lint
    local ignore_lint_folders = {"node_modules"}
    for _, ignored in ipairs(ignore_lint_folders) do
      if string.match(params.bufname, ignored) then
        return false  -- false 不执行 lint
      end
    end

    return true
  end,

  --timeout = 3000,   -- linter 超时时间, 全局设置了 default_timeout.
  --diagnostics_format = "#{m} [null-ls:#{s}]",  -- 只对单个 linter 生效.

  --- NOTE: Post Hook, 会导致 diagnostics_format 设置失效. 可以给单独 linter 设置 post hook.
  --- This option is not compatible with 'diagnostics_format'.
  -- diagnostics_postprocess = function(diagnostic)
  --   --- 会导致所有 error msg 都是设置的 severity level, ERROR(1) | WARN(2) | INFO(3) | HINT(4)
  --   diagnostic.severity = vim.diagnostic.severity.WARN
  --
  --   --- 相当于重新设置 diagnostics_format.
  --   diagnostic.message = diagnostic.message .. ' [null-ls]'
  -- end,
}
-- -- }}}

--- linter / formatter / code action 设置 ----------------------------------------------------------
--- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/MAIN.md  -- runtime_condition function 中的 params
--- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/CONFIG.md    -- setup 设置
--- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md  -- formatter & linter 列表
--- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md  -- with() 设置
--- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/HELPERS.md -- $FILENAME, $DIRNAME, $ROOT ...
--- linters 设置 -----------------------------------------------------------------------------------
local linter_settings = {
  --- golangci-lint
  diagnostics.golangci_lint.with(__Proj_local_settings.keep_extend('lint', 'golangci_lint',
    require("user.lsp.null_ls.tools.golangci"), diagnostics_opts)  -- NOTE: 加载单独设置 null_ls/tools/golangci
  ),

  --- NOTE: eslint 分别对不同的 filetype 做不同的设置. --- {{{
  --- eslint 运行必须有配置文件, 如果没有配置文件则 eslint 运行错误.
  --- VVI: eslint 运行所需的插件下载时会生成 package.json 文件, package.json 文件必须和 .eslintrc.* 文件在同一个文件夹中.
  --- 否则 eslint 无法找到运行所需的插件.
  --- eslint 会自动寻找 .eslintrc.* 文件, '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.yaml', '.eslintrc.yml', '.eslintrc.json'.
  --- eslint will searches for directory of the file and successive parent directories all the way up to the root directory.
  --- 可以使用 '--config /xxx' 指定配置文件位置.
  --- https://eslint.org/docs/user-guide/configuring/configuration-files
  -- -- }}}
  diagnostics.eslint.with(__Proj_local_settings.keep_extend('lint', 'eslint', {
    extra_args = { "--config", "eslintrc-ts.json" },
    filetypes = {"typescript"},
  }, diagnostics_opts)),
  diagnostics.eslint.with(__Proj_local_settings.keep_extend('lint', 'eslint', {
    extra_args = { "--config", "eslintrc-react.json" },
    filetypes = {"typescriptreact"},
  }, diagnostics_opts)),
  diagnostics.eslint.with(__Proj_local_settings.keep_extend('lint', 'eslint', {
    extra_args = { "--config", "eslintrc-js.json" },
    filetypes = {"javascript", "javascriptreact", "vue"},
  }, diagnostics_opts)),

  --- python, flake8, mypy
  diagnostics.flake8.with(__Proj_local_settings.keep_extend('lint', 'flake8', diagnostics_opts)),
  diagnostics.mypy.with(__Proj_local_settings.keep_extend('lint', 'mypy', {
    extra_args = {"--follow-imports=silent", "--ignore-missing-imports"},
  }, diagnostics_opts)),

  --- protobuf, buf
  diagnostics.buf.with(__Proj_local_settings.keep_extend('lint', 'buf', diagnostics_opts)),
}

--- formatter 设置 ---------------------------------------------------------------------------------
local formatter_settings = {
  --- NOTE: 需要在 lsp.setup(opts) 中的 on_attach 中排除 tsserver & sumneko_lua 的 formatting 功能
  formatting.prettier.with(__Proj_local_settings.keep_extend('format', 'prettier',
    require("user.lsp.null_ls.tools.prettier")
  )),

  --- lua, stylua
  formatting.stylua.with(__Proj_local_settings.keep_extend('format', 'stylua', {
    extra_args = { "--column-width=" .. vim.bo.textwidth },  -- 和 vim textwidth 相同.
  })),

  --- python, autopep8, black, YAPF
  formatting.autopep8.with(__Proj_local_settings.keep_extend('format', 'autopep8', {})),

  --- go, gofmt, goimports, gofumpt
  --- go 需要在这里使用 'goimports', 因为 gopls 默认不会处理 "source.organizeImports",
  --- 但是需要 gopls 格式化 go.mod 文件.
  formatting.goimports.with(__Proj_local_settings.keep_extend('format', 'goimports', {})),

  --- sh shell
  formatting.shfmt.with(__Proj_local_settings.keep_extend('format', 'shfmt', {})),

  --- protobuf, buf
  formatting.buf.with(__Proj_local_settings.keep_extend('format', 'buf', {})),
}

--- null-ls setup() 在这里加载上面设置的 formatting & linter ---------------------------------------
--- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/CONFIG.md
null_ls.setup({
  --- VVI: 设置 linter / formatter / code actions
  sources = vim.list_extend(linter_settings, formatter_settings),

  --- VVI: project root, 影响 linter 执行时的 pwd. 这里的 root_dir 是一个全局设置, 对 null-ls 中的所有 linter 有效.
  --- root_dir 需要传入一个回调函数 func(params):string.
  --- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/MAIN.md#generators
  --- 默认值: root_dir = require("null-ls.utils").root_pattern(".null-ls-root", "Makefile", ".git")
  --- 如果 utils.root_pattern() 返回 nil, 则 root_dir 会被设置成当前路径 vim.fn.getcwd().
  ---
  --- PROBLEM: null-ls 的 root_dir 只会运行一次. 而 lspconfig 的 root_dir 在每次打开 buffer 时都会执行.
  --- Q: 为什么要在每次执行 linter 时单独获取 pwd 路径?
  --- A: 因为 nvim 可能会在多个项目文件之间跳转, 每个项目有自己单独的 root.
  --- HOW: 单独为 linter 设置 cwd = func(params):string, 参考 tools/golangci.lua
  root_dir = function(params)
    local util = require("null-ls.utils")
    return util.root_pattern('go.work')(params.bufname) or
      util.root_pattern('.git','go.mod','package.json','tsconfig.json','jsconfig.json')(params.bufname)
  end,

  --- 如果 error msg 没有特别指明 severity level, 则会使用下面的设置.
  fallback_severity = vim.diagnostic.severity.WARN,

  --- NOTE: 非常耗资源, 调试完后设置为 false.
  --- is the same as setting log.level to "trace" 记录 log, `:NullLsLog` 打印 log.
  debug = false,

  --- log 输出到 stdpath('cache') .. 'null-ls.log'
  log = {
    enable = true,
    level = 'warn',  -- "error", "warn"(*), "info", "debug", "trace"

    --- show log output in Neovim's ':messages'.
    --- sync is slower but guarantees that messages will appear in order.
    use_console = 'async',  -- "sync", "async"(*), false.
  },

  update_in_insert = false,  -- 节省资源, 一边输入一边检查
  debounce = 600,            -- 节省资源, diagnostics 间隔时间, 默认 250
  default_timeout = 5000,    -- lint 超时时间
  diagnostics_format = "#{m} [null-ls]",  -- 错误信息显示格式, #{m} - message, #{s} - source, #{c} - err_code

  --- NOTE: 以下 callback 函数中都会传入 on_init = function(client, init_result) 两个参数.
  --- null-ls 退出的时候提醒.
  on_exit = function()
    Notify("Null-Ls exit. Please check ':NullLsInfo' & ':NullLsLog'","WARN",
      {title = {"Null-ls", "null_ls/init.lua"}, timeout = false})
  end,

  --- 设置 key_mapping vim.diagnostic.goto_next() ...
  on_attach = function()
    require("user.lsp.util.lsp_keymaps").diagnostic_keymaps(0)
  end,

  --on_init = function(client, init_result)
})



