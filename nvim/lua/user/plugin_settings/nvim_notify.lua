--- nvim-notify ------------------------------------------------------------------------------------
--- NOTE: notify 的窗口打开时设置是 set nowrap 的, 无法修改.
--- `:help notify.Options`
--- `:help notify.Config`
local notify_status_ok, notify = pcall(require, "notify")
if not notify_status_ok then
  return
end

notify.setup({
  level = "TRACE",  -- Minimum log level to display.
                    -- 可以使用 vim.log.levels (int); 也可以用 vim.log.levels,
                    -- 也可以使用 (string), 大小写都可以.

  stages = "static",  -- VVI: Animation style, for `set termguicolors`

  top_down = true,  -- true: top-down; false: bottom-up

  on_close = nil,
  on_open = function(win_id)
    local bufnr = vim.api.nvim_win_get_buf(win_id)

    --- set filetype 主要是为了 highlight. 默认 filetype = notify
    --vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
    vim.bo[bufnr].filetype = "markdown"

    --- 配合 markdown highlight.
    vim.wo[win_id].conceallevel = 2
    vim.wo[win_id].concealcursor = "nc"  -- 'nc' Normal & Command Mode 不显示 Concealed text.

    --- set keymap to close window
    vim.keymap.set('n', 'q', '<cmd>q<CR>', {noremap=true, buffer=bufnr, desc="close window"})
    --vim.keymap.set('n', '<ESC>', '<cmd>q<CR>', {noremap=true, buffer=bufnr, desc="close window"})
  end,

  timeout = 3000,     -- Default timeout for notifications

  minimum_width = 50, -- Minimum width for notification windows
  --- Max number of columns for messages
  max_width = function()
    --- vim.go.columns 整个屏幕的宽度
    return math.ceil(math.max(vim.go.columns / 2))
  end,
  --- Max number of lines for a message
  max_height = function()
    --- vim.go.lines 整个屏幕的高度
    return math.ceil(math.max(vim.go.lines / 3))
  end,

  -- Icons for the different levels
  icons = {
    ERROR = "◍",
    WARN  = "◍",
    INFO  = "◍",
    DEBUG = "◍",
    TRACE = "◍",
  },
})

--- 使用方法:
-- require('telescope').extensions.notify.notify(<opts>)  -- 整合到 telescope
-- print(vim.inspect(require("notify").history()))  -- `:Notifications` 查看 msg 列表
-- require("notify")("omg", "DEBUG", {title = "TTT"})  -- send notify message
-- require("notify")("omg", 0, {title = "TTT"})        -- send notify message

--- 颜色只对 notify 有用 ---------------------------------------------------------------------------
--- border 颜色
vim.cmd [[hi NotifyERRORBorder ctermfg=167]] -- red
vim.cmd [[hi NotifyWARNBorder  ctermfg=202]] -- orange
vim.cmd [[hi NotifyINFOBorder  ctermfg=38]]  -- blue
vim.cmd [[hi NotifyDEBUGBorder ctermfg=102]] -- grey
vim.cmd [[hi NotifyTRACEBorder ctermfg=59]]  -- grey

--- Title 颜色
vim.cmd [[hi NotifyERRORTitle ctermfg=197]]  -- magenta
vim.cmd [[hi NotifyWARNTitle  ctermfg=214]]  -- orange
vim.cmd [[hi NotifyINFOTitle  ctermfg=81]]   -- blue
vim.cmd [[hi NotifyDEBUGTitle ctermfg=102]]  -- green
vim.cmd [[hi NotifyTRACETitle ctermfg=59]]   -- grey

--- icon 颜色, NOTE: 没用到
vim.cmd [[hi NotifyERRORIcon ctermfg=197]]
vim.cmd [[hi NotifyWARNIcon  ctermfg=214]]
vim.cmd [[hi NotifyINFOIcon  ctermfg=81]]
vim.cmd [[hi NotifyDEBUGIcon ctermfg=102]]
vim.cmd [[hi NotifyTRACEIcon ctermfg=59]]

--- 文字内容颜色
vim.cmd [[hi! link NotifyERRORBody Normal]]
vim.cmd [[hi! link NotifyWARNBody Normal]]
vim.cmd [[hi! link NotifyINFOBody Normal]]
vim.cmd [[hi! link NotifyDEBUGBody Normal]]
vim.cmd [[hi! link NotifyTRACEBody Normal]]



