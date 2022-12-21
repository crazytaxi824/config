local pat = require('user.global.filepath.pattern')

local M = {}

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
  local m = vim.fn.matchstr(content, pat.file_schema_pattern)
  if m ~= "" then
    local _, e = string.find(m, 'file://')
    return string.sub(m, e+1)
  end

  m = vim.fn.matchstr(content, pat.filepath_pattern)
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

M.jump_to_file = function(content, ignore_matchstr)
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

return M
