--- Jump to file -----------------------------------------------------------------------------------
--- 利用 local list 跳转到 log 文件
function Jump_to_file(filepath, lnum, col)
  if not filepath then
    return
  end
  filepath = vim.fn.expand(filepath)

  if not lnum then  --- 如果 lnum 不存在, 跳到文件第一行.
    lnum = 1
  end

  if not col then
    col = 1
  end

  --- 如果 filepath 不可读取, 则直接 return. eg: filepath 错误
  if vim.fn.filereadable(filepath) == 0 then
    Notify('cannot open file: ' .. filepath, "DEBUG", {timeout = 1500})
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
  local loclist_items = {filename = filepath, lnum = lnum, col=col, text='jump_to_log_file()'}

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

--- file://xxxx
local function parse_file_scheme(content)
  if string.match(content, '^file://') then
    local _, e = string.find(content, 'file://')
    return string.sub(content, e+1)
  end
  return content
end

--- split filepath:lnum, NOTE: go_run_test.lua 文件会用到该函数.
function Parse_filepath(content)
  content = parse_file_scheme(content)

  local file, lnum, col
  local fp = vim.split(vim.fn.trim(content), ":")
  file = fp[1]
  if fp[2] then
    lnum = tonumber(fp[2])  -- tonumber(nil) = nil; tonumber('a') = nil
  end
  if lnum and fp[3] then
    col = tonumber(fp[3])
  end
  return file, lnum, col
end

--- terminal normal 模式跳转文件 -------------------------------------------------------------------
--- 操作方法: 在 Terminal Normal 模式中, 在行的任意位置使用 <CR> 跳转到文件.
function Cursor_cWORD_filepath()
  return Parse_filepath(vim.fn.expand('<cWORD>'))
end

--- TermClose 意思是 job done
--- TermLeave 意思是 term 关闭
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = {"term://*"},
  callback = function(params)
    vim.keymap.set('n', '<CR>',
      "<cmd>lua Jump_to_file(Cursor_cWORD_filepath())<CR>",
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
  return Parse_filepath(v_content)
end

vim.keymap.set('v', '<CR>',
  "<C-c>:lua Jump_to_file(Visual_selected_filepath())<CR>",
  {noremap = true, silent = true}
)



