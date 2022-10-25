--- NOTE: 设置 markdown syn-cchar & conceal
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"markdown"},
  callback = function(params)
    vim.wo.conceallevel = 2
    vim.wo.concealcursor = "nc"  -- 'nc' Normal & Command Mode 不显示 Concealed text.

    --- `:help syn-cchar`, `:help syn-conceal`
    --- vim.cmd([[ syntax match Entity "\(^\s*\)\@<=-\(\s\S\+\)\@=" conceal cchar=● ]])
    --- NOTE: pattern: `-` 的前面必须是 0~n 个 \s, 后面必须有一个空格, 空格后面必须有内容.
    --- 使用 matchadd('Conceal', pat, {conceal}) 的时候只能使用 'Conceal' highlight group; {conceal=''} 只能是一个字符.
    vim.fn.matchadd('Conceal', "\\(^\\s*\\)\\@<=-\\( \\S\\+\\)\\@=", 100, -1, {conceal = "•"})  -- list, •◦●○

    --- code block, ```go, ``` go, ...
    vim.fn.matchadd('Conceal', "^```\\s*\\(\\w*\\)\\@=", 100, -1, {conceal = "λ"})  -- lamda code block
    vim.fn.matchadd('SpecialChar', "\\(^```\\s*\\)\\@<=\\w\\+", 100)  -- code block lang, NOTE: 这里不是 conceal 设置.
  end
})



