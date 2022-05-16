-- 利用 local list 跳转到 log 文件 -----------------------------------------------------------------
-- 用来储存 setloclist() 用的 winnr.
-- FIXME WinEnter 时更新 go_run_win_id
go_run_win_id = vim.fn.win_getid()
-- if not go_run_win_id then
--   print('not')
--   go_run_win_id = {vim.fn.win_getid()}
-- else
--   print('ok')
--   table.insert(go_run_win_id, vim.fn.win_getid())
-- end

-- 操作方法: cursor 需要在 filepath string 上, 然后使用 <CR> 跳转到文件.
local function gotoLogFile()
  local lcontent = vim.fn.expand('<cWORD>')  -- <cWORD> 以 %s 切分.

  local fp = vim.split(lcontent, ":")

  local lnum = tonumber(fp[2])
  if not lnum then
    lnum = 1
  end

  local locitem = nil
  if vim.fn.filereadable(fp[1]) == 1 then
    locitem = {filename = fp[1], lnum = lnum}
  else
    -- 如果 go_run_win_id 窗口中的 bufname 和 log 打印出来的文件名相同, 则跳转到该文件.
    local bufname = vim.fn.bufname(vim.fn.getwininfo(go_run_win_id)[1].bufnr)
    if vim.fn.fnamemodify(bufname, ':t') == fp[1] then
      locitem = {filename = bufname, lnum = lnum}
    end
  end

  if locitem then
    -- TODO if go_run_win_id 不存在, 则创建一个新的 window.

    vim.fn.setloclist(go_run_win_id, {locitem}, 'r')  -- 给指定 window 设置 loclist
    vim.fn.win_gotoid(go_run_win_id)  -- 必须在该 window 下才能打开 loclist
    vim.cmd('lfirst')  -- jump to loclist first item
    vim.fn.setloclist(go_run_win_id, {}, 'r')  -- clear loclist
  end
end

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = {"term://*toggleterm#*"},
  callback = function()
    --- VVI: api.nvim_{buf}_set_keymap 需要使用 callback 来传入 local lua function
    vim.api.nvim_buf_set_keymap(0, 'n', '<CR>', '', {noremap = true, callback = gotoLogFile})
  end,
})


