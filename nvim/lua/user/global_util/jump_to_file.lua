--- Jump to file -----------------------------------------------------------------------------------
--- 利用 local list 跳转到 log 文件
function Jump_to_file(filepath, lnum)
  if not filepath then
    return
  end

  if not lnum then  --- 如果 lnum 不存在, 跳到文件第一行.
    lnum = 1
  end

  local same_file_win_id = -1  -- 用于设置 setloclist()
  local loc_items = nil     -- 初始化 local list item

  -- 寻找和 log 打印的 filepath 相同的 win_id. 如果有则跳转到该 window.
  for _, win_info in ipairs(vim.fn.getwininfo()) do
    local bufpath = vim.fn.fnamemodify(vim.fn.bufname(win_info.bufnr), ':p')  -- convert bufname to absolute path
    local logpath = vim.fn.fnamemodify(filepath, ':p')  -- convert log path to absolute path

    if bufpath == logpath then  -- bufpath 和 logpath 相同的情况下, 跳转到该 window.
      same_file_win_id = win_info.winid
      loc_items = {filename = bufpath, lnum = lnum, text='jump_to_log_file()'}
      break
    elseif vim.fn.buflisted(win_info.bufnr) == 1 then
      -- 如果所有的 win 中都没有 log 打印的 filepath, 则选择一个 listed buffer 的 winid 用于跳转.
      same_file_win_id = win_info.winid
      break
    end
  end

  -- 如果所有的 win 中都没有 log 打印的 filepath, 则检查该 filepath 是否是可以打开的文件.
  if not loc_items then
    if vim.fn.filereadable(filepath) == 1 then
      loc_items = {filename = filepath, lnum = lnum, text='jump_to_log_file()'}
    end
  end

  -- 如果有 local list item, 则进行跳转.
  if loc_items then
    if vim.fn.win_gotoid(same_file_win_id) == 1 then
      vim.fn.setloclist(same_file_win_id, {loc_items}, 'r')  -- 给指定 window 设置 loclist
      vim.cmd('silent lfirst')  -- jump to loclist first item
      vim.fn.setloclist(same_file_win_id, {}, 'r')  -- clear loclist
    else
      -- 如果 go_run_win_id 不存在, 则在 terminal 正上方创建一个新的 window.
      vim.cmd('leftabove split ' .. loc_items.filename)
      same_file_win_id = vim.fn.win_getid()
      vim.fn.setloclist(same_file_win_id, {loc_items}, 'r')  -- 给指定 window 设置 loclist
      vim.cmd('silent lfirst')  -- jump to loclist first item
      vim.fn.setloclist(same_file_win_id, {}, 'r')  -- clear loclist
    end
  end
end

--- split filepath:lnum
function Parse_filepath(lcontent)
  local fp = vim.split(vim.fn.trim(lcontent), ":")
  if fp[2] then
    local lnum = tonumber(vim.split(fp[2], " ")[1])  -- tonumber(nil) = nil; tonumber('a') = nil
    return fp[1], lnum
  end
  return fp[1], nil
end

--- terminal normal 模式跳转文件 -------------------------------------------------------------------
--- 操作方法: 在 terminal normal 模式中, 在行的任意位置使用 <CR> 跳转到文件.
function Line_filepath()
  return Parse_filepath(vim.fn.getline('.'))
end

--- TermClose 意思是 job done
--- TermLeave 意思是 term 关闭
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = {"term://*"},
  callback = function()
    vim.keymap.set('n', '<CR>',
      "<cmd>lua Jump_to_file(Line_filepath())<CR>",
      {noremap = true, silent = true, buffer = true} -- local to Terminal buffer
    )
  end,
})

--- VISIAL 模式跳转文件 ----------------------------------------------------------------------------
--- VISUAL 选中的 filepath, 不管在什么 filetype 中都跳转
--- 操作方法: visual select 'filepath:lnum', 然后使用 <CR> 跳转到文件.
function Visual_selected_filepath()
  --- NOTE: getpos("'<") 和 getpos("'>") 必须在 normal 模式执行, 意思是从 visual mode 退出后再执行以下函数.
  --- `:echo getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]-1]`
  local startpos = vim.fn.getpos("'<")
  local endpos = vim.fn.getpos("'>")

  --- 如果不在同一行则 return
  if startpos[2] ~= endpos[2] then
    return
  end

  local v_content = string.sub(vim.fn.getline("'<"), startpos[3], endpos[3])
  return Parse_filepath(v_content)
end

vim.keymap.set('v', '<CR>',
  "<C-c>:lua Jump_to_file(Visual_selected_filepath())<CR>",
  {noremap = true, silent = true}
)



