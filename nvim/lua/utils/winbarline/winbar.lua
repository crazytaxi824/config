local wb = require('utils.winbarline.win_buf_var')


local sign_indicator = '▌'
local sign_modified = '●'


local M = {}


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
--- @param win_id integer
--- @return string
local function winbar_highlight(idx, bufnr, win_id)
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
  if win_id == vim.api.nvim_get_current_win() and bufnr == vim.api.nvim_win_get_buf(win_id) then
    --- selected buffer
    str = '%#MyWinBarLineBufferSelectedIndicator#' .. sign_indicator .. '%#MyWinBarLineBufferSelected#' .. idx .. '. ' .. bufname

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
  elseif win_id ~= vim.api.nvim_get_current_win() and bufnr == vim.api.nvim_win_get_buf(win_id) then
    --- visible buffer
    str = '%#MyWinBarLineBufferIndicator#' .. sign_indicator .. '%#MyWinBarLineBuffer#' .. idx .. '. ' .. bufname

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
  else
    --- other buffer
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
function M.set_winbar(win_id)
  --- 没有 winvar 的 window 不显示 WinBarLine
  local win_bufs = wb.get_win_bufs(win_id)
  if not win_bufs then
    return
  end

  local str = ''
  local remove_idx = {}

  for idx, buf in ipairs(win_bufs) do
    if vim.api.nvim_buf_is_valid(buf) then
      local winbar_buf_str = winbar_highlight(idx, buf, win_id)
      if str == '' then
        str = winbar_buf_str
      else
        str = str .. " " .. winbar_buf_str
      end
    else
      --- 需要删除的 buffer 的 index, 倒序插入
      table.insert(remove_idx, 1, idx)
    end
  end

  --- 从 win_bufs 中删除 invalid buffer
  for _, remove in ipairs(remove_idx) do
    table.remove(win_bufs, remove)
  end

  --- 清除 invalid buffer 后重新赋值
  wb.set_win_bufs(win_id, win_bufs)

  --- tabpagenr
  local tabs = vim.api.nvim_list_tabpages()
  if #tabs > 1 then
    str = str .. '%=%#MyWinBarLineTab# ' .. vim.fn.tabpagenr() .. ' '
  end

  vim.api.nvim_set_option_value('winbar', str, { scope='local', win=win_id })
end


return M
