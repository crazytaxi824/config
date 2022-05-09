--- Readme ----------------------------------------------------------------------------------------- {{{
--- `:help lua`, 查看 lua 设置.

--- https://github.com/LunarVim/Neovim-from-scratch
--- https://github.com/glepnir/nvim-lua-guide-zh

--- NOTE: 配置文件结构
--- 1. neovim 会首先查找 runtimepath 中的 init.lua 文件. - `:set runtimepath?`
---
--- 2. 我们的配置文件使用的是 vim.fn.stdpath("config") == "~/.config/nvim/".
---    vim.fn.stdpath("config") == "~/.local/share/nvim"
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

--- NOTE: 常用函数
---   vim.inspect(table)                  打印 table 中的内容, 类似 fmt.Printf("%+v", struct)
---   table.insert({list}, elem)          向 list 中插入元素
---   table.concat({list}, "sep")         类似 string.join()
---   string.gsub("a b c", " ", "\\%%")   类似 string.replace()
---   vim.list_extend({list1}, {list2})   合并两个 list-like table
---   vim.tbl_deep_extend("force", {map1}, {map2})  合并两个 map-like table
--    vim.fn.split({list}, sep, keepempty)
--    vim.fn.join({list}, sep)
--
--- NOTE: nvim 常用函数
--    vim.cmd(autocmd) -> vim.api.nvim_create_autocmd("BufEnter", {pattern, buffer=0, command/callback}),
--    vim.cmd(command) -> vim.api.nvim_create_user_command(), nvim_buf_create_user_command()
--    vim.keymap.set() -> 直接写 local function
--    vim.api.nvim_echo({{"A warning message: blahblah", "WarningMsg"}}, true, {})
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
--
--  }

--- }}}

-------------------------------------+----------------------------------+------------------------------------
-- 常用 Commands                     | 作用                             | package
-------------------------------------+----------------------------------+------------------------------------
-- `:PackerSync`                     | Clean, Install, Update packages. | "wbthomason/packer.nvim"
-- `:LspInstallInfo`                 | 所有 LSP 列表. 快捷键 - i, u, X  | "williamboman/nvim-lsp-installer"
-- `:TSInstallInfo`, `:TSUpdate`     | tree-sitter 安装列表.            | "nvim-treesitter/nvim-treesitter"
-- `:TSHighlightCapturesUnderCursor` | 查看当前 word tree-sitter 颜色.  | "nvim-treesitter/playground"
-- `:Notifications`                  | 查看 notify msg 列表             | "rcarriga/nvim-notify"
-------------------------------------+----------------------------------+------------------------------------

--- 读取设置: ~/.config/nvim/lua/user/xxx.lua
require "user.settings"  -- vimrc 设置
require "user.keymaps"   -- keymap 设置
require "user.fold"      -- 代码折叠设置, NOTE: treesitter experimental function.
require "user.util"      -- 自定义函数
--require "user.terminal"  -- 自定义 terminal, 需要时可替代 toggle terminal.

--- 加载 plugins ---
require "user.plugins"  -- packer 加载 plugin

--- 以下是 plugins 设置, 位置在 ~/.config/nvim/lua/user/plugin-settings/ ---
require "user.plugin-settings.impatient"   -- "lewis6991/impatient.nvim"
require "user.plugin-settings.autopairs"   -- "windwp/nvim-autopairs"
require "user.plugin-settings.indentline"  -- "lukas-reineke/indent-blankline.nvim"
require "user.plugin-settings.comment"     -- "numToStr/Comment.nvim"
require "user.plugin-settings.treesitter"  -- "nvim-treesitter/nvim-treesitter"
require "user.plugin-settings.nvim-tree"   -- "kyazdani42/nvim-tree.lua"
require "user.plugin-settings.airline"     -- "vim-airline/vim-airline"
require "user.plugin-settings.tagbar"      -- "preservim/tagbar"
require "user.plugin-settings.toggleterm"  -- "akinsho/toggleterm.nvim"
require "user.plugin-settings.telescope"   -- "nvim-telescope/telescope.nvim"
require "user.plugin-settings.notify"      -- "rcarriga/nvim-notify"
require "user.plugin-settings.which-key"   -- "folke/which-key.nvim"

--- lsp setting ---
require "user.lsp"    -- 如果加载地址为文件夹, 则会寻找文件夹中的 init.lua 文件.

--- 自动补全插件 cmp ---
require "user.plugin-settings.luasnip"  -- "L3MON4D3/LuaSnip"          -- snip engine
require "user.plugin-settings.cmp"      -- "hrsh7th/nvim-cmp"          -- The completion plugin
                                        -- "hrsh7th/cmp-buffer"        -- buffer completions
                                        -- "hrsh7th/cmp-path"          -- path completions
                                        -- "hrsh7th/cmp-cmdline"       -- cmdline completions
                                        -- "saadparwaiz1/cmp_luasnip"  -- snippet completions
                                        -- "hrsh7th/cmp-nvim-lsp"      -- lsp comletions

--- debug tool ---
require "user.plugin-settings.vimspector"

--- 放在最后 overwirte 其他颜色设置.
require "user.colors"  -- vim highlight 设置


-- TODO
-- zshrc backup nvim
-- godebug -- "puremourning/vimspector"
-- 不同的 workspace 单独设置.
-- vimspector launch config / settings
-- js / ts - launch project
--
--
-- FIXME
-- lspconfig 设置. hover 在 cursor 左右移动的时候不消失. insert 模式的时候不消失.




