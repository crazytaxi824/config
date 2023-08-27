--- VVI: 以下需要事先加载.
require("user.core.funcs.fzf_edit")  -- 用于编辑 fzf multi selected item
require("user.core.funcs.notify")    -- Notify() 函数

require "user.core.colors"   -- VVI: 必须放在最前面加载, 因为有全局变量 "Color", 很多 plugins 需要用到.
require "user.core.options"  -- vimrc 设置
require "user.core.keymaps"  -- keymap 设置
require "user.core.fold"     -- fold-lsp -> fold-treesitter
require "user.core.terminal" -- terminal buffer 自动设置 nonumber signcolumn ...
require "user.core.wrap"     -- 根据 set wrap 设置 cursor move.



