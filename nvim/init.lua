--- Readme ----------------------------------------------------------------------------------------- {{{
--- `:help lua`, 查看 lua 设置.

--- https://github.com/LunarVim/Neovim-from-scratch
--- https://github.com/glepnir/nvim-lua-guide-zh

--- NOTE: 配置文件结构
--- 1. neovim 会首先查找 runtimepath 中的 init.lua 文件. - `:set runtimepath?`
---
--- 2. 我们的配置文件使用的是 vim.fn.stdpath("config") == "~/.config/nvim/".
---    vim.fn.stdpath("data") == "~/.local/share/nvim/"
---    vim.fn.stdpath("cache") == "~/.cache/nvim/"
---    neovim 启动时会找到 "~/.config/nvim/init.lua" 文件.
---    然后根据 init.lua 文件中的 require() 在所有的 runtimepath 中查找对应的文件.
---
--- 3. 配置文件 *.lua 中的 require("xxx") 文件必须是 runtimepath/lua/ 下的文件路径.
---    eg: ~/.local/share/nvim/site/pack/*/start/*, 这是插件的安装位置,
---        所有 lua 插件中都会有一个 "./lua/" 文件夹(纯 vim 插件没有, eg: vim-airline),
---        所以我们可以通过 require("xxx").setup() 调用插件方法.
---
--- 4. after/ftplugin, after/syntax, ftplugin 和 syntax 作用几乎一样, 却别在于:
--     - after/ftplugin 是针对文件的 filetype, 而 after/syntax 是针对文件的 syntax.
--       eg: json 文件filetype 是 json, 而 syntax 可以为 jsonc.
--     - after/ftplugin 在 after/syntax 之前加载.
---
--- 5. require 使用:
---    - 加载 ~/.config/nvim/lua/user/options.lua 单个文件, require "user.options" OR require "user/options" 省略 .lua
---    - 加载 ~/.config/nvim/lua/user/lsp/ 文件夹. VVI: 首先 lsp 文件夹中必须有 init.lua 文件,
---           然后使用 require "user/lsp" 直接加载整个 lsp 文件夹.
--
--- VVI: `_G` 全局变量/函数
--    nvim 中有一个 `_G` 全局变量. 自定义的所有全局变量和函数都会被放在 _G 内.
--    例如:
--      自定义了 __Proj_local_settings 变量, 则可以使用 __Proj_local_settings 或者 _G.__Proj_local_settings 访问.
--      自定义全局函数 Notify(xxx), 则可以使用 Notify(), 或者 _G.Notify() 调用函数.

--- NOTE: 常用函数
--    pcall(vim.cmd, "normal! n")         获取 command 返回信息
---   vim.inspect(table)                  打印 table 中的内容, 类似 fmt.Printf("%+v", struct)
---   table.insert({list}, elem)          向 list 中插入元素
---   table.concat({list}, "sep")         类似 string.join()
---   string.gsub("a b c", " ", "\\%%")   类似 string.replace()
---   vim.list_extend({list1}, {list2})   合并两个 list-like table
---   vim.tbl_deep_extend("force", {map1}, {map2}, {map3}...)  合并多个 map-like table
--    vim.split({string}, {sep}, {kwargs})
--    vim.fn.split({string}, {pattern}, {keepempty})
--    vim.fn.join({list}, sep)
--
--- NOTE: nvim 常用函数
--    vim.cmd(autocmd) -> vim.api.nvim_create_autocmd("BufEnter", {pattern, buffer=0, command/callback}),
--    vim.cmd(command) -> vim.api.nvim_create_user_command(), nvim_buf_create_user_command()
--    vim.keymap.set() -> 直接写 local function
--    vim.api.nvim_echo({{"A warning message: blahblah", "WarningMsg"}}, true, {})
--    vim.notify("msg", vim.log.levels.WARN) == vim.api.nvim_echo({{"A warning message: blahblah", "WarningMsg"}}, true, {})
--    vim.notify_once("msg", vim.log.levels.WARN)  只显示一次.
--    vim.lsp.buf.execute_command() && vim.lsp.util.apply_workspace_edit()
--    print(vim.inspect(vim.lsp.buf_get_clients())) -- VVI: lsp on_attach.

--- VVI: floating window 设置: `:help nvim_open_win()`

--- VVI: lua 转义符 `%` and `\`
--  local matches =
--  {
--    ["^"] = "%^";
--    ["$"] = "%$";
--    ["("] = "%(";
--    [")"] = "%)";
--    ["%"] = "%%";
--    ["."] = "%.";
--    ["["] = "%[";
--    ["]"] = "%]";
--    ["*"] = "%*";
--    ["+"] = "%+";
--    ["-"] = "%-";
--    ["?"] = "%?";
--
--    \n, \t, \r ...
--
--- NOTE: lua regex 正则
--  lua regex - string.match(), https://fhug.org.uk/kb/kb-article/understanding-lua-patterns/
--  }
--
--- NOTE: using filter, `:help filter`
--  使用方法:
--  1. 在行内写入 shell 代码. `cal -h -3`
--  2. filter command, `!!`, 不需要 `:`, 会在底部命令行区域出现 `:.!`, 进入 (filter) command 模式.
--     . 表示当前行.
--     ! 表示后面是 shell command.
--  3. ! 后输入 bash, cat, grep ... 等支持 pipe 的 shell command. 如果不支持 pipe 则不行, 例如 echo.
--
--  visual mode:
--  也可以在 visual select 之后, 按 `!`, 进入 (filter) command 模式 `:'<,'>!`
--
--  其他例子:
--  打开文件: line: `cat ~/.Desktop/foo.md`, cmd: `:.!bash`
--  打印日历: line: `cal -h -3`, cmd: `:.!bash`
--  过滤内容: line: `a/b/c`, cmd: `:.!awk -F/ '{print $1}'`  -- 替换成 a.
--  过滤行:   line: `abc`, `ccc`, `ddd`, visual select 之后 cmd: `:'<,'>!grep c`  --  剩下 `abc`, `ccc` 两行.
--
-- -- }}}

-------------------------------------+----------------------------------+------------------------------------
-- 常用 Commands                     | 作用                             | package
-------------------------------------+----------------------------------+------------------------------------
-- `:PackerSync`                     | Clean, Install, Update packages. | "wbthomason/packer.nvim"
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
-- eg: nvim --startuptime log src/main.go
-------------------------------------+----------------------------------+------------------------------------

--- VVI: 在最开始加载 "lewis6991/impatient.nvim" 设置,
--- Speed up loading Lua modules in Neovim to improve startup time.
require "user.plugin-settings.impatient"

--- 读取设置: ~/.config/nvim/lua/user/xxx.lua
require "user.util"      -- [必要], 自定义函数, 很多设置用到的常用函数.
require "user.settings"  -- vimrc 设置
require "user.keymaps"   -- keymap 设置
require "user.fold"      -- 代码折叠设置, NOTE: treesitter experimental function.
require "user.custom_commands"  -- 自定义命令
--require "user.terminal"  -- 自定义 terminal, 需要时可替代 toggle terminal.

--- 加载 plugins ---
require "user.plugins"  -- packer 加载 plugin

--- 放在最后 overwirte 其他颜色设置.
require "user.colors"  -- vim highlight 设置

--- TODO -------------------------------------------------------------------------------------------

--- update <leader>d airline buffer delete function.


