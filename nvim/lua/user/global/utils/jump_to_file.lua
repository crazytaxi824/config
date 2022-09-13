--- highlight <file:line:col>, `:help pattern-overview` --------------------------------------------
function Highlight_filepath(data_list)
  --- file:// pattern match
  --- '\f' - isfname, 可用于 filename 的字符/数字/符号...
  --- '\<' - start of a word
  vim.fn.matchadd('Underlined', '\\<file://\\f*\\(:[0-9]\\+\\)\\{0,2}')  -- highlight filepath

  for _, lcontent in ipairs(data_list) do
    for _, content in ipairs(vim.split(lcontent, " ")) do
      --- VVI: 这里必须 trim(), 可以去掉 \r \n ...
      local fp = vim.split(vim.fn.trim(content), ":")

      local expand_status_ok, result = pcall(vim.fn.expand, fp[1])
      if expand_status_ok and vim.fn.filereadable(result) == 1 then
        --- \@<! - eg: \(foo\)\@<!bar  - any "bar" that's not in "foobar"
        --- \@!  - eg: foo\(bar\)\@!   - any "foo" not followed by "bar"
        vim.fn.matchadd('Underlined', '\\(\\S\\)\\@<!'..vim.fn.escape(fp[1], '~') .. '\\(:[0-9]\\+\\)\\{0,2}')  -- highlight filepath
      end
    end
  end
end

--- Jump to file -----------------------------------------------------------------------------------
--- 利用 local list 跳转到 log 文件, vim.fn.setloclist(win_id/winnr, {item_list}, 'r'/'a')
--- vim.fn.setloclist(1000, { {filename='src/main.go', lnum=1, col=1, text='jump_to_log_file()'} }, 'r'/'a')
--- 'r' - replace items; 'a' - append items
--- `:help setqflist-what`
function Jump_to_file(filepath, lnum, col)
  if not filepath or filepath == '' then  -- empty line
    return
  end

  --- 这里使用 pcall 是为了防止 vim.fn.expand('{foo') unescaped char {}[] ... 报错.
  local expand_status_ok, result = pcall(vim.fn.expand, filepath)
  if not expand_status_ok then
    Notify('cannot open file: ' .. filepath, "DEBUG", {timeout = 1500})
    return
  end

  filepath = result

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

  --- 在本 tab 中寻找第一个显示 listed-buffer 的 window, 用于显示 log filepath.
  local tab_wins = vim.fn.winnr('$')
  for i=1, tab_wins, 1 do
    local winid = vim.fn.win_getid(i)
    if vim.fn.buflisted(vim.api.nvim_win_get_buf(winid)) == 1 then
      log_display_win_id = winid
    end
  end

  local loclist_item = {filename = filepath, lnum = lnum, col=col, text='jump_to_log_file()'}

  if vim.fn.win_gotoid(log_display_win_id) == 1 then
    --- 如果 log_display_win_id 可以跳转则直接跳转.
    vim.fn.setloclist(log_display_win_id, {loclist_item}, 'r')  -- 给指定 window 设置 loclist, 'r' - replace, `:help setqflist-what`
    vim.cmd('silent lfirst')  -- jump to loclist first item
    vim.fn.setloclist(log_display_win_id, {}, 'r')  -- VVI: clear loclist
  else
    --- 如果 log_display_win_id 不能跳转, 则在 terminal 正上方创建一个新的 window 用于显示 log filepath
    vim.cmd('leftabove split ' .. loclist_item.filename)
    log_display_win_id = vim.fn.win_getid()
    vim.fn.setloclist(log_display_win_id, {loclist_item}, 'r')  -- 给指定 window 设置 loclist, 'r' - replace, `:help setqflist-what`
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

--- split filepath:lnum
local function parse_filepath(content)
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
  return parse_filepath(vim.fn.expand('<cWORD>'))
end

--- TermClose 意思是 job done
--- TermLeave 意思是 term 关闭
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = {"term://*"},
  callback = function(params)
    vim.keymap.set('n', '<CR>',
      "<cmd>lua Jump_to_file(Cursor_cWORD_filepath())<CR>",
      {noremap = true, silent = true, buffer = params.buf, desc = "Jump to file"} -- local to Terminal buffer
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
  return parse_filepath(v_content)
end

vim.keymap.set('v', '<CR>',
  "<C-c>:lua Jump_to_file(Visual_selected_filepath())<CR>",
  {noremap = true, silent = true, desc = "Jump to file"}
)



