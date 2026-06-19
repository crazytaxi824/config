local fmter = require('myplugins.wbl.formatter')
local bimap = require('myplugins.wbl.bimap')

local M = {}

---@param opts { win_id: integer, bufnr: integer }
function M.binding_win_buf(opts)
  if not vim.api.nvim_buf_is_valid(opts.bufnr) or not vim.api.nvim_win_is_valid(opts.win_id) then
    error(string.format("Invalid win(%s), or bufnr(%s)", opts.win_id, opts.bufnr))
  end

  -- floating window 不显示 WinBarLine
  local win_cfg = vim.api.nvim_win_get_config(opts.win_id)
  if win_cfg.relative ~= '' then
    return
  end

  bimap.bind(opts)
end

---@param win_id integer
---@param focused? 'focused'|'auto'
---@param debug_msg? string
local function set_winbar(win_id, focused, debug_msg)
  if not vim.api.nvim_win_is_valid(win_id) then
    return
  end

  -- DEBUG
  if debug_msg then
    print(win_id, debug_msg)
  end

  local focus = false
  if focused == 'focused' then
    focus = true
  elseif focused == 'auto' then
    focus = win_id == vim.api.nvim_get_current_win()
  end

  local winbar_str = fmter.winbar_format(win_id, focus) or ''
  vim.api.nvim_set_option_value('winbar', winbar_str, { scope='local', win=win_id })
end

M.set_winbar = set_winbar

-- debounce set winbar for window
M.set_winbar_debounce = Debounce(set_winbar, 500)  -- NOTE: 500ms 比较适中


return M
