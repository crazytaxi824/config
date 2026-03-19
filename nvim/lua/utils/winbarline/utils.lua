local M = {}

M.winvar = "my_winbar"

local sign_indicator = '▌'
local sign_modified = '●'


--- 找出 value 在 list 中的 index
---
--- @generic T
--- @param list T[]
--- @param val T
--- @return integer|nil
function M.list_index_value(list, val)
  for i, v in ipairs(list) do
    if v == val then
      return i
    end
  end
end


--- 将一个 value 从 list 中 remove
---
--- @generic T
--- @param list T[]
--- @param val T
function M.list_remove_value(list, val)
  local idx = M.list_index_value(list, val)
  if idx then
    table.remove(list, idx)
  end
end


--- bufname modification
---
--- @param buf integer
--- @return string
local function bufname_mod(buf)
  local bufname = vim.api.nvim_buf_get_name(buf)

  if bufname == '' and vim.fn.buflisted(buf) == 1 then
    bufname = '[No Name]'
  elseif bufname == '' and vim.fn.buflisted(buf) == 0 then
    if vim.bo[buf].buftype == 'nofile' then
      bufname = '[Scratch]'  -- 特殊情况
    else
      bufname = '[' .. vim.bo[buf].buftype .. ']'
    end
  elseif bufname ~= '' and vim.fn.buflisted(buf) == 0 then
    bufname = '[' .. vim.fs.basename(bufname) .. ']'  -- unlisted buffer
  else
    bufname = vim.fs.basename(bufname)
  end

  return bufname
end


--- 给 bufname 前后添加 highlight, idx, indicator
---
--- @param idx integer
--- @param bufnr integer
--- @param selected? boolean  是否是 current window & current buffer
--- @return string
local function winbar_highlight(idx, bufnr, selected)
  local bufname = bufname_mod(bufnr)
  if bufname == '' then
    return ''
  end

  --- diagnostic count
  local count = vim.diagnostic.count(bufnr) or {}
  local total = 0
  for _, num in pairs(count) do
    total = total + num
  end

  local str = ''
  if selected then
    str = '%#MyWinBarLineBufferIndicator#' .. sign_indicator .. '%#MyWinBarLineBufferSelected#' .. idx .. '. ' .. bufname

    if count[vim.diagnostic.severity.ERROR] then
      str = str .. ' %#MyWinBarLineBufferSelectedError#(' .. total .. ')'
    elseif count[vim.diagnostic.severity.WARN] then
      str = str .. ' %#MyWinBarLineBufferSelectedWarn#(' .. total .. ')'
    elseif count[vim.diagnostic.severity.INFO] then
      str = str .. ' %#MyWinBarLineBufferSelectedInfo#(' .. total .. ')'
    elseif count[vim.diagnostic.severity.HINT] then
      str = str .. ' %#MyWinBarLineBufferSelectedHint#(' .. total .. ')'
    end

    if vim.bo[bufnr].modified then
      str = str .. ' %#MyWinBarLineBufferSelectedModified#' .. sign_modified
    end
  else
    str = '%#MyWinBarLineBuffer# ' .. idx .. '. ' .. bufname

    if count[vim.diagnostic.severity.ERROR] then
      str = str .. ' %#MyWinBarLineBufferError#(' .. total .. ')'
    elseif count[vim.diagnostic.severity.WARN] then
      str = str .. ' %#MyWinBarLineBufferWarn#(' .. total .. ')'
    elseif count[vim.diagnostic.severity.INFO] then
      str = str .. ' %#MyWinBarLineBufferInfo#(' .. total .. ')'
    elseif count[vim.diagnostic.severity.HINT] then
      str = str .. ' %#MyWinBarLineBufferHint#(' .. total .. ')'
    end

    if vim.bo[bufnr].modified then
      str = str .. ' %#MyWinBarLineBufferModified#' .. sign_modified
    end
  end

  str = str .. ' %*'

  return str
end


--- 通过 winvar 给 winbar 设置 buffers
---
--- @param win_id integer
--- @param enter? boolean  是否需要计算 selected buffer
function M.set_winbar(win_id, enter)
  local current_buf = vim.api.nvim_get_current_buf()

  --- 没有 winvar 的 window 不显示 WinBarLine
  local win_bufs = vim.w[win_id][M.winvar]
  if not win_bufs then
    return
  end

  local str = ''
  for idx, buf in ipairs(win_bufs) do
    local winbar_buf_str = winbar_highlight(idx, buf, enter and buf == current_buf)
    if str == '' then
      str = winbar_buf_str
    else
      str = str .. " " .. winbar_buf_str
    end
  end

  local tabs = vim.api.nvim_list_tabpages()
  if #tabs > 1 then
    str = str .. '%=%#MyWinBarLineTab# ' .. vim.fn.tabpagenr() .. ' '
  end

  vim.api.nvim_set_option_value('winbar', str, { scope='local', win=win_id })
end

return M
