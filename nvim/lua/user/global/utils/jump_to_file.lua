--- highlight <file:line:col> ----------------------------------------------------------------------
vim.cmd('hi Filepath cterm=underline')  -- 自定义颜色, for Highlight_filepath()
vim.cmd('hi URL cterm=underline ctermfg=75')  -- 自定义颜色, for Highlight_filepath()

--- NOTE: `:help pattern-overview`, vim pattern.
function Highlight_filepath()
  --- file:///abc/def.txt
  --- '\f' - isfname, 表示可用于 filename 的字符/数字/符号...
  --- '\<' - start of a word
  vim.fn.matchadd('Filepath',
    '\\<file://'  -- 'file://' 开头
    .. '\\f\\+'  -- filename 可以用字符. '\+' 表示至少有一个字符.
    .. '\\(:[0-9]\\+\\)\\{0,2}'  -- ':num:num' | ':num' | '' (空)
  )

  --- ~/xxx | ./xxx | /xxx
  --- \@<! - eg: \(foo\)\@<!bar  - any "bar" that's not in "foobar"
  --- \@!  - eg: foo\(bar\)\@!   - any "foo" not followed by "bar"
  vim.fn.matchadd('Filepath',
    '\\(\\S\\)\\@<!'   -- 表示前面不能是 (\S) non-whitespace, 意思是只能是 whitespace 或者 ^.
    .. '[~.]\\{0,1}/'  -- '~/' | './' | '/' 开头
    .. '\\f\\+'  -- filename 可以用字符. '\+' 表示至少有一个字符.
    .. '\\(:[0-9]\\+\\)\\{0,2}'  -- ':num:num' | ':num' | '' (空)
  )

  --- highlight url
  --- http:// | https://
  vim.fn.matchadd('URL',
    '\\<http[s]\\{0,1}://'  -- 'http://' | 'https://' 开头
    .. '\\f\\+'  -- filename 可以用字符. eg: www.abc.com
    .. '\\(:[0-9]\\+\\)\\{0,1}' -- port, eg:80
    .. '[/]\\{0,1}[?]\\{0,1}'  -- /? | ? | ''
    .. '\\f*\\(&\\f\\+\\)*'  -- '' | foo=bar | foo=fuz&bar=buz...
  )
end

--- Jump to file -----------------------------------------------------------------------------------
--- 利用 local list 跳转到 log 文件, vim.fn.setloclist(win_id/winnr, {item_list}, 'r'/'a')
--- vim.fn.setloclist(1000, { {filename='src/main.go', lnum=1, col=1, text='jump_to_log_file()'} }, 'r'/'a')
--- 'r' - replace items; 'a' - append items
--- `:help setqflist-what`
local function jump_to_file(absolute_path, lnum, col)
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

  local loclist_item = {filename = absolute_path, lnum = lnum, col=col, text='jump_to_file()'}

  if vim.fn.win_gotoid(log_display_win_id) == 1 then
    --- 如果 log_display_win_id 可以跳转则直接跳转.
    --- 给指定 window 设置 loclist, 'r' - replace, `:help setqflist-what`
    vim.fn.setloclist(log_display_win_id, {loclist_item}, 'r')

    --- jump to loclist first item
    vim.cmd('silent lfirst')

    --- VVI: clear loclist
    vim.fn.setloclist(log_display_win_id, {}, 'r')
  else
    --- 如果 log_display_win_id 不能跳转, 则在 terminal 正上方创建一个新的 window 用于显示 log filepath
    vim.cmd('leftabove split ' .. loclist_item.filename)
    log_display_win_id = vim.fn.win_getid()

    --- 给指定 window 设置 loclist, 'r' - replace, `:help setqflist-what`
    vim.fn.setloclist(log_display_win_id, {loclist_item}, 'r')

    --- jump to loclist first item
    vim.cmd('silent lfirst')

    --- VVI: clear loclist
    vim.fn.setloclist(log_display_win_id, {}, 'r')
  end
end

--- jump to dir if nvim-tree exist
local function open_dir_in_nvimtree(dir)
  local nt_status_ok, nt = pcall(require, "nvim-tree.api")
  if not nt_status_ok then
    return
  end

  --- open nvim-tree
  nt.tree.open()

  --- cursor jump to dir
  nt.tree.find_file(dir)
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

function Jump_to_file(content)
  local filepath, lnum, col = parse_filepath(content)

  if not filepath or filepath == '' then  -- empty line
    return
  end

  local absolute_path = vim.fn.fnamemodify(filepath, ':p')

  --- 如果 filepath 不可读取, 则直接 return. eg: filepath 错误
  if vim.fn.filereadable(absolute_path) == 0 then
    if vim.fn.isdirectory(absolute_path) == 0 then
      Notify('cannot open file: "' .. filepath .. '"', "DEBUG", {timeout = 1500})
      return
    else
      Notify('"' .. filepath .. '" is a directory', "DEBUG", {timeout = 1500})
      --open_dir_in_nvimtree(absolute_path)  -- TODO
      return
    end
  end

  if not lnum then  --- 如果 lnum 不存在, 跳到文件第一行.
    lnum = 1
  end

  if not col then
    col = 1
  end

  jump_to_file(absolute_path, lnum, col)
end

--- terminal normal 模式跳转文件 -------------------------------------------------------------------
--- 操作方法: 在 Terminal Normal 模式中, 在行的任意位置使用 <CR> 跳转到文件.

--- TermClose 意思是 job done
--- TermLeave 意思是 term 关闭
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = {"term://*"},
  callback = function(params)
    vim.keymap.set('n', '<S-CR>',
      "<cmd>lua Jump_to_file(vim.fn.expand('<cWORD>'))<CR>",
      {
        noremap = true,
        silent = true,
        buffer = params.buf,  -- local to Terminal buffer
        desc = "Jump to file",
      }
    )
  end,
})

--- for debug dap-repl buffer
vim.api.nvim_create_autocmd('FileType', {
  pattern = {"dap-repl"},
  callback = function(params)
    vim.keymap.set('n', '<S-CR>',
      "<cmd>lua Jump_to_file(vim.fn.expand('<cWORD>'))<CR>",
      {
        noremap = true,
        silent = true,
        buffer = params.buf,  -- local to Terminal buffer
        desc = "Jump to file",
      }
    )
  end
})

--- VISIAL 模式跳转文件 ----------------------------------------------------------------------------
--- 获取 visual selected word.
function Visual_selected()
  --- NOTE: getpos("'<") 和 getpos("'>") 必须在 normal 模式执行,
  --- 即: <C-c> 从 visual mode 退出后再执行以下函数.
  --- `:echo getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]-1]`
  local startpos = vim.fn.getpos("'<")
  local endpos = vim.fn.getpos("'>")

  --- 如果不在同一行则 return
  if startpos[2] ~= endpos[2] then
    return
  end

  return string.sub(vim.fn.getline("'<"), startpos[3], endpos[3])
end

--- VISUAL 选中的 filepath, 不管在什么 filetype 中都跳转
--- 操作方法: visual select 'filepath:lnum', 然后使用 <S-CR> 跳转到文件.
vim.keymap.set('v', '<S-CR>',
  "<C-c>:lua Jump_to_file(Visual_selected())<CR>",
  {noremap = true, silent = true, desc = "Jump to file"}
)



