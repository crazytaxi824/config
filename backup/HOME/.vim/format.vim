"autocmd FileType javascript,typescript setlocal formatprg=prettier\ --single-quote\ --jsx-single-quote\ --end-of-line=lf\ --stdin-filepath\ %
"autocmd FileType go setlocal formatprg=goimports

""" auto format when save file
"autocmd BufWritePre * silent! normal! gggqG

autocmd BufWritePre *.js,*.ts,*.jsx,*.tsx silent! execute '%!prettier --single-quote --jsx-single-quote --end-of-line=lf --stdin-filepath ' .. expand('%:p')
autocmd BufWritePre *.go silent! execute '%!goimports'
