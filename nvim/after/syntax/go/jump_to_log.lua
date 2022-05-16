-- 利用 local list 跳转到 log 文件 -----------------------------------------------------------------

-- 操作方法: cursor 需要在 filepath string 上, 然后使用 <CR> 跳转到文件.
local function gotoLogFile()
  local lcontent = vim.fn.expand('<cWORD>')  -- <cWORD> 以 %s 切分.
  local fp = vim.split(lcontent, ":")

  local lnum = tonumber(fp[2])
  if not lnum then  -- 如果没有 lnum 则设为 1
    lnum = 1
  end

  local go_run_win_id = -1  -- 用于设置 setloclist()
  local loc_items = nil     -- 初始化 local list item

  -- 寻找和 log 打印的 filepath 相同的 win_id. 如果有则跳转到该 window.
  for _, win_info in ipairs(vim.fn.getwininfo()) do
    local bufpath = vim.fn.fnamemodify(vim.fn.bufname(win_info.bufnr), ':p')  -- bufname full path

    -- FIXME when `go test` could print absolute path
    -- https://github.com/golang/vscode-go/issues/1875
    -- https://github.com/golang/go/issues/47399
    if string.match(bufpath, fp[1]) then  -- NOTE: 这里是临时措施, 主要是为 t.Log() 打印路径.
    --local logpath = vim.fn.fnamemodify(fp[1], ':p')  -- log full path
    --if bufpath == logpath then  -- 如果 bufpath 绝对路径和 logpath 绝对路径完全相同的情况下.
      go_run_win_id = win_info.winid
      loc_items = {filename = bufpath, lnum = lnum, text='function gotoLogFile()'}
      break
    elseif string.match(bufpath, ".*%.go$") then
      -- 如果所有的 win 中都没有 log 打印的 filepath, 则选择一个 .go 文件的 winid 用于跳转.
      go_run_win_id = win_info.winid
    end
  end

  -- 如果所有的 win 中都没有 log 打印的 filepath, 则检查该 <cWORD> 是否是可以打开的文件.
  if not loc_items then
    if vim.fn.filereadable(fp[1]) == 1 then
      loc_items = {filename = fp[1], lnum = lnum, text='function gotoLogFile()'}
    end
  end

  -- 如果有 local list item, 则进行跳转.
  if loc_items then
    if vim.fn.win_gotoid(go_run_win_id) == 1 then
      vim.fn.setloclist(go_run_win_id, {loc_items}, 'r')  -- 给指定 window 设置 loclist
      vim.cmd('lfirst')  -- jump to loclist first item
      vim.fn.setloclist(go_run_win_id, {}, 'r')  -- clear loclist
    else
      -- 如果 go_run_win_id 不存在, 则创建一个新的 window.
      vim.cmd('botright vsplit ' .. loc_items.filename)
      go_run_win_id = vim.fn.win_getid()
      vim.fn.setloclist(go_run_win_id, {loc_items}, 'r')  -- 给指定 window 设置 loclist
      vim.cmd('lfirst')  -- jump to loclist first item
      vim.fn.setloclist(go_run_win_id, {}, 'r')  -- clear loclist
    end
  end
end

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = {"term://*toggleterm#*"},
  callback = function()
    --- VVI: api.nvim_{buf}_set_keymap 需要使用 callback 来传入 local lua function
    vim.api.nvim_buf_set_keymap(0, 'n', '<CR>', '', {noremap = true, callback = gotoLogFile})
  end,
})


