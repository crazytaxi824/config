local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

local util = require("null-ls.utils")

--- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
--- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics
--- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/code_actions
--- NOTE: null-ls 不是 autostart 的, 需要触发操作后才会加载. 会导致第一次 code action 的时候速度慢.
--local code_actions = null_ls.builtins.code_actions

--- diagnostics_opts 用于下面的 sources diagnostics 设置.
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
    {
      -- VVI: 执行 golangci-lint 的 pwd. 默认是 params.root 即: null_ls.setup() 中的 root_dir / $ROOT
      -- params 回调参数 --- {{{
      --   content,    -- current buffer content (table, split at newline)
      --   lsp_method, -- lsp method that triggered request (string)
      --   method,  -- null-ls method that triggered generator (string)
      --   row,     -- cursor's current row (number, zero-indexed)
      --   col,     -- cursor's current column (number)
      --   bufnr,   -- current buffer's number (number)
      --   bufname, -- current buffer's full path (string)
      --   ft,   -- current buffer's filetype (string)
      --   root, -- current buffer's root directory (string)
      -- -- }}}
      cwd = function(params)
        return util.root_pattern('go.work')(params.bufname) or
          util.root_pattern('go.mod','.git')(params.bufname) or
          params.root
      end,

      ---  可以通过设置 setup() 中的 debug = true, 打开 `:NullLsLog` 查看命令行默认参数.
      args = function(params)
        local new_root = util.root_pattern('go.work')(params.bufname) or
          util.root_pattern('go.mod','.git')(params.bufname) or
          params.root
        --- VVI: 这里必须要使用 $DIRNAME.
        ---  如果使用 $FILENAME 意思是 lint 单个文件. 别的文件中定义的 var 无法被 golangci 找到.
        ---  如果缺省设置, 即不设置 $FILENAME 也不设置 $DIRNAME, 则每次 golangci 都会 lint 整个 project.
        return { "run", "--fix=false", "--fast", "--out-format=json", "$DIRNAME", "--path-prefix", new_root }
      end,

      --- golangci-lint 配置文件设置 --- {{{
      --- golangci-lint 会自动寻找 '.golangci.yml', '.golangci.yaml', '.golangci.toml', '.golangci.json'.
      --- GolangCI-Lint also searches for config files in all directories from the directory of the first analyzed path up to the root.
      --- https://golangci-lint.run/usage/configuration/#linters-configuration
      -- -- }}}
      --extra_args = { '--config', ".golangci.yml"},  -- NOTE: 相对上面 cwd 的路径, 也可以使用绝对地址.

      --filetypes = { "go" },  -- 只对 go 文件生效.
    }, diagnostics_opts)
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
}

--- formatter 设置 ---------------------------------------------------------------------------------
local formatter_settings = {
  --- NOTE: 需要在 lsp.setup(opts) 中的 on_attach 中排除 tsserver & sumneko_lua 的 formatting 功能
  formatting.prettier.with({
    --command = "/path/to/prettier",
    --env = { PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/xxx/.prettierrc.json") }  -- 环境变量
    --- NOTE: prettier 默认支持 .editorconfig 文件.
    extra_args = { "--single-quote", "--jsx-single-quote",
      "--print-width=" .. vim.bo.textwidth,  -- 和 vim textwidth 相同.
      "--end-of-line=lf", "--tab-width=2" },
    disabled_filetypes = { "yaml" },  -- 不需要使用 prettier 格式化.
  }),

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
  root_dir = util.root_pattern('.git','go.mod','go.work','package.json','tsconfig.json','jsconfig.json'),

  -- NOTE: 非常耗资源, 调试完后设置为 false.
  -- is the same as setting log.level to "trace" 记录 log, `:NullLsLog` 打印 log.
  debug = false,

  update_in_insert = false,  -- 节省资源, 一边输入一边检查
  debounce = 600,            -- 节省资源, diagnostics 间隔时间, 默认 250
  diagnostics_format = "#{m} [null-ls]",  -- 错误信息显示格式, #{m} - message, #{s} - source, #{c} - err_code
  default_timeout = 5000,   -- lint 超时时间

  -- on_attach =
  -- on_exit =
  -- on_init = function(client, init_result)

  -- null-ls 退出的时候提醒.
  on_exit = function()
    Notify("Null-Ls exit. Please check ':NullLsInfo' & ':NullLsLog'","WARN",
      {title = {"LSP", "null-ls.lua"}, timeout = false})
  end
})



