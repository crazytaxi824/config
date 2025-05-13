""" this is not a vim9script

""" normal setting ---------------------------------------------------------------------------------
tnoremap <ESC> <C-\><C-n>
nnoremap <tab> <C-w><C-w>

nnoremap D "_dd
xnoremap D "_x

vnoremap <leader>y "*y

""" 自动括号
vnoremap <leader>" <C-c>`>a"<C-c>`<i"<C-c>v`><right><right>
vnoremap <leader>' <C-c>`>a'<C-c>`<i'<C-c>v`><right><right>
vnoremap <leader>` <C-c>`>a`<C-c>`<i`<C-c>v`><right><right>
vnoremap <leader>* <C-c>`>a*<C-c>`<i*<C-c>v`><right><right>
vnoremap <leader>_ <C-c>`>a_<C-c>`<i_<C-c>v`><right><right>
vnoremap <leader>$ <C-c>`>a$<C-c>`<i$<C-c>v`><right><right>
vnoremap <leader>{ <C-c>`>a}<C-c>`<i{<C-c>v`><right><right>
vnoremap <leader>} <C-c>`>a}<C-c>`<i{<C-c>v`><right><right>
vnoremap <leader>[ <C-c>`>a]<C-c>`<i[<C-c>v`><right><right>
vnoremap <leader>] <C-c>`>a]<C-c>`<i[<C-c>v`><right><right>
vnoremap <leader>( <C-c>`>a)<C-c>`<i(<C-c>v`><right><right>
vnoremap <leader>) <C-c>`>a)<C-c>`<i(<C-c>v`><right><right>
vnoremap <leader>> <C-c>`>a><C-c>`<i<<C-c>v`><right><right>
vnoremap <leader><lt> <C-c>`>a><C-c>`<lt>i<lt><C-c>v`><right><right>

nnoremap <leader>" viw<C-c>`>a"<C-c>`<i"<C-c>
nnoremap <leader>' viw<C-c>`>a'<C-c>`<i'<C-c>
nnoremap <leader>` viw<C-c>`>a`<C-c>`<i`<C-c>
nnoremap <leader>* viw<C-c>`>a*<C-c>`<i*<C-c>
nnoremap <leader>_ viw<C-c>`>a_<C-c>`<i_<C-c>
nnoremap <leader>$ viw<C-c>`>a$<C-c>`<i$<C-c>
nnoremap <leader>{ viw<C-c>`>a}<C-c>`<i{<C-c>
nnoremap <leader>} viw<C-c>`>a}<C-c>`<i{<C-c>
nnoremap <leader>[ viw<C-c>`>a]<C-c>`<i[<C-c>
nnoremap <leader>] viw<C-c>`>a]<C-c>`<i[<C-c>
nnoremap <leader>( viw<C-c>`>a)<C-c>`<i(<C-c>
nnoremap <leader>) viw<C-c>`>a)<C-c>`<i(<C-c>
nnoremap <leader>> viw<C-c>`>a><C-c>`<i<<C-c>
nnoremap <leader><lt> viw<C-c>`>a><C-c>`<lt>i<lt><C-c>

""" <Nop>
nnoremap s <Nop>

""" <Ctrl-Z> 是危险操作. 意思是 :stop. Suspend vim, 退出到 terminal 界面, 但保留 job.
""" 需要使用 `jobs -l` 列出 Suspended 列表, 使用 `fg %1` 恢复 job, 或者 `kill %1` (不推荐, 会留下 .swp 文件)
nnoremap <C-z> <Nop>
vnoremap <C-z> <Nop>

nnoremap <F1> <Nop>
inoremap <F1> <Nop>

"""" -----------------------------------------------------------------------------------------------
source ~/.vim/keymaps/buffer.vim
source ~/.vim/keymaps/cursor_move.vim



