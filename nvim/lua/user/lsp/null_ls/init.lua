local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

local s = require("user.lsp.null_ls.sources")

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

  --- log 输出到 stdpath('cache') .. '/null-ls.log', 目前无法修改.
  log_level = 'warn',  -- "error", "warn"(*), "info", "debug", "trace"

  --- 一边输入一边检查. false: 节省资源.
  update_in_insert = false,

  --- 两次请求的时间超过该设置才会向 null-ls 发送请求. 如果两次请求的时间小于该设置则不发送请求.
  --- NOTE: 这里相当于是 null-ls 的 "flags = {debounce_text_changes = xxx}" 设置.
  debounce = 500,  -- 默认 250.

  --- lint 超时时间, 30s. 默认为 5000, 5s.
  default_timeout = 30000,

  --- 错误信息显示格式. #{m} - err_msg; #{s} - source_name; #{c} - err_code
  diagnostics_format = "#{m} [null-ls]",

  --- 以下callback 都是 DEBUG: 用
  --- keymaps ---
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

  --- null-ls 退出的时候触发, 每次退出 vim 时也会触发.
  -- on_exit = function()
  --   Notify("Null-ls on_exit() event.", "warn", {title = "Null-ls"})
  -- end,
})



