-------------------------------------+----------------------------------+------------------------------------
-- 常用 Commands                     | 作用                             | package
-------------------------------------+----------------------------------+------------------------------------
-- `:checkhealth`                    | (*) 检查 nvim 环境               | neovim
-------------------------------------+----------------------------------+------------------------------------
-- `:PackerClean`                    | Remove disabled/unused plugins.  | "wbthomason/packer.nvim"
-- `:PackerCompile`                  | 每次修改 packer.startup() 设置都需要重新运行 PackerCompile 否则修改不生效.
-- `:PackerSync`                     | :PackerUpdate, Compile plugins.  | *
-- `:PackerSnapshot foo`             | 拍摄快照记录 plugins 版本        |
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
-- `:LuaCacheProfile`                | 查看文件加载时间                 | "lewis6991/impatient.nvim" 需要 enable_profile()
-- `:LuaCacheClear`                  | 清空缓存文件, 下次启动重新生成   |    清空 luacache_chunks, luacache_modpaths
-------------------------------------+----------------------------------+------------------------------------
-- `$ nvim --startuptime [logfile] [open_file]`  -- 将 nvim 打开 open_file 过程中的所有耗时打印到 logfile 中
-- eg: `$ nvim --startuptime log src/main.go`    -- 将 nvim 打开 open_file 过程中的所有耗时打印到 ./log 文件中
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
require "user.settings" -- vimrc 设置
require "user.lsp"      -- 加载 vim.lsp/vim.diagnostic 相关设置. 这里不是插件设置, 是内置参数设置.
                        -- user/lsp 是个文件夹, 这里是加载的 user/lsp/init.lua
require "user.fold"

--- terminal 相关设置
require "user.terminal" -- terminal settings
require "user.term_instances"  -- my_term 实例

require "user.wrap" -- autocmd 根据 filetype 设置 set wrap && cursor move.
require "user.misc" -- 其他杂项设置. 例如 autocmd VimEnter, VimLeave ...

--- 加载 plugins 和 plugins' settings
require "user.plugins_loader"

--- VVI: keymap 放在最后 overwirte 其他设置.
require "user.keymaps"  -- keymap 设置

require "user.global"   -- 自定义全局函数, 主要用于 debug. 可以不加载.

