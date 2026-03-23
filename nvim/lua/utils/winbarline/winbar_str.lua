local wb_var = require('utils.winbarline.win_buf_var')


local sign_indicator = '▌'
local sign_modified = '●'


local M = {}


--- modify bufname
---
--- @param buf integer
--- @return string
local function bufname_mod(buf)
  local bufname = vim.api.nvim_buf_get_name(buf)
  if bufname ~= '' and vim.bo[buf].buflisted then
    return vim.fs.basename(bufname)
  elseif bufname ~= '' and not vim.bo[buf].buflisted then
    return '[' .. vim.fs.basename(bufname) .. ']'  -- unlisted buffer
  end

  --- 以下是特殊情况
  if vim.fn.getcmdwintype() ~= '' then
    return "[Command Line]"
  end

  local bt = vim.bo[buf].buftype
  if bt == "quickfix" then
    return "[Qf/Loc List]"
  elseif bt == "nofile" then
    return "[Scratch]"
  elseif bt == "terminal" then
    return "[Terminal]"
  elseif bt == "prompt" then
    return "[Prompt]"
  elseif bt == "help" then
    return "[Help]"
  else
    return "[No Name]"  -- buftype == ''
  end
end


--- 给单个 bufname 前后添加 highlight, idx, indicator
---
--- @param idx integer
--- @param bufnr integer
--- @param win_id integer
--- @return string
local function winbar_buf(idx, bufnr, win_id)
  local bufname = bufname_mod(bufnr)
  if bufname == '' then
    return ''
  end

  --- diagnostic
  local diagnostics = vim.diagnostic.count(bufnr) or {}
  local diag_count = 0
  local severity = 9
  for s, c in pairs(diagnostics) do
    diag_count = diag_count + c

    if s < severity then
      severity = s
    end
  end

  local str = ''
  if win_id == vim.api.nvim_get_current_win() and bufnr == vim.api.nvim_win_get_buf(win_id) then
    --- selected buffer
    str = '%#MyWinBarLineBufferSelectedIndicator#' .. sign_indicator .. '%#MyWinBarLineBufferSelected#' .. idx .. '. ' .. bufname

    if diag_count > 0 then
      str = str .. ' %#MyWinBarLineBufferSelectedSeverity_' .. severity ..  '#(' .. diag_count .. ')'
    end

    if vim.bo[bufnr].modified then
      str = str .. ' %#MyWinBarLineBufferSelectedModified#' .. sign_modified
    end
  else
    if bufnr == vim.api.nvim_win_get_buf(win_id) then
      --- visible buffer
      str = '%#MyWinBarLineBufferIndicator#' .. sign_indicator .. '%#MyWinBarLineBuffer#' .. idx .. '. ' .. bufname
    else
      --- other buffer
      str = '%#MyWinBarLineBuffer# ' .. idx .. '. ' .. bufname
    end

    if diag_count > 0 then
      str = str .. ' %#MyWinBarLineBufferSeverity_' .. severity ..  '#(' .. diag_count .. ')'
    end

    if vim.bo[bufnr].modified then
      str = str .. ' %#MyWinBarLineBufferModified#' .. sign_modified
    end
  end

  --- '%*' reset highlight
  str = str .. ' %*'

  return str
end


--- 将 window 的所有 buffer 拼接成 winbar string
---
--- @param win_id integer
--- @return string|nil
local function winbar_buffers(win_id)
  --- 没有 winvar 的 window 不显示 WinBarLine
  local win_bufs = wb_var.get_win_bufs(win_id)
  if not win_bufs then
    return
  end

  local str = ''
  local remove_idxes = {}

  for idx, buf in ipairs(win_bufs) do
    if vim.api.nvim_buf_is_valid(buf) then
      local winbar_buf_str = winbar_buf(idx, buf, win_id)
      if str == '' then
        str = winbar_buf_str
      else
        str = str .. " " .. winbar_buf_str
      end
    else
      --- 需要删除的 buffer 的 index, 倒序插入
      table.insert(remove_idxes, 1, idx)
    end
  end

  --- 从 win_bufs 中删除 invalid buffer
  for _, idx in ipairs(remove_idxes) do
    table.remove(win_bufs, idx)
  end

  --- 清除 invalid buffer 后重新赋值
  wb_var.set_win_bufs(win_id, win_bufs)

  --- 添加 tabpagenr
  local tabs = vim.api.nvim_list_tabpages()
  if #tabs > 1 then
    str = str .. '%=%#MyWinBarLineTab# ' .. vim.fn.tabpagenr() ..'/'.. #tabs .. ' '
  end

  return str
end


--- 通过 winvar 给 winbar 设置 buffers
---
--- @param win_id integer
function M.set_winbar(win_id)
  local winbar_str = winbar_buffers(win_id)

  if winbar_str then
    vim.api.nvim_set_option_value('winbar', winbar_str, { scope='local', win=win_id })
  end
end


return M
