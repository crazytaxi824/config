scriptencoding utf-8

""" 参考 `~/.local/share/nvim/site/pack/packer/start/vim-airline/autoload/airline/themes/dark.vim`
""" 参考 "vim-airline/vim-airline-themes" dark_minimal.vim 设置.

let g:airline#themes#mydark#palette = {}

""" 首先定义 normal
let s:airline_a_normal  = [ '#00005f' , '#dfff00' , 17  , 190 ]
let s:airline_b_normal  = [ '#ffffff' , '#444444' , 255 , 238 ]
let s:airline_c_normal  = [ '#9cffd3' , '#202020' , 85  , 234 ]
let g:airline#themes#mydark#palette.normal = airline#themes#generate_color_map(s:airline_a_normal, s:airline_b_normal, s:airline_c_normal)

""" 如果文件修改了但是没有保存则 section_c 的颜色改变.
let g:airline#themes#mydark#palette.normal_modified = {
      \ 'airline_c': [ '#ffffff', '#5f005f', 255, 53, '' ],
      \ }

let g:airline#themes#mydark#palette.accents = {
      \ 'red': [ '#ff0000' , '' , 160 , ''  ]
      \ }

let pal = g:airline#themes#mydark#palette
for item in [ 'insert', 'replace', 'visual', 'ctrlp' ]
  exe "let pal.".item." = pal.normal"
  exe "let pal.".item."_modified = pal.normal_modified"
endfor

""" 没选中的 buffer 的 Statusline 颜色
let s:airline_a_inactive = [ '#4e4e4e' , '#1c1c1c' , 244 , 235 , '' ]
let s:airline_b_inactive = [ '#4e4e4e' , '#262626' , 246 , 237 , '' ]
let s:airline_c_inactive = [ '#4e4e4e' , '#303030' , 248 , 239 , '' ]
let g:airline#themes#mydark#palette.inactive = airline#themes#generate_color_map(s:airline_a_inactive, s:airline_b_inactive, s:airline_c_inactive)
let g:airline#themes#mydark#palette.inactive_modified = {
      \ 'airline_c': [ '#875faf', '', 255, 53, '' ],
      \ }

""" 如果要设置 airline 颜色必须使用 AirlineAfterTheme
function! s:update_highlights()
    """ tabline filepath (buffer) 颜色
    hi airline_tabsel ctermfg=17 ctermbg=190
    hi airline_tab ctermfg=239 ctermbg=236
    hi airline_tabmod ctermfg=17 ctermbg=45
    hi airline_tabmod_unsel ctermfg=255 ctermbg=53
endfunction
autocmd User AirlineAfterTheme call s:update_highlights()


