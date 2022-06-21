--- nvim-notify ------------------------------------------------------------------------------------
--- `:help notify.Options`
--- `:help notify.Config`
local notify_status_ok, notify = pcall(require, "notify")
if not notify_status_ok then
  return
end

notify.setup({
  level = "TRACE",    -- "ERROR(4) > WARN(3) > INFO(2) > DEBUG(1) > TRACE(0)", NOTE: 大写, 这里不能用数字.
  stages = "static",  -- VVI: Animation style, for `set termguicolors`

  on_open = nil,
  on_close = nil,

  timeout = 5000,     -- Default timeout for notifications

  minimum_width = 50, -- Minimum width for notification windows
  max_width = nil,    -- Max number of columns for messages
  max_height = nil,   -- Max number of lines for a message

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
vim.cmd [[highlight NotifyERRORBorder ctermfg=167]] -- red
vim.cmd [[highlight NotifyWARNBorder  ctermfg=166]] -- orange
vim.cmd [[highlight NotifyINFOBorder  ctermfg=38]]  -- blue
vim.cmd [[highlight NotifyDEBUGBorder ctermfg=102]] -- grey
vim.cmd [[highlight NotifyTRACEBorder ctermfg=59]]  -- grey

--- Title 颜色
vim.cmd [[highlight NotifyERRORTitle ctermfg=197]]  -- magenta
vim.cmd [[highlight NotifyWARNTitle  ctermfg=208]]  -- orange
vim.cmd [[highlight NotifyINFOTitle  ctermfg=81]]   -- blue
vim.cmd [[highlight NotifyDEBUGTitle ctermfg=102]]  -- green
vim.cmd [[highlight NotifyTRACETitle ctermfg=59]]   -- grey

--- icon 颜色, NOTE: 没用到
vim.cmd [[highlight NotifyERRORIcon ctermfg=197]]
vim.cmd [[highlight NotifyWARNIcon  ctermfg=208]]
vim.cmd [[highlight NotifyINFOIcon  ctermfg=81]]
vim.cmd [[highlight NotifyDEBUGIcon ctermfg=102]]
vim.cmd [[highlight NotifyTRACEIcon ctermfg=59]]

--- 文字内容颜色
vim.cmd [[highlight link NotifyERRORBody Normal]]
vim.cmd [[highlight link NotifyWARNBody Normal]]
vim.cmd [[highlight link NotifyINFOBody Normal]]
vim.cmd [[highlight link NotifyDEBUGBody Normal]]
vim.cmd [[highlight link NotifyTRACEBody Normal]]



