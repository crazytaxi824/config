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
local winvar_reusable = "my_reusable"

function Terminal_exec(term_id, cmd)
  -- 获取 term win_id
  for winnr = vim.fn.winnr('$'), 1, -1 do
    if vim.fn.getwinvar(winnr, winvar_reusable) == term_id then
      vim.cmd(winnr .. 'q!')  -- 关闭之前的 terminal window
    end
  end

  vim.cmd('bot split term://'..cmd..';\\#reusable\\#'..term_id .. ' | setlocal winfixheight nobuflisted bufhidden=wipe filetype=myterm')
  vim.fn.setwinvar(vim.fn.win_getid(), winvar_reusable, term_id)
end

function Terminal_normal()
  -- 获取 term win_id
  for winnr = vim.fn.winnr('$'), 1, -1 do
    if vim.fn.getwinvar(winnr, winvar_reusable) == "normal" then
      vim.cmd(winnr .. 'q!')  -- 关闭之前的 terminal window
    end
  end

  -- 开启新的 terminal normal
  vim.cmd('bot split term:///bin/zsh;\\#reusable\\#normal | setlocal winfixheight nobuflisted filetype=myterm')
  vim.fn.setwinvar(vim.fn.win_getid(), winvar_reusable, "normal")
end


--- Terminal autocmd -------------------------------------------------------------------------------
--- VVI: 绑定 <ESC> 进入 terminal normal 模式, 只对本 buffer 有效.
vim.cmd [[au TermOpen term://* tnoremap <buffer> <ESC> <C-\><C-n>]]

--- normal terminal 进入时打开 insert mode
vim.cmd [[au TermOpen  term://*#reusable#normal startinsert]]
--- normal terminal job done 时 quit! / bd! / bw!
vim.cmd [[au TermClose term://*#reusable#normal quit!]]

--- resize reusable terminal, 这里是为了避免 term 窗口 size 是屏幕的一半.
vim.cmd('au BufEnter term://*#reusable#* resize '..reusable_term_size)



