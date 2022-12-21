--- README: 利用了内置的 vimL function `matchadd()` 和 `matchstr()` 的统一性进行 filepath highlight 和分析.
--- 所以只要是能被 `matchadd()` 正确 highlight 的 filepath 就能被 `matchstr()` 一字不差的分析出来.

--- highlight <file:line:col> ----------------------------------------------------------------------
vim.api.nvim_set_hl(0, 'Filepath', {underline = true}) -- 自定义颜色, for Highlight_filepath()
vim.api.nvim_set_hl(0, 'URL', {ctermfg = Color.info_blue, underline = true}) -- 自定义颜色, for Highlight_filepath()

--- VVI: vim `:h pattern-overview` 中使用双引号和单引号是不一样的. 单引号 '\(\)\+' 在双引号中需要写成 "\\(\\)\\+"
--- regex: (ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)
---   '\f' - isfname, 表示可用于 filename 的字符/数字/符号...
---   '\<' - beginning of a word
---   '\+' - 1~n
---   '\?' - 0~1
---   '\{0,2}' - 0~2

--- 'file:///abc/def.txt', 'file://~/abc/def.txt', 'file://./abc/def.txt'
local file_schema_pattern = '\\<file://' -- file://
  .. '[~.]\\?/'  -- '~/' | './' | '/'
  .. '\\f\\+'  -- filename 可以用字符. '\+' 表示至少有一个字符.
  .. '\\(:[0-9]\\+\\)\\{0,2}'  -- ':num:num' | ':num' | '' (空)

--- '/a/b/c', '~/a/b/c', './a/b/c'
local filepath_pattern = '\\(^\\|\\s\\|\\[\\|<\\|{\\|(\\)\\@<='  -- '^' | whitespace | '(' | '[' | '{' | '<' 开头
  .. '[~.]\\?/'  -- '~/' | './' | '/'
  .. '\\f\\+'  -- filename 可以用字符. '\+' 表示至少有一个字符.
  .. '\\(:[0-9]\\+\\)\\{0,2}'  -- ':num:num' | ':num' | '' (空)

--- 'http://' | 'https://'
local url_schema_pattern = '\\<http[s]\\?://'  -- 'http://' | 'https://' 开头
  .. '\\f\\+'  -- filename 可以用字符. eg: 'www.abc.com'
  .. '\\(:[0-9]\\+\\)\\?' -- port, eg: ':80'
  .. '[/]\\?'
  .. '\\(?\\f\\+\\(&\\f\\+\\)*\\)\\?'  -- '/?foo=fuz&bar=buz'

--- NOTE: matchadd() 每次执行只能作用在 current window 上.
--- 而且状态持续, 当该 window 打开别的 buffer 时, highlight 一样会存在.
function Highlight_filepath()
  vim.fn.matchadd('Filepath', file_schema_pattern)
  vim.fn.matchadd('Filepath', filepath_pattern)
  vim.fn.matchadd('URL', url_schema_pattern)
end

--- Jump to file -----------------------------------------------------------------------------------
--- NOTE: 在 `:edit +call\ cursor('a','b') foo.go` 命令中 lnum & col 都是 string 的情况下,
--- cursor 会跳转到文件的第一行第一列;
--- 单独执行 :call cursor('a','b') 的时候, cursor 不会动;
--- 单独执行 :call cursor(3,'b')   的时候, cursor 跳转到第三行第一列;
--- 单独执行 :call cursor('a',3)   的时候, cursor 跳转到本行第三列;
--- 单独执行 :call cursor('3','3') 的时候, cursor 跳转到第三行第三列; NOTE: 这里 lnum & col 是 string, 可以跳转.
local function jump_to_file(absolute_path, lnum, col)
  --- 则选择合适的 window 显示文件.
  local log_display_win_id

  --- 在本 tab 中寻找第一个显示 listed-buffer 的 window, 用于显示 log filepath.
  local tab_wins = vim.fn.winnr('$')
  for i=1, tab_wins, 1 do
    local winid = vim.fn.win_getid(i)
    if vim.fn.buflisted(vim.api.nvim_win_get_buf(winid)) == 1 then
      log_display_win_id = winid
    end
  end

  --- VVI: escape filename for Vim Command.
  --- unscaped filename 可以被 lua vim.fn.fnamemodify() 读取, 但是不能被 Vim Command (:edit ...) 读取.
  absolute_path = vim.fn.fnameescape(absolute_path)

  --- NOTE: cmd 利用 cursor('lnum','col') 可以传入 string args 的特点.
  local cmd
  if vim.fn.win_gotoid(log_display_win_id) == 1 then
    --- 如果 win_id 可以跳转, 则直接在该 window 中打开文件.
    cmd = 'edit +lua\\ vim.fn.cursor("' .. lnum .. '","' .. col .. '") ' .. absolute_path
  else
    --- 如果 win_id 不能跳转, 则在 terminal 正上方创建一个新的 window 用于显示 log filepath
    cmd = 'leftabove split +lua\\ vim.fn.cursor("' .. lnum .. '","' .. col .. '") ' .. absolute_path
  end

  vim.cmd(cmd)
end

local function jump_to_dir(dir)
  --- NOTE: 新窗口中打开 dir, 因为 nvim-tree 设置 hijack netrw & directories = true,
  --- 如果直接使用 `:edit dir` 会导致打开 dir 的窗口被关闭 (hijack).
  --- 如果 hijack netrw & directories = false, 则这里可以使用 `:tabnew dir`
  vim.cmd('new ' .. dir)
end

--- VVI: 利用了内置的 vimL function `matchadd()` 和 `matchstr()` 的统一性进行 filepath highlight 和分析.
--- 所以只要是能被 `matchadd()` 正确 highlight 的 filepath 就能被 `matchstr()` 一字不差的分析出来.
local function matchstr_filepath(content)
  local m = vim.fn.matchstr(content, file_schema_pattern)
  if m ~= "" then
    local _, e = string.find(m, 'file://')
    return string.sub(m, e+1)
  end

  m = vim.fn.matchstr(content, filepath_pattern)
  if m ~= "" then
    return m
  end

  return content
end

--- split filepath:lnum:col
local function parse_filepath(content, ignore_matchstr)
  local filepath
  if ignore_matchstr then  -- 不需要 matchstr
    filepath = content
  else
    filepath = matchstr_filepath(content)
  end

  local fp = vim.split(vim.fn.trim(filepath), ":")

  --- file, lnum, col 都不能为 nil
  local file = fp[1] or ''
  local lnum = fp[2] or ''
  local col  = fp[3] or ''

  return file, lnum, col
end

function Jump_to_file(content, ignore_matchstr)
  local filepath, lnum, col = parse_filepath(content, ignore_matchstr)

  if not filepath or filepath == '' then  -- empty line
    return
  end

  local absolute_path = vim.fn.fnamemodify(filepath, ':p')

  if vim.fn.filereadable(absolute_path) == 1 then  -- 是 file
    jump_to_file(absolute_path, lnum, col)
    return
  elseif vim.fn.isdirectory(absolute_path) == 1 then  -- 是 dir
    jump_to_dir(absolute_path)
    return
  end

  Notify('cannot open file: "' .. filepath .. '"', "INFO", {timeout = 1500})
end

--- terminal normal 模式跳转文件 -------------------------------------------------------------------
--- 操作方法: 在 Terminal Normal 模式中, 在行的任意位置使用 <CR> 跳转到文件.

--- TermClose 意思是 job done
--- TermLeave 意思是 term 关闭
--- TermOpen 类似 FileType 只在第一次打开 terminal 的时候触发.
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = {"term://*"},
  callback = function(params)
    --- 显示 filepath, NOTE: 第一次打开 terminal 的时候不会触发 "BufEnter", 只能使用 "TermOpen"
    --- 但是 "TermOpen" 类似 "FileType" 只在第一次打开 terminal 的时候触发.
    Highlight_filepath()

    --- 设置 keymaps
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

--- 这里是保证 terminal hidden 之后, 再次打开时显示 filepath
vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = {"term://*"},
  callback = Highlight_filepath,
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
  "<C-c><cmd>lua Jump_to_file(Visual_selected(), true)<CR>",
  {noremap = true, silent = true, desc = "Jump to file"}
)

--- 使用 system 打开文件.
function System_open(filepath)
  local result = vim.fn.system('open "' .. filepath .. '"')
  if vim.v.shell_error ~= 0 then  --- 判断 system() 结果是否错误
    Notify("system open error: " .. result, "ERROR")
  end
end
vim.keymap.set('v', '<C-o>',
  '<C-c><cmd>lua System_open(Visual_selected())<CR>',
  {noremap = true, silent = true, desc = "Jump to file"}
)



