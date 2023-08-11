-------------------------------------+----------------------------------+------------------------------------
-- 常用 Commands                     | 作用                             | package
-------------------------------------+----------------------------------+------------------------------------
-- `:checkhealth`                    | (*) 检查 nvim 环境               | neovim
-------------------------------------+----------------------------------+------------------------------------
-- `:LspInfo`                        | 所有已启动的 LSP 列表.           | "neovim/nvim-lspconfig"
-------------------------------------+----------------------------------+------------------------------------
-- `:Mason`                          | lsp servers 安装辅助工具         | "williamboman/mason.nvim"
-------------------------------------+----------------------------------+------------------------------------
-- `:TSInstallInfo`                  | treesitter 安装列表.             | "nvim-treesitter/nvim-treesitter"
-- `:TSUpdate`                       | treesitter 安装/更新.            |
-- `:TSModuleInfo`                   | treesitter 模块当前状态.         |
-------------------------------------+----------------------------------+------------------------------------
-- `:TSHighlightCapturesUnderCursor` | 查看当前 word treesitter 颜色.   | "nvim-treesitter/playground"
-- `:TSPlaygroundToggle`             | treesitter 解析整个文件的信息.   |
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
  null_ls = false,  -- null-ls DEBUG, `:NullLsLog` & golangci-lint Notify msg.
  lspconfig = false,  -- lspconfig DEBUG, Notify msg.
  luasnip = false,  -- LuaSnip DEBUG, stdpath('log') .. '/luasnip.log' set_loglevel().
}

--- 读取设置: ~/.config/nvim/lua/user/xxx.lua
require "user.core"     -- VVI: 必须放在最前面加载, 因为有全局函数需要被用到.
require "user.colors"   -- VVI: 必须放在最前面加载, 因为有全局变量 "Color", 很多 plugins 需要用到.
require "user.options"  -- vimrc 设置
require "user.health"   -- 在 :checkhealth 时执行.
require "user.lsp"      -- 加载 vim.lsp/vim.diagnostic 相关设置. 这里不是插件设置, 是内置参数设置.
                        -- user/lsp 是个文件夹, 这里是加载的 user/lsp/init.lua

--- autcmd 相关设置
require "user.terminal" -- terminal buffer 自动设置 nonumber signcolumn ...
require "user.fold"     -- fold-lsp -> fold-treesitter -> fold-indent
require "user.wrap"     -- 根据 set wrap 设置 cursor move.

--- 加载 plugins 和 plugins' settings
require "user.plugins"

--- VVI: keymap 放在最后 overwirte 其他设置.
require "user.keymaps"  -- keymap 设置

require "user.misc"    -- 其他杂项设置.
require "user.global"  -- 自定义全局函数, 主要用于 debug. 可以不加载.

