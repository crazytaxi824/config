-- 利用 local list 跳转到 log 文件 -----------------------------------------------------------------

-- 操作方法: cursor 需要在 filepath string 上, 然后使用 <CR> 跳转到文件.
local function jump_to_log_file()
  local lcontent = vim.fn.getline('.')  -- current line content
  local fp = vim.split(lcontent, ":")

  local lnum = tonumber(fp[2])  -- tonumber(nil) = nil; tonumber('a') = nil
  if not lnum then  -- 如果没有 lnum 则设为 1
    lnum = 1
  end

  local go_run_win_id = -1  -- 用于设置 setloclist()
  local loc_items = nil     -- 初始化 local list item

  -- 寻找和 log 打印的 filepath 相同的 win_id. 如果有则跳转到该 window.
  for _, win_info in ipairs(vim.fn.getwininfo()) do
    local bufpath = vim.fn.fnamemodify(vim.fn.bufname(win_info.bufnr), ':p')  -- convert bufname to absolute path
    local logpath = vim.fn.fnamemodify(fp[1], ':p')  -- convert log path to absolute path

    if bufpath == logpath then  -- bufpath 和 logpath 相同的情况下, 跳转到该 window.
      go_run_win_id = win_info.winid
      loc_items = {filename = bufpath, lnum = lnum, text='jump_to_log_file()'}
      break
    elseif vim.fn.buflisted(win_info.bufnr) == 1 then
      -- 如果所有的 win 中都没有 log 打印的 filepath, 则选择一个 listed buffer 的 winid 用于跳转.
      go_run_win_id = win_info.winid
      break
    end
  end

  -- 如果所有的 win 中都没有 log 打印的 filepath, 则检查该 <cWORD> 是否是可以打开的文件.
  if not loc_items then
    if vim.fn.filereadable(fp[1]) == 1 then
      loc_items = {filename = fp[1], lnum = lnum, text='jump_to_log_file()'}
    end
  end

  -- 如果有 local list item, 则进行跳转.
  if loc_items then
    if vim.fn.win_gotoid(go_run_win_id) == 1 then
      vim.fn.setloclist(go_run_win_id, {loc_items}, 'r')  -- 给指定 window 设置 loclist
      vim.cmd('silent lfirst')  -- jump to loclist first item
      vim.fn.setloclist(go_run_win_id, {}, 'r')  -- clear loclist
    else
      -- 如果 go_run_win_id 不存在, 则在 terminal 上方创建一个新的 window.
      vim.cmd('leftabove split ' .. loc_items.filename)
      go_run_win_id = vim.fn.win_getid()
      vim.fn.setloclist(go_run_win_id, {loc_items}, 'r')  -- 给指定 window 设置 loclist
      vim.cmd('silent lfirst')  -- jump to loclist first item
      vim.fn.setloclist(go_run_win_id, {}, 'r')  -- clear loclist
    end
  end
end

--- TermClose 意思是 job done
--- TermLeave 意思是 term 关闭
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = {"term://*go run*toggleterm#*", "term://*go test*toggleterm#*"},
  callback = function()
    vim.keymap.set('n', '<CR>', jump_to_log_file, {noremap = true, buffer = true}) -- local to Terminal buffer
  end,
})


