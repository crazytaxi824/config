--- Jump to file -----------------------------------------------------------------------------------
--- 利用 local list 跳转到 log 文件
function Jump_to_file(filepath, lnum)
  if not filepath then
    return
  end

  if not lnum then  --- 如果 lnum 不存在, 跳到文件第一行.
    lnum = 1
  end

  --- 如果 filepath 不可读取, 则直接 return. eg: filepath 错误
  if vim.fn.filereadable(filepath) == 0 then
    return
  end

  --- 如果有 local list item, 则选择合适的 window 进行显示.
  local log_display_win_id  -- 用于设置 setloclist()

  --- 寻找第一个显示 listed-buffer 的 window 用于显示 log filepath.
  local all_win_info = vim.fn.getwininfo()
  for _, win_info in ipairs(all_win_info) do
    if vim.fn.buflisted(win_info.bufnr) == 1 then
      log_display_win_id = win_info.winid
      break
    end
  end

  --- `:help setqflist-what`
  local loclist_items = {filename = filepath, lnum = lnum, text='jump_to_log_file()'}

  if vim.fn.win_gotoid(log_display_win_id) == 1 then
    --- 如果 log_display_win_id 可以跳转则直接跳转.
    vim.fn.setloclist(log_display_win_id, {loclist_items}, 'r')  -- 给指定 window 设置 loclist
    vim.cmd('silent lfirst')  -- jump to loclist first item
    vim.fn.setloclist(log_display_win_id, {}, 'r')  -- VVI: clear loclist
  else
    --- 如果 log_display_win_id 不能跳转, 则在 terminal 正上方创建一个新的 window 用于显示 log filepath
    vim.cmd('leftabove split ' .. loclist_items.filename)
    log_display_win_id = vim.fn.win_getid()
    vim.fn.setloclist(log_display_win_id, {loclist_items}, 'r')  -- 给指定 window 设置 loclist
    vim.cmd('silent lfirst')  -- jump to loclist first item
    vim.fn.setloclist(log_display_win_id, {}, 'r')  -- VVI: clear loclist
  end
end

--- split filepath:lnum, NOTE: go_run_test.lua 文件会用到该函数.
function Parse_filepath(lcontent)
  local fp = vim.split(vim.fn.trim(lcontent), ":")
  if fp[2] then
    local lnum = tonumber(vim.split(fp[2], " ")[1])  -- tonumber(nil) = nil; tonumber('a') = nil
    return fp[1], lnum
  end
  return fp[1], nil
end

--- terminal normal 模式跳转文件 -------------------------------------------------------------------
--- 操作方法: 在 Terminal Normal 模式中, 在行的任意位置使用 <CR> 跳转到文件.
function Line_filepath()
  return Parse_filepath(vim.fn.getline('.'))
end

--- TermClose 意思是 job done
--- TermLeave 意思是 term 关闭
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = {"term://*"},
  callback = function(params)
    vim.keymap.set('n', '<CR>',
      "<cmd>lua Jump_to_file(Line_filepath())<CR>",
      {noremap = true, silent = true, buffer = params.buf} -- local to Terminal buffer
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

  --- 如果 v_content 不可读取, 则直接 return. eg: filepath 错误
  if vim.fn.filereadable(v_content) == 0 then
    Notify("cannot open file '" .. v_content .. "'", "DEBUG")
    return
  end

  return Parse_filepath(v_content)
end

vim.keymap.set('v', '<CR>',
  "<C-c>:lua Jump_to_file(Visual_selected_filepath())<CR>",
  {noremap = true, silent = true}
)



