""" based on '~/.vim/plugged/vim-airline/autoload/airline/themes/dark.vim'

""" section
"   * airline_a_<Mode> (left most section)
"   * airline_b_<Mode> (section just to the right of airline_a)
"   * airline_c_<Mode> (section just to the right of airline_b)
"   * airline_x_<Mode> (first section of the right most sections)
"   * airline_y_<Mode> (section just to the right of airline_x)
"   * airline_z_<Mode> (right most section)

""" mode
"   * normal
"   * insert
"   * replace
"   * visual
"   * inactive
"   * terminal

scriptencoding utf-8

let g:airline#themes#foo#palette = {}

""" NORMAL
let s:airline_a_normal   = [ '#00005f' , '#dfff00' , 17  , 190 ]
let s:airline_b_normal   = [ '#ffffff' , '#444444' , 255 , 238 ]
let s:airline_c_normal   = [ '#9cffd3' , '#202020' , 85  , 234 ]
let g:airline#themes#foo#palette.normal = airline#themes#generate_color_map(s:airline_a_normal, s:airline_b_normal, s:airline_c_normal)

""" 如果文件修改了但是没有保存则 section_c 的颜色改变.
let g:airline#themes#foo#palette.normal_modified = {
      \ 'airline_c': [ '#ffffff' , '#5f005f' , 255     , 53      , ''     ] ,
      \ }

""" INSERT
let s:airline_a_insert = [ '#00005f' , '#00dfff' , 17  , 45  ]
let s:airline_b_insert = [ '#ffffff' , '#005fff' , 255 , 27  ]
let s:airline_c_insert = [ '#ffffff' , '#000080' , 15  , 17  ]
let g:airline#themes#foo#palette.insert = airline#themes#generate_color_map(s:airline_a_insert, s:airline_b_insert, s:airline_c_insert)
let g:airline#themes#foo#palette.insert_modified = {
      \ 'airline_c': [ '#ffffff' , '#5f005f' , 255     , 53      , ''     ] ,
      \ }
let g:airline#themes#foo#palette.insert_paste = {
      \ 'airline_a': [ s:airline_a_insert[0]   , '#d78700' , s:airline_a_insert[2] , 172     , ''     ] ,
      \ }

""" TERMINAL
let g:airline#themes#foo#palette.terminal = airline#themes#generate_color_map(s:airline_a_insert, s:airline_b_insert, s:airline_c_insert)

""" REPLACE
let g:airline#themes#foo#palette.replace = copy(g:airline#themes#foo#palette.insert)
let g:airline#themes#foo#palette.replace.airline_a = [ s:airline_b_insert[0]   , '#af0000' , s:airline_b_insert[2] , 124     , ''     ]
let g:airline#themes#foo#palette.replace_modified = g:airline#themes#foo#palette.insert_modified

""" VISUAL
let s:airline_a_visual = [ '#000000' , '#ffaf00' , 232 , 214 ]
let s:airline_b_visual = [ '#000000' , '#ff5f00' , 232 , 202 ]
let s:airline_c_visual = [ '#ffffff' , '#5f0000' , 15  , 52  ]
let g:airline#themes#foo#palette.visual = airline#themes#generate_color_map(s:airline_a_visual, s:airline_b_visual, s:airline_c_visual)
let g:airline#themes#foo#palette.visual_modified = {
      \ 'airline_c': [ '#ffffff' , '#5f005f' , 255     , 53      , ''     ] ,
      \ }

""" 没选中的 buffer 的 Statusline 颜色
let s:airline_a_inactive = [ '#4e4e4e' , '#1c1c1c' , 239 , 234 , '' ]
let s:airline_b_inactive = [ '#4e4e4e' , '#262626' , 239 , 235 , '' ]
let s:airline_c_inactive = [ '#4e4e4e' , '#303030' , 239 , 236 , '' ]
let g:airline#themes#foo#palette.inactive = airline#themes#generate_color_map(s:airline_a_inactive, s:airline_b_inactive, s:airline_c_inactive)
let g:airline#themes#foo#palette.inactive_modified = {
      \ 'airline_c': [ '#875faf' , '' , 97 , '' , '' ] ,
      \ }

""" Command mode
let s:airline_a_commandline = [ '#00005f' , '#00d700' , 17  , 40 ]
let s:airline_b_commandline = [ '#ffffff' , '#444444' , 255 , 238 ]
let s:airline_c_commandline = [ '#9cffd3' , '#202020' , 85  , 234 ]
let g:airline#themes#foo#palette.commandline = airline#themes#generate_color_map(s:airline_a_commandline, s:airline_b_commandline, s:airline_c_commandline)

let g:airline#themes#foo#palette.accents = {
      \ 'red': [ '#ff0000' , '' , 160 , ''  ]
      \ }

if get(g:, 'loaded_ctrlp', 0)
  let g:airline#themes#foo#palette.ctrlp = airline#extensions#ctrlp#generate_color_map(
        \ [ '#d7d7ff' , '#5f00af' , 189 , 55  , ''     ],
        \ [ '#ffffff' , '#875fd7' , 231 , 98  , ''     ],
        \ [ '#5f00af' , '#ffffff' , 55  , 231 , 'bold' ])
endif

" """ 如果要设置 airline 颜色必须使用 AirlineAfterTheme
" function! s:update_highlights()
"     """ tabline filepath (buffer) 颜色
"     hi airline_tabsel ctermfg=17 ctermbg=190
"     hi airline_tab ctermfg=239 ctermbg=236
"     hi airline_tabmod ctermfg=17 ctermbg=45
"     hi airline_tabmod_unsel ctermfg=255 ctermbg=53
" endfunction
" autocmd User AirlineAfterTheme call s:update_highlights()

