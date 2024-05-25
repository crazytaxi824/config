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

  stages = "fade_in_slide_out",  -- VVI: Animation style, for `set termguicolors`
  background_colour = "#000000",

  top_down = true,  -- true: top-down; false: bottom-up

  on_close = nil,
  on_open = function(win_id)
    --- Notify window not focusable.
    vim.api.nvim_win_set_config(win_id, { focusable = false })

    --- set Notify content markdown syntax. 主要是为了 highlight.
    local bufnr = vim.api.nvim_win_get_buf(win_id)
    vim.bo[bufnr].filetype = "markdown"

    --- set keymap to close window
    vim.keymap.set('n', 'q', '<cmd>q<CR>', { buffer=bufnr, desc="close window" })
  end,

  timeout = 5000,     -- Default timeout for notifications
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
    DEBUG = "",  --  
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
vim.api.nvim_set_hl(0, 'NotifyERRORBorder', {ctermfg=Colors.red.c, fg=Colors.red.g})
vim.api.nvim_set_hl(0, 'NotifyWARNBorder',  {ctermfg=Colors.orange.c, fg=Colors.orange.g}) -- orange
vim.api.nvim_set_hl(0, 'NotifyINFOBorder',  {ctermfg=Colors.blue.c, fg=Colors.blue.g})  -- blue
vim.api.nvim_set_hl(0, 'NotifyDEBUGBorder', {ctermfg=Colors.g246.c, fg=Colors.g246.g}) -- grey
vim.api.nvim_set_hl(0, 'NotifyTRACEBorder', {ctermfg=Colors.g240.c, fg=Colors.g240.g}) -- grey

--- Title 颜色
vim.api.nvim_set_hl(0, 'NotifyERRORTitle', {ctermfg=Colors.red.c, fg=Colors.red.g})
vim.api.nvim_set_hl(0, 'NotifyWARNTitle',  {ctermfg=Colors.orange.c, fg=Colors.orange.g}) -- orange
vim.api.nvim_set_hl(0, 'NotifyINFOTitle',  {ctermfg=Colors.blue.c, fg=Colors.blue.g})  -- blue
vim.api.nvim_set_hl(0, 'NotifyDEBUGTitle', {ctermfg=Colors.g246.c, fg=Colors.g246.g}) -- grey
vim.api.nvim_set_hl(0, 'NotifyTRACETitle', {ctermfg=Colors.g240.c, fg=Colors.g240.g}) -- grey

--- icon 颜色, NOTE: 没用到
vim.api.nvim_set_hl(0, 'NotifyERRORIcon', {ctermfg=Colors.red.c, fg=Colors.red.g})
vim.api.nvim_set_hl(0, 'NotifyWARNIcon',  {ctermfg=Colors.orange.c, fg=Colors.orange.g}) -- orange
vim.api.nvim_set_hl(0, 'NotifyINFOIcon',  {ctermfg=Colors.blue.c, fg=Colors.blue.g})  -- blue
vim.api.nvim_set_hl(0, 'NotifyDEBUGIcon', {ctermfg=Colors.g246.c, fg=Colors.g246.g}) -- grey
vim.api.nvim_set_hl(0, 'NotifyTRACEIcon', {ctermfg=Colors.g240.c, fg=Colors.g240.g}) -- grey

--- message 内容颜色, 包括背景颜色.
vim.api.nvim_set_hl(0, 'NotifyERRORBody', {link = 'Normal'})
vim.api.nvim_set_hl(0, 'NotifyWARNBody',  {link = 'Normal'})
vim.api.nvim_set_hl(0, 'NotifyINFOBody',  {link = 'Normal'})
vim.api.nvim_set_hl(0, 'NotifyDEBUGBody', {link = 'Normal'})
vim.api.nvim_set_hl(0, 'NotifyTRACEBody', {link = 'Normal'})



