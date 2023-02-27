local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

local s = require("user.lsp.null_ls.sources")

--- 检查 null-ls 所需 tools ------------------------------------------------------------------------ {{{
--- 在 null_ls.setup() 的时候, 如果命令行工具不存在不会报错;
--- 在使用的时候 (eg:Format) 如果命令行工具不存在才会报错.
local null_tools = {
  {
    cmd="goimports",
    install="go install golang.org/x/tools/cmd/goimports@latest",
    mason="goimports",
  },
  {
    cmd="goimports-reviser",
    mason="goimports-reviser",
  },
  {
    cmd="golangci-lint",
    install="go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest",
    mason="golangci-lint",
  },
  {
    cmd="buf",  -- protobuf formatter & linter
    install="go install github.com/bufbuild/buf/cmd/buf@latest",
    mason = "buf",
  },

  {cmd="prettier", install=" brew info prettier", mason="prettier"},
  {cmd="shfmt", install="brew info shfmt", mason="shfmt"},
  --{cmd="stylua", install="brew info stylua", mason="stylua"},

  {cmd="flake8", install="pip3 install flake8", mason="flake8"},
  {cmd="autopep8", install="pip3 install autopep8", mason="autopep8"},
  {cmd="mypy", install="pip3 install mypy", mason="mypy"}, -- 还有个 mypy-extensions 是 mypy 插件

  {cmd="eslint", install="npm install -g eslint"}, -- NOTE: mason 暂时不能安装 "eslint"
}

require('user.utils.check_tools').check(null_tools, {title= "check null-ls tools"})
-- -- }}}

--- 合并 sources 到一个 list
local function combine_sources()
  local list = {}

  for _, tool_types in pairs(s.sources) do
    for _, tool_setup in pairs(tool_types) do
      table.insert(list, tool_setup())
    end
  end

  return list
end

--- null-ls setup() 在这里加载上面设置的 formatting & linter ---------------------------------------
--- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/CONFIG.md
null_ls.setup({
  --- VVI: 设置 linter / formatter / code actions
  sources = combine_sources(),

  --- VVI: project root, 影响 linter 执行时的 pwd. 这里的 root_dir 是一个全局设置,
  --- 对 null-ls 中的所有 linter 有效. root_dir 需要传入一个回调函数 func(params):string.
  --- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/MAIN.md#generators
  --- 默认值: root_dir = require("null-ls.utils").root_pattern(".null-ls-root", "Makefile", ".git")
  --- 如果 utils.root_pattern() 返回 nil, 则 root_dir 会被设置成当前路径 vim.fn.getcwd().
  ---
  --- PROBLEM: null-ls 的 root_dir 只会运行一次. 而 lspconfig 的 root_dir 在每次打开 buffer 时都会执行.
  --- Q: 为什么要在每次执行 linter 时单独获取 pwd 路径?
  --- A: 因为 nvim 可能会在多个项目文件之间跳转, 每个项目有自己单独的 root.
  --- HOW: 单独为 linter 设置 cwd = func(params):string, 参考 tools/golangci.lua
  --root_dir = function(params) return vim.fn.getcwd() end,

  --- 如果 error msg 没有特别指明 severity level, 则会使用下面的设置.
  fallback_severity = vim.diagnostic.severity.WARN,

  --- NOTE: 非常耗资源, 调试完后设置为 false.
  --- is the same as setting log.level to "trace" 记录 log, `:NullLsLog` 打印 log.
  debug = __Debug_Neovim.null_ls,

  --- log 输出到 stdpath('cache') .. '/null-ls.log'
  log = {
    enable = true,
    level = 'warn',  -- "error", "warn"(*), "info", "debug", "trace"

    --- show log output in Neovim's ':messages'.
    --- sync is slower but guarantees that messages will appear in order.
    use_console = 'async',  -- "sync", "async"(*), false.
  },

  update_in_insert = false,  -- 节省资源, 一边输入一边检查
  debounce = 500,  -- 默认 250.
                   -- NOTE: 这里相当于是 null-ls 的 "flags = {debounce_text_changes = xxx}" 设置.
                   -- 停止输入文字的时间超过该数值, 则向 null-ls 发送请求.
                   -- 如果 "update_in_insert = false", 则该设置应该不生效.
  default_timeout = 5000,  -- lint 超时时间
  diagnostics_format = "#{m} [null-ls]",  -- 错误信息显示格式,
                                          -- #{m} - message, #{s} - source, #{c} - err_code

  --- 以下callback 都是 DEBUG: 用
  --- 设置 key_mapping vim.diagnostic.goto_next() ...
  on_attach = function(client, bufnr)
    require("user.lsp.lsp_keymaps").diagnostic_keymaps(bufnr)

    if __Debug_Neovim.null_ls then
      Notify("LSP Server attach: " .. client.name, "DEBUG", {title="Null-ls"})
    end
  end,

  on_init = function(client, init_result)
    --- DEBUG: 用
    if __Debug_Neovim.null_ls then
      Notify("LSP Server init: " .. client.name, "DEBUG", {title="Null-ls"})
    end
  end,

  --- null-ls 退出的时候触发.
  --on_exit = function() ... end,
})



