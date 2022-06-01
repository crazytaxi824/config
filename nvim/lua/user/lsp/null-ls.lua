local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

--- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
--- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics
--- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/code_actions
local code_actions = null_ls.builtins.code_actions

--- diagnostics_opts 用于下面的 sources diagnostics 设置.
local diagnostics_opts = {
  method = null_ls.methods.DIAGNOSTICS_ON_SAVE,  -- 只在 save 的时候执行 diagnostics.
  runtime_condition = function(params)  -- NOTE: 耗资源, 每次运行 linter 前都要运行该函数, 不要做太复杂的运算.
    -- runtime_condition function 中的 params --- {{{
    --     content, -- current buffer content (table, split at newline)
    --     lsp_method, -- lsp method that triggered request (string)
    --     method, -- null-ls method that triggered generator (string)
    --     row, -- cursor's current row (number, zero-indexed)
    --     col, -- cursor's current column (number)
    --     bufnr, -- current buffer's number (number)
    --     bufname, -- current buffer's full path (string)
    --     ft, -- current buffer's filetype (string)
    --     root, -- current buffer's root directory (string)
    --
    -- }}}
    -- do not lint readonly files
    return not vim.bo.readonly
  end,
  --timeout = 3000,   -- linter 超时时间, 全局设置了 default_timeout.
  --diagnostics_format = "#{m} [null-ls:#{s}]",  -- 只对该 linter 生效.
}

--- linter / formatter / code action 设置 ----------------------------------------------------------
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/MAIN.md  -- runtime_condition function 中的 params
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/CONFIG.md    -- setup 设置
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md  -- formatter & linter 列表
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md  -- with() 设置
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/HELPERS.md -- $FILENAME, $DIRNAME, $ROOT ...
local util = require("null-ls/utils")
local sources = {
  --- linters 设置 ---------------------------------------------------------------------------------
  diagnostics.flake8,  -- python, flake8

  --- golangci-lint
  diagnostics.golangci_lint.with(vim.tbl_deep_extend('keep', {
      -- VVI: 执行 golangci-lint 的 pwd. 默认是 params.root 即: null_ls.setup() 中的 root_dir / $ROOT
      cwd = function(params)
        local new_root = util.root_pattern('go.work','go.mod','.git')(params.bufname)
        return new_root
      end,

      args = function(params)  -- NOTE: golangci-lint 命令的参数
        local new_root = util.root_pattern('go.work','go.mod','.git')(params.bufname)
        --- VVI: 这里必须要使用 $DIRNAME.
        ---  如果使用 $FILENAME, 则别的文件中定义的 var 无法被 golangci 找到.
        ---  如果缺省设置, 即不设置 $FILENAME 也不设置 $DIRNAME, 则每次 golangci 都会 lint 整个 project.
        return { "run", "--fix=false", "--fast", "--out-format=json", "--path-prefix", new_root, "$DIRNAME" }
      end,

      extra_args = { '--config', ".golangci.yml"},  -- NOTE: 相对 cwd 的路径, 也可以用 vim.fn.expand("~/...") 等地址.

      --filetypes = { "go" },  -- 只对 go 文件生效.
    }, diagnostics_opts)),

  --- NOTE: eslint 分别对不同的 filetype 做不同的设置
  diagnostics.eslint.with(vim.tbl_deep_extend('keep', {
    extra_args = { "--config", "eslintrc-ts.json" },
    filetypes = {"typescript"},
  }, diagnostics_opts)),
  diagnostics.eslint.with(vim.tbl_deep_extend('keep', {
    extra_args = { "--config", "eslintrc-react.json" },
    filetypes = {"typescriptreact"},
  }, diagnostics_opts)),
  diagnostics.eslint.with(vim.tbl_deep_extend('keep', {
    extra_args = { "--config", "eslintrc-js.json" },
    filetypes = {"javascript", "javascriptreact", "vue"},
  }, diagnostics_opts)),

  --- formatter 设置 -------------------------------------------------------------------------------
  --- NOTE: 需要在 lsp.setup(opts) 中的 on_attach 中排除 tsserver & sumneko_lua 的 formatting 功能
  formatting.prettier.with({
    --command = "/path/to/prettier",
    --env = { PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/xxx/.prettierrc.json") }  -- 环境变量
    --- NOTE: prettier 默认支持 .editorconfig 文件.
    extra_args = { "--single-quote", "--jsx-single-quote",
      "--print-width=" .. vim.bo.textwidth,  -- NOTE: 和 vim textwidth 相同.
      "--end-of-line=lf", "--tab-width=2" },
    disabled_filetypes = { "yaml" },  -- 不需要使用 prettier 格式化.
  }),

  formatting.stylua.with({   -- lua, stylua
    extra_args = { "--column-width=" .. vim.bo.textwidth },  -- NOTE: 和 vim textwidth 相同.
  }),

  formatting.autopep8,  -- python, autopep8, black

  --- go 需要在这里使用 'goimports', 因为 gopls 默认不会处理 "source.organizeImports",
  --- 但是需要 gopls 格式化 go.mod 文件.
  formatting.goimports, -- go, gofmt, goimports, gofumpt

  --- code actions 设置 ----------------------------------------------------------------------------
  --- NOTE: null-ls 不是 autostart 的, 需要触发操作后才会加载, 所以在 js/ts 中
  --- 第一次使用 code action 时会导致速度变慢.
  --code_actions.eslint,  -- 不建议开启. eslint 的 code_action 的主要作用是提示 disable 相应的 lint.
}

--- null-ls 在这里加载上面设置的 formatting & linter -----------------------------------------------
--- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/CONFIG.md
null_ls.setup({
  --- VVI: 设置 linter / formatter / code actions
  sources = sources,

  --- VVI: project root, 影响 linter 执行. root_dir 传入一个 function.
  root_dir = require("null-ls/utils").root_pattern(
    '.git', 'go.mod', 'go.work',
    'tsconfig.json', 'package.json', 'jsconfig.json'
  ),

  -- NOTE: 非常耗资源, 调试完后设置为 false.
  -- is the same as setting log.level to "trace" 记录 log, `:NullLsLog` 打印 log.
  debug = false,

  update_in_insert = false,  -- 节省资源, 一边输入一边检查
  debounce = 600,            -- 节省资源, diagnostics 间隔时间, 默认 250
  diagnostics_format = "#{m} [null-ls]",  -- 错误信息显示格式, #{m} - message, #{s} - source, #{c} - err_code
  default_timeout = 5000,   -- lint 超时时间

  -- on_attach =
  -- on_exit =
  -- on_init = function(client, unused)

  --- NOTIFY: 加载某些 linter 的时候通知 --- {{{
  -- on_attach = function(lsp_client, unused)  -- NOTE: unused 是一个保留入参.
  --   local linters = {}   -- list of linter enabled
  --   local count = 0  -- for len(msg)
  --   for _, value in ipairs(lsp_client.messages.progress) do
  --     if value.message ~= nil then
  --       table.insert(linters, value.message)
  --       count = count + 1
  --     end
  --   end
  --   if count > 0 then  -- 为了 len(msg)
  --     Notify("Linter Loaded: " .. vim.fn.join(linters,","), "INFO", {title={"LSP", "null-ls.lua"}, timeout = 2000})
  --   end
  -- end,
  -- -- }}}

  -- null-ls 退出的时候提醒.
  on_exit = function()
    Notify("Null-ls exit. Please check ':NullLsInfo' & ':NullLsLog'", "WARN", {title = {"LSP", "null-ls"}, timeout = false})
  end
})



