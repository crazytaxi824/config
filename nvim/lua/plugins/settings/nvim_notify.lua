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
    ERROR = Nerd_icons.diag.error,
    WARN  = Nerd_icons.diag.warn,
    INFO  = Nerd_icons.diag.hint,
    DEBUG = "",
    TRACE = "◍",
  },
})

--- 使用方法:
-- require('telescope').extensions.notify.notify(<opts>)  -- 整合到 telescope
-- vim.print(require("notify").history())              -- `:Notifications` 查看 msg 列表
-- require("notify")("omg", "DEBUG", {title = "TTT"})  -- send notify message
-- require("notify")("omg", 0, {title = "TTT"})        -- send notify message

--- 颜色只对 notify 有用 ---------------------------------------------------------------------------
--- border 颜色
vim.api.nvim_set_hl(0, 'NotifyERRORBorder', {ctermfg=Color.red})
vim.api.nvim_set_hl(0, 'NotifyWARNBorder',  {ctermfg=Color.orange}) -- orange
vim.api.nvim_set_hl(0, 'NotifyINFOBorder',  {ctermfg=Color.blue})  -- blue
vim.api.nvim_set_hl(0, 'NotifyDEBUGBorder', {ctermfg=245}) -- grey
vim.api.nvim_set_hl(0, 'NotifyTRACEBorder', {ctermfg=241}) -- grey

--- Title 颜色
vim.api.nvim_set_hl(0, 'NotifyERRORTitle', {ctermfg=Color.red})  -- magenta
vim.api.nvim_set_hl(0, 'NotifyWARNTitle',  {ctermfg=Color.orange})
vim.api.nvim_set_hl(0, 'NotifyINFOTitle',  {ctermfg=Color.blue})
vim.api.nvim_set_hl(0, 'NotifyDEBUGTitle', {ctermfg=245})  -- grey
vim.api.nvim_set_hl(0, 'NotifyTRACETitle', {ctermfg=241})  -- grey

--- icon 颜色, NOTE: 没用到
vim.api.nvim_set_hl(0, 'NotifyERRORIcon', {ctermfg=Color.red})  -- magenta
vim.api.nvim_set_hl(0, 'NotifyWARNIcon',  {ctermfg=Color.orange})
vim.api.nvim_set_hl(0, 'NotifyINFOIcon',  {ctermfg=Color.blue})
vim.api.nvim_set_hl(0, 'NotifyDEBUGIcon', {ctermfg=245})  -- grey
vim.api.nvim_set_hl(0, 'NotifyTRACEIcon', {ctermfg=241})   -- grey

--- message 内容颜色, 包括背景颜色.
vim.api.nvim_set_hl(0, 'NotifyERRORBody', {link = 'Normal'})
vim.api.nvim_set_hl(0, 'NotifyWARNBody',  {link = 'Normal'})
vim.api.nvim_set_hl(0, 'NotifyINFOBody',  {link = 'Normal'})
vim.api.nvim_set_hl(0, 'NotifyDEBUGBody', {link = 'Normal'})
vim.api.nvim_set_hl(0, 'NotifyTRACEBody', {link = 'Normal'})



