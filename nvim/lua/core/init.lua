--- VVI: 以下需要事先加载.
require("core.funcs.fzf_edit")  -- 用于编辑 fzf multi selected item
require("core.funcs.notify")    -- Notify() 函数

require("core.colors")  -- 有全局变量 "Colors", 很多 plugins 需要用到
require("core.nerd_icons")  -- nerd fonts icons

require("core.options")  -- vimrc 设置
require("core.keymaps")

require("core.diagnostic")
require("core.lsp")  -- 加载 vim.lsp 相关设置. 不是 lspconfig 插件设置.

--- VVI: 以下使用 autocmd 设置相关 options, 需要放在 "core.options" 后加载.
require("core.fold")     -- lsp-fold & treesitter-fold autocmd
require("core.terminal") -- terminal buffer 自动设置 nonumber signcolumn ...


-- --- for bufferline sort order, 用进入时间排序
-- local bufvar = 'my_winenter_time'
-- vim.api.nvim_create_autocmd({"BufNew", "BufReadPre"}, {
--   callback = function(args)
--     if not vim.b[args.buf][bufvar] then
--       --- 注意这是 Neovim 启动后的相对时间，不是 unix timestamp
--       vim.b[args.buf][bufvar] = vim.uv.now()
--     end
--   end
-- })



