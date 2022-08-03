-------------------------------------+----------------------------------+------------------------------------
-- 常用 Commands                     | 作用                             | package
-------------------------------------+----------------------------------+------------------------------------
-- `:checkhealth`                    | (*) 检查 nvim 环境               | neovim
-------------------------------------+----------------------------------+------------------------------------
-- `:PackerClean`                    | Remove disabled/unused plugins.  | "wbthomason/packer.nvim"
-- `:PackerCompile`                  | Regenerate compiled loader file. |
-- `:PackerInstall`                  | Clean, Install missing plugins.  |
-- `:PackerUpdate`                   | Clean, Update, Install plugins.  |
-- `:PackerSync`                     | :PackerUpdate, Compile plugins.  | *
-- `:PackerSnapshot foo`             | 拍摄快照记录 plugins 版本        |
-------------------------------------+----------------------------------+------------------------------------
-- `:LspInfo`                        | 所有已启动的 LSP 列表.           | "neovim/nvim-lspconfig"
-------------------------------------+----------------------------------+------------------------------------
-- `:LspInstallInfo`                 | 所有 LSP 列表. 快捷键 - i, u, X  | "williamboman/nvim-lsp-installer"
-------------------------------------+----------------------------------+------------------------------------
-- `:TSInstallInfo`, `:TSUpdate`     | treesitter 安装列表.             | "nvim-treesitter/nvim-treesitter"
-------------------------------------+----------------------------------+------------------------------------
-- `:TSHighlightCapturesUnderCursor` | 查看当前 word treesitter 颜色.   | "nvim-treesitter/playground"
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

--- VVI: 在最开始加载 "lewis6991/impatient.nvim" 设置,
--- it is recommended you add the following near the start of your 'init.vim'.
--- Speed up loading Lua modules in Neovim to improve startup time.
require "user.plugin_settings.impatient"

--- 读取设置: ~/.config/nvim/lua/user/xxx.lua
require "user.global_util"  -- [必要], 自定义函数, 很多设置用到的常用函数.
require "user.settings"     -- vimrc 设置
require "user.lsp"          -- 加载 vim.lsp/vim.diagnostic 相关设置. 这里不是插件设置, 是内置参数设置.
                            -- user/lsp 是个文件夹, 这里是加载的 user/lsp/init.lua
require "user.keymaps"      -- keymap 设置
require "user.fold"         -- 代码折叠设置, NOTE: treesitter experimental function.
--require "user.terminal"   -- 自定义 terminal, 学习/测试用. 需要时可替代 toggle terminal.

--- 加载 plugins 和 settings
require "user.plugins_loader"  -- packer 加载 plugin

--- 放在最后 overwirte 其他颜色设置
require "user.colors"   -- vim highlight 设置

--- TODO -------------------------------------------------------------------------------------------



