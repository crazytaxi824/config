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

  flake8 = "   pip3 install flake8",
  autopep8 = " pip3 install autopep8",

  eslint = "   npm install -g eslint",
}

Check_Cmd_Tools(null_tools)
-- -- }}}

--- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
--- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics
--- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/code_actions
--- NOTE: null-ls 不是 autostart 的, 需要触发操作后才会加载. 会导致第一次 code action 的时候速度慢.
--local code_actions = null_ls.builtins.code_actions

--- diagnostics_opts 用于下面的 sources diagnostics 设置 ------------------------------------------- {{{
local ignore_lint_folders = {"node_modules"}  -- 文件夹中的文件不进行 lint

local diagnostics_opts = {
  method = null_ls.methods.DIAGNOSTICS_ON_SAVE,  -- 只在 save 的时候执行 diagnostics.
  runtime_condition = function(params)  -- NOTE: 耗资源, 每次运行 linter 前都要运行该函数, 不要做太复杂的运算.
    if vim.bo.readonly then
      return false  -- do not lint readonly files
    end

    for _, ignored in ipairs(ignore_lint_folders) do
      if string.match(params.bufname, ignored) then
        return false  -- ignore 指定 folder 中的文件
      end
    end

    return true
  end,
  --timeout = 3000,   -- linter 超时时间, 全局设置了 default_timeout.
  --diagnostics_format = "#{m} [null-ls:#{s}]",  -- 只对单个 linter 生效.
}
-- -- }}}

--- linter / formatter / code action 设置 ----------------------------------------------------------
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/MAIN.md  -- runtime_condition function 中的 params
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/CONFIG.md    -- setup 设置
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md  -- formatter & linter 列表
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md  -- with() 设置
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/HELPERS.md -- $FILENAME, $DIRNAME, $ROOT ...
--- linters 设置 -----------------------------------------------------------------------------------
local linter_settings = {
  -- python, flake8
  diagnostics.flake8.with(__Proj_local_settings.keep_extend('lint', diagnostics_opts)),

  --- golangci-lint
  diagnostics.golangci_lint.with(__Proj_local_settings.keep_extend('lint',
    require("user.lsp.null-ls.golangci"), diagnostics_opts)
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
  diagnostics.eslint.with(__Proj_local_settings.keep_extend('lint', {
    extra_args = { "--config", "eslintrc-ts.json" },
    filetypes = {"typescript"},
  }, diagnostics_opts)),
  diagnostics.eslint.with(__Proj_local_settings.keep_extend('lint', {
    extra_args = { "--config", "eslintrc-react.json" },
    filetypes = {"typescriptreact"},
  }, diagnostics_opts)),
  diagnostics.eslint.with(__Proj_local_settings.keep_extend('lint', {
    extra_args = { "--config", "eslintrc-js.json" },
    filetypes = {"javascript", "javascriptreact", "vue"},
  }, diagnostics_opts)),

  --- protobuf, buf
  diagnostics.buf.with(diagnostics_opts),
}

--- formatter 设置 ---------------------------------------------------------------------------------
local formatter_settings = {
  --- NOTE: 需要在 lsp.setup(opts) 中的 on_attach 中排除 tsserver & sumneko_lua 的 formatting 功能
  formatting.prettier.with(require("user.lsp.null-ls.prettier")),

  --- lua, stylua
  formatting.stylua.with({
    extra_args = { "--column-width=" .. vim.bo.textwidth },  -- 和 vim textwidth 相同.
  }),

  --- python, autopep8, black, YAPF
  formatting.autopep8,

  --- go 需要在这里使用 'goimports', 因为 gopls 默认不会处理 "source.organizeImports",
  --- 但是需要 gopls 格式化 go.mod 文件.
  formatting.goimports, -- go, gofmt, goimports, gofumpt

  --- sh shell
  formatting.shfmt,

  --- protobuf, buf
  formatting.buf,
}

--- null-ls 在这里加载上面设置的 formatting & linter -----------------------------------------------
--- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/CONFIG.md
null_ls.setup({
  --- VVI: 设置 linter / formatter / code actions
  sources = vim.list_extend(linter_settings, formatter_settings),

  --- VVI: project root, 影响 linter 执行. root_dir 传入一个回调 func(fname).
  --- 如果想要改变 linter 执行的路径, 需要在 linter.with() 设置中设置 cwd. cwd 默认值为 root_dir.
  --- null-ls 的 root_dir 只会运行一次. 而 lspconfig 的 root_dir 在每次打开 buffer 时都会执行.
  --- root_dir 有默认值. 如果 root_pattern() 返回 nil, 则 root_dir 会被设置成默认值, 即 vim.fn.getcwd().
  root_dir = require("null-ls.utils").root_pattern(
    '.git','go.mod','go.work','package.json','tsconfig.json','jsconfig.json'),

  -- NOTE: 非常耗资源, 调试完后设置为 false.
  -- is the same as setting log.level to "trace" 记录 log, `:NullLsLog` 打印 log.
  debug = false,

  update_in_insert = false,  -- 节省资源, 一边输入一边检查
  debounce = 600,            -- 节省资源, diagnostics 间隔时间, 默认 250
  diagnostics_format = "#{m} [null-ls]",  -- 错误信息显示格式, #{m} - message, #{s} - source, #{c} - err_code
  default_timeout = 5000,   -- lint 超时时间

  --- null-ls 退出的时候提醒.
  on_exit = function()
    Notify("Null-Ls exit. Please check ':NullLsInfo' & ':NullLsLog'","WARN",
      {title = {"LSP", "null-ls.lua"}, timeout = false})
  end,

  --- 设置 key_mapping vim.diagnostic.goto_next() ...
  on_attach = function(client, init_result)
    require("user.lsp.lsp_keymaps").diagnostic_keymaps(0)
  end,

  --- 其他设置
  --on_init = function(client, init_result)
})



