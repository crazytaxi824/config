--- VVI: 以下需要事先加载.
require("core.funcs.fzf_edit")  -- 用于编辑 fzf multi selected item
require("core.funcs.notify")    -- Notify() 函数
require("core.options")  -- vimrc 设置

require("core.colors")  -- 有全局变量 "Colors", 很多 plugins 需要用到.
require("core.nerd_icons")  -- nerd fonts icons
require("core.keymaps")
require("core.diagnostic")

--- VVI: 以下使用 autocmd 设置相关 options, 需要放在 "core.options" 后加载.
require("core.fold")     -- lsp-fold & treesitter-fold autocmd
require("core.terminal") -- terminal buffer 自动设置 nonumber signcolumn ...



