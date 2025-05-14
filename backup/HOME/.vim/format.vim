vim9script

autocmd FileType
	\ javascript,typescript,typescriptreact,javascriptreact,json,jsonc,css,scss,less,html,vue,markdown,yaml,graphql,svelte
	\ setlocal formatprg=prettier\ --single-quote\ --jsx-single-quote\ --end-of-line=lf\ --stdin-filepath\ %

autocmd FileType go setlocal formatprg=goimports

:command! Format normal! gggqG

# auto format when save file
#autocmd BufWritePre * normal! gggqG



