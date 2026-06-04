-- nvim-notify ------------------------------------------------------------------------------------
-- NOTE: notify 的窗口打开时设置是 set nowrap 的, 无法修改.
-- `:help notify.Options`
-- `:help notify.Config`
local notify_status_ok, notify = pcall(require, "notify")
if not notify_status_ok then
  return
end

notify.setup({
  level = "TRACE",  -- Minimum log level to display.
                    -- 可以使用 vim.log.levels (int); 也可以用 vim.log.levels,
                    -- 也可以使用 (string), 大小写都可以.

  stages = "slide",  -- VVI: Animation style, for `set termguicolors`
  background_colour = "#000000",

  top_down = false,  -- true: top-down; false: bottom-up

  on_close = nil,
  on_open = function(win_id)
    -- Notify window not focusable.
    vim.api.nvim_win_set_config(win_id, { focusable = false })

    -- set Notify content markdown syntax. 主要是为了 highlight.
    local bufnr = vim.api.nvim_win_get_buf(win_id)
    vim.bo[bufnr].filetype = "markdown"
  end,

  timeout = 3000,     -- Default timeout for notifications
  minimum_width = 50, -- Minimum width for notification windows

  -- Max number of columns for messages
  max_width = function()
    -- vim.go.columns 整个屏幕的宽度
    return math.ceil(math.max(vim.go.columns / 2))
  end,
  -- Max number of lines for a message
  max_height = function()
    -- vim.go.lines 整个屏幕的高度
    return math.ceil(math.max(vim.go.lines / 3))
  end,

  -- Icons for the different levels
  icons = {
    ERROR = Nerd_icons.diag[vim.diagnostic.severity.ERROR],
    WARN  = Nerd_icons.diag[vim.diagnostic.severity.WARN],
    INFO  = Nerd_icons.diag[vim.diagnostic.severity.INFO],
    DEBUG = "",  --  
    TRACE = "󰷺",  -- 󰷺
  },
})

-- 使用方法:
-- require('telescope').extensions.notify.notify(<opts>)  -- 整合到 telescope
-- vim.print(require("notify").history())              -- `:Notifications` 查看 msg 列表
-- require("notify")("omg", "DEBUG", {title = "TTT"})  -- send notify message
-- require("notify")("omg", 0, {title = "TTT"})        -- send notify message

-- 颜色只对 notify 有用 ---------------------------------------------------------------------------
-- border 颜色
vim.api.nvim_set_hl(0, 'NotifyERRORBorder', { link = 'DiagnosticError' })
vim.api.nvim_set_hl(0, 'NotifyWARNBorder',  { link = 'DiagnosticWarn' })
vim.api.nvim_set_hl(0, 'NotifyINFOBorder',  { link = 'DiagnosticInfo' })
vim.api.nvim_set_hl(0, 'NotifyDEBUGBorder', { link = 'DiagnosticHint' })
vim.api.nvim_set_hl(0, 'NotifyTRACEBorder', { link = 'DiagnosticHint' })

-- Title 颜色
vim.api.nvim_set_hl(0, 'NotifyERRORTitle', { link = 'DiagnosticError' })
vim.api.nvim_set_hl(0, 'NotifyWARNTitle',  { link = 'DiagnosticWarn' })
vim.api.nvim_set_hl(0, 'NotifyINFOTitle',  { link = 'DiagnosticInfo' })
vim.api.nvim_set_hl(0, 'NotifyDEBUGTitle', { link = 'DiagnosticHint' })
vim.api.nvim_set_hl(0, 'NotifyTRACETitle', { link = 'DiagnosticHint' })

-- icon 颜色, NOTE: 没用到
vim.api.nvim_set_hl(0, 'NotifyERRORIcon', { link = 'DiagnosticError' })
vim.api.nvim_set_hl(0, 'NotifyWARNIcon',  { link = 'DiagnosticWarn' })
vim.api.nvim_set_hl(0, 'NotifyINFOIcon',  { link = 'DiagnosticInfo' })
vim.api.nvim_set_hl(0, 'NotifyDEBUGIcon', { link = 'DiagnosticHint' })
vim.api.nvim_set_hl(0, 'NotifyTRACEIcon', { link = 'DiagnosticHint' })

-- message 内容颜色, 包括背景颜色.
vim.api.nvim_set_hl(0, 'NotifyERRORBody', { link = 'Normal' })
vim.api.nvim_set_hl(0, 'NotifyWARNBody',  { link = 'Normal' })
vim.api.nvim_set_hl(0, 'NotifyINFOBody',  { link = 'Normal' })
vim.api.nvim_set_hl(0, 'NotifyDEBUGBody', { link = 'DiagnosticHint' })
vim.api.nvim_set_hl(0, 'NotifyTRACEBody', { link = 'DiagnosticHint' })



