--- mode 变更的时候会自动刷新 statusline, 不需要 `:redrawstatus`

local M = {}

--- `:help mode()`
local mode_map = {
    n  = "NORMAL",
    no  = "O-PENDING",  -- eg: press `d` motion 后触发
    nov = "O-PENDING",
    noV = "O-PENDING",
    ["\22no"]   = "O-PENDING",  -- noCTRL-V
    niI = "NORMAL",  -- INSERT mode press `Ctrl-O`
    niR = "NORMAL",  -- REPLACE mode press `Ctrl-O`
    niV = "NORMAL",  -- Virtual-Replace mode `gR` press `Ctrl-O`, V-REPLACE 按屏幕显示宽度替换，考虑 tab、全角字符等占用的实际显示宽度.
    nt  = "NORMAL",  -- terminal normal mode, 按 `t_Ctrl-\_Ctrl-N` 退出 Terminal 模式.
    ntT = "NORMAL",  -- terminal `t_CTRL-\_CTRL-O` mode

    v  = "VISUAL",
    vs = "VISUAL",  -- Select 模式下 `Ctrl-O` 的临时 Visual
    V  = "V-LINE",
    Vs = "V-LINE",  -- S-LINE 模式下 `Ctrl-O` 的临时 V-LINE
    ["\22"]  = "V-BLOCK",  -- Ctrl-V
    ["\22s"] = "V-BLOCK",  -- Select mode 下 `Ctrl-V`

    s  = "SELECT",
    S  = "S-LINE",
    ["\19"] = "S-BLOCK",  -- Ctrl-S

    i  = "INSERT",
    ic = "INSERT",  -- completion, 按 `Ctrl-N` 或 `Ctrl-P` 触发补全时进入
    ix = "INSERT",  -- completion, 按 `Ctrl-X` 进入补全子模式，然后再按 `Ctrl-N/Ctrl-F/Ctrl-L` 等触发

    R   = "REPLACE",
    Rc  = "REPLACE",    -- completion
    Rx  = "REPLACE",    -- Ctrl-X completion
    Rv  = "V-REPLACE",
    Rvc = "V-REPLACE",  -- completion
    Rvx = "V-REPLACE",  -- Ctrl-X completion

    c  = "COMMAND",
    cr  = "COMMAND",    -- overstrike, Command 模式下按 Insert 键切换到 overstrike（覆盖输入）模式
    cv  = "EX",         -- Vim Ex mode, 按 `gQ` 进入 Vim Ex 模式
    cvr = "EX",         -- Ex mode overstrike, Ex 模式下按 Insert 键切换到 overstrike 模式

    t  = "TERMINAL",
}

---@return string
function M.mode()
  return mode_map[vim.fn.mode()] or vim.fn.mode()
end

return M
