-- NOTE: reusable terminal -------------------------------------------------------------------------
-- bot 12split term:///bin/zsh;\#reusable#normal
-- bot 12vsplit term://ls -l;\#reusable#exec
--
-- winnr('$')  -- last window number
-- bufnr('$')  -- last buffer number
-- bufnr('%')  -- return bufnr
-- bufname(bufnr)  -- return buffer name
--
-- setlocal nobuflisted bufhidden=wipe
-- bot sbuffer {bufnr}  -- NOTE: load unlisted buffer, 但是不能有 bufhidden=wipe
--
-- getwinvar() & setwinvar()
-- win_getid() & win_gotoid()
--
-- :startinsert 进入 insert mode
-- :stopinsert  进入 insert mode, terminal 模式下无法使用.
--
-- :set winfixheight / vim.wo.winfixheight = true 固定 window 高度
-- :set winfixwidth / vim.wo.winfixwidth = true   固定 window 宽度

local reusable_term_size = 12

function Terminal_exec(term_id, cmd)
  local win_index = -1
  -- 获取 term win_id
  for winnr = vim.fn.winnr('$'), 1, -1 do
    if vim.fn.getwinvar(winnr, 'reusable') == term_id then
      win_index = winnr
    end
  end

  if win_index > 0 then
    vim.cmd(win_index..'q!')  -- 关闭之前的 terminal window
  end

  vim.cmd('bot split term://'..cmd..';\\#reusable\\#'..term_id .. ' | setlocal winfixheight nobuflisted bufhidden=wipe')
  vim.fn.setwinvar(vim.fn.win_getid(), "reusable", term_id)
end

function Terminal_normal()
  local term_bufnr = -1
  -- 获取 term win_id
  for bufnr = vim.fn.bufnr('$'), 1, -1 do
    if string.match(vim.fn.bufname(bufnr), "term://.*;#reusable#normal") then
      term_bufnr = bufnr
    end
  end

  if term_bufnr > 0 then
    if vim.fn.getbufinfo(term_bufnr)[1].hidden == 0 then
      Notify("terminal normal is already opened","WARN",{title={"Terminal_normal()","terminal.lua"}})
    else
      -- load 隐藏的 terminal normal
      vim.cmd('bot sbuffer '..term_bufnr ..' | setlocal winfixheight nobuflisted')
    end
    return
  end

  -- 开启新的 terminal normal
  vim.cmd('bot split term:///bin/zsh;\\#reusable\\#normal | setlocal winfixheight nobuflisted')
  vim.fn.setwinvar(vim.fn.win_getid(), "reusable", "normal")
end


--- Terminal autocmd -------------------------------------------------------------------------------
--- normal terminal 进入时打开 insert mode
vim.cmd [[au TermOpen  term://*#reusable#normal startinsert]]
--- normal terminal job done 时 quit! / bd! / bw!
vim.cmd [[au TermClose term://*#reusable#normal quit!]]

--- resize reusable terminal
vim.cmd('au BufEnter term://*#reusable#* resize '..reusable_term_size)  -- 必须要, 否则 sbuffer 的时候高度会变成一半.

--- 绑定 <ESC> 进入 terminal normal 模式, 只对本 buffer 有效.
vim.cmd [[au TermOpen term://* tnoremap <buffer> <ESC> <C-\><C-n>]]



