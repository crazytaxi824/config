vim9script

### 进入文件夹 netrw, `:help :Explore`
nnoremap <S-Tab> <cmd>execute("30Lexplore " .. expand('%:p:h')) <CR>
nnoremap <leader><CR> <cmd>execute("30Lexplore " .. expand('%:p:h')) <CR>
nnoremap <leader>; <cmd>execute("30Lexplore " .. getcwd())<CR>



