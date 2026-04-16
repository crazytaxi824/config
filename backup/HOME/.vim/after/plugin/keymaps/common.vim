vim9script

# NOTE: "key-notation" 中 <D-*> 只在 MacVIM (gui) 中可以使用.

# normal setting -----------------------------------------------------------------------------------
tnoremap <ESC> <C-\><C-n>
nnoremap <expr> <ESC> v:hlsearch ? ":nohlsearch\<CR>" : "\<ESC>"

nnoremap <Tab> <C-w><C-w>

nnoremap D "_dd
xnoremap D "_x

xnoremap <leader>y "*y

# <Nop>
nnoremap s <Nop>

# <Ctrl-Z> 是危险操作. 意思是 :stop. Suspend vim, 退出到 terminal 界面, 但保留 job.
# 需要使用 `jobs -l` 列出 Suspended 列表, 使用 `fg %1` 恢复 job, 或者 `kill %1` (不推荐, 会留下 .swp 文件)
nnoremap <C-z> <Nop>
vnoremap <C-z> <Nop>

nnoremap <F1> <Nop>
inoremap <F1> <Nop>



