--- 跳转到 cursor 所在 filepath

local parse = require('user.utils.filepath.parse')

local M = {}

--- NOTE: 在 `:edit +call\ cursor('a','b') foo.go` 命令中 lnum & col 都是 string 的情况下,
--- cursor 会跳转到文件的第一行第一列;
--- 单独执行 :call cursor('a','b') 的时候, cursor 不会动;
--- 单独执行 :call cursor(3,'b')   的时候, cursor 跳转到第三行第一列;
--- 单独执行 :call cursor('a',3)   的时候, cursor 跳转到本行第三列;
--- 单独执行 :call cursor('3','3') 的时候, cursor 跳转到第三行第三列; NOTE: 这里 lnum & col 是 string, 可以跳转.
local function jump_to_file(absolute_path, lnum, col)
  lnum = lnum or '1'
  col = col or '1'

  --- 则选择合适的 window 显示文件.
  local display_win_id

  --- 在当前 tab 中寻找第一个显示 listed-buffer 的 window, 用于显示 filepath.
  local tab_wins = vim.api.nvim_tabpage_list_wins(0)
  for _, win_id in ipairs(tab_wins) do
    local bufnr = vim.api.nvim_win_get_buf(win_id)
    local buffer_fullpath = vim.api.nvim_buf_get_name(bufnr)

    --- 寻找是否有 window 已经显示了指定文件.
    if buffer_fullpath == absolute_path then
      display_win_id = win_id
      break
    end

    --- 记录当前 tab 中第一个显示 listed-buffer 的 window, 用于显示 filepath.
    if not display_win_id and vim.fn.buflisted(bufnr) == 1 then
      display_win_id = win_id
    end
  end

  --- VVI: escape filename for Vim Command.
  --- unscaped filename 可以被 lua vim.fn.fnamemodify() 读取, 但是不能被 Vim Command (:edit ...) 读取.
  absolute_path = vim.fn.fnameescape(absolute_path)

  --- NOTE: cmd 利用 cursor('lnum','col') 可以传入 string args 的特点.
  local cmd
  if vim.fn.win_gotoid(display_win_id) == 1 then
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

--- 获取 visual selected word.
local function visual_selected()
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

--- jump controller
local function jump(content)
  local r = parse.parse(content)
  if r.type == 'file' then
    jump_to_file(r.absolute_fp, r.lnum, r.col)
    return
  elseif r.type == 'dir' then
    jump_to_dir(r.absolute_fp)
    return
  end

  Notify('cannot open: "' .. content .. '"', "INFO", {timeout = 1500})
end

--- NOTE: 为保险起见, 不在 Normal 模式下使用 system_open 打开 <cWORD>
local function system_open(filepath)
  local result = vim.fn.system('open "' .. filepath .. '"')
  if vim.v.shell_error ~= 0 then  --- 判断 system() 结果是否错误
    Notify(vim.trim(result), "ERROR")
  end
end

M.n_jump_cWORD = function() jump(vim.fn.expand('<cWORD>')) end
M.v_jump_selected = function() jump(visual_selected()) end
M.v_system_open_selected = function() system_open(visual_selected()) end

return M
