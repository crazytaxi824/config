-------------------------------------+----------------------------------+------------------------------------
-- 常用 Commands                     | 作用                             | package
-------------------------------------+----------------------------------+------------------------------------
-- `:checkhealth`                    | (*) 检查 nvim 环境               | neovim 自带
-- `:Inspect`                        | 查看当前 word treesitter 颜色.   |
-- `:InspectTree`                    | treesitter 解析整个文件的信息.   |
-- `:PreviewQuery`                   | treesitter 解析整个文件的信息.   | neovim v0.10+
-------------------------------------+----------------------------------+------------------------------------
-- `:TSInstallInfo`                  | treesitter 安装列表.             | "nvim-treesitter/nvim-treesitter"
-- `:TSUpdate`                       | treesitter 安装/更新.            |
-- `:TSModuleInfo`                   | treesitter 模块当前状态.         |
-------------------------------------+----------------------------------+------------------------------------
-- `:LspInfo`                        | 所有已启动的 LSP 列表.           | "neovim/nvim-lspconfig"
-------------------------------------+----------------------------------+------------------------------------
-- `:Mason`                          | lsp servers 安装辅助工具         | "williamboman/mason.nvim"
-------------------------------------+----------------------------------+------------------------------------
-- `:Notifications`                  | 查看 notify msg 列表             | "rcarriga/nvim-notify"
-------------------------------------+----------------------------------+------------------------------------
-- `:NullLsLog`                      | 查看 null-ls debug log           | "jose-elias-alvarez/null-ls.nvim"
-- `:NullLsInfo`                     | 查看 null-ls 加载信息            |
-------------------------------------+----------------------------------+------------------------------------
-- `$ nvim --startuptime log src/main.go`  -- 将 nvim 打开 open_file 过程中的所有耗时打印到 ./log 文件中
-- `$ nvim --clean src/main.go`   -- 不加载任何 plugins
-------------------------------------+----------------------------------+------------------------------------

--- for Debugging Neovim plugins. `:LspInfo`, `:LspLog`
__Debug_Neovim = {
  lsp = false,  -- vim.lsp DEBUG, Notify msg.
  null_ls = false,  -- null-ls DEBUG, `:NullLsLog` & golangci-lint Notify msg.
  luasnip = false,  -- LuaSnip DEBUG, stdpath('log') .. '/luasnip.log' set_loglevel().
  dap_debug = false,  -- `:help dap.set_log_level()`
  autocmd = false,  -- debug_autocmd.lua
}

--- 读取设置: ~/.config/nvim/lua/xxx.lua
require("core")     -- VVI: 必须放在最前面加载, 因为有全局函数需要被用到.

require("plugins")  -- 加载 plugins 和 plugins' settings
require("misc")     -- 其他设置.



