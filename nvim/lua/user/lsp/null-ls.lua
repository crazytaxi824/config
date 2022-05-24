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

--- VVI: linter / formatter / code action 设置 -----------------------------------------------------
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/MAIN.md  -- runtime_condition function 中的 params
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/CONFIG.md    -- setup 设置
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md  -- formatter & linter 列表
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md  -- with() 设置
local sources = {
  --- linters 设置 ---------------------------------------------------------------------------------
  diagnostics.flake8,  -- python, flake8

  --- golangci-lint
  diagnostics.golangci_lint.with(vim.tbl_deep_extend('keep', {
      extra_args = { "--config", ".golangci.yml" },  -- 相对项目根目录, 也可以用 vim.fn.expand("~/...") 等地址.
      --filetypes = { "go" },  -- 只对 go 文件生效.
    }, diagnostics_opts)),

  --- NOTE: eslint 分别对不同的 filetype 做不同的设置
  diagnostics.eslint.with(vim.tbl_deep_extend('keep', {
    extra_args = { "--config","eslintrc-ts.json" },
    filetypes = {"typescript"},
  }, diagnostics_opts)),
  diagnostics.eslint.with(vim.tbl_deep_extend('keep', {
    extra_args = { "--config","eslintrc-react.json" },
    filetypes = {"typescriptreact"},
  }, diagnostics_opts)),
  diagnostics.eslint.with(vim.tbl_deep_extend('keep', {
    extra_args = { "--config","eslintrc-js.json" },
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
  formatting.goimports, -- go, gofmt, goimports, gofumpt

  --- code actions 设置 ----------------------------------------------------------------------------
  code_actions.eslint,
}

--- null-ls 在这里加载上面设置的 formatting & linter -----------------------------------------------
--- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/CONFIG.md
null_ls.setup({
  --- VVI: 设置 linter / formatter / code actions
  sources = sources,

  debug = false,   -- 记录 log, `:NullLsLog` 打印 log. VVI: 非常耗资源, 调试完后设置为 false.

  update_in_insert = false,  -- 节省资源, 一边输入一边检查
  debounce = 600,            -- 节省资源, diagnostics 间隔时间, 默认 250
  diagnostics_format = "#{m} [null-ls]",  -- 错误信息显示格式, #{m} - message, #{s} - source, #{c} - err_code
  default_timeout = 5000,   -- lint 超时时间

  -- on_attach =
  -- on_exit =
  -- on_init = function(client, unused)

  --- NOTIFY: 加载某些 linter 的时候通知.
  on_attach = function(diag_client, unused)  -- NOTE: unused 是一个保留入参.
    local notify_status_ok, notify = pcall(require, "notify")
    if not notify_status_ok then
      return
    end

    local linters = {}   -- list of linter enabled
    local count = 0  -- for len(msg)
    for _, value in ipairs(diag_client.messages.progress) do
      if value.message ~= nil then
        table.insert(linters, value.message)
        count = count + 1
      end
    end
    if count > 0 then  -- 为了 len(msg)
      notify("Linter Loaded: " .. vim.fn.join(linters,","), "INFO", {title={"LSP", "null-ls.lua"}, timeout = 2000})
    end
  end,

  -- null-ls 退出的时候提醒.
  on_exit = function()
    local notify_status_ok, notify = pcall(require, "notify")
    if not notify_status_ok then
      return
    end
    notify("Null-ls exit. Please check ...", "WARN", {title = {"Null-ls"}, timeout = false})
  end
})



