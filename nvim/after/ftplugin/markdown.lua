-- 创建 markdown table
local function markdown_create_table(arglist)  -- args: 创建一个 row * col 的表.
  if vim.bo.readonly then
    Notify("this is a readonly file","ERROR")
    return
  end

  -- if arglist < 1, vim 会提示需要 Argument required
  if #arglist > 2 then
    Notify('args error. eg: "MarkdownCreateTable row:number col:number"', "ERROR")
    return
  end

  -- 类型转换
  local col = tonumber(arglist[1])  -- NOTE: col 放在前面, 必须要的, row 很容易复制添加.

  local row
  if not arglist[2] then
    row = 3  -- row omit 默认值
  else
    row = tonumber(arglist[2])  -- 如果 arglist[2] 不是 number, row = nil
  end

  if not col or not row then
    Notify("args need to be number","ERROR")
    return
  end

  if row < 1 or col < 1 then
    Notify("row & col needs to > 0","ERROR")
    return
  end

  local _colspace = "|       "
  local _rowsplit = "| ----- "

  local col_placeholder = ""   -- '|     |     |     |'
  local table_split = ""       -- '| --- | --- | --- |'
  for _ = 1, col, 1 do
    col_placeholder = col_placeholder .. _colspace
    table_split = table_split .. _rowsplit
  end
  col_placeholder = col_placeholder .. "|"
  table_split = table_split .. "|"

  local result = {col_placeholder, table_split}

  for _ = 1, row, 1 do
    table.insert(result, col_placeholder)
  end

  --- 输出整个 table
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_lines(0, line, line, true, result)
end

--- 设置 command
vim.api.nvim_buf_create_user_command(
  0,
  "MarkdownCreateTable",
  function(params)
    markdown_create_table(params.fargs)
  end,
  {bang=true, nargs="+"}
)

--- conceal ----------------------------------------------------------------------------------------
--vim.opt_local.conceallevel = 2  -- NOTE: 默认不开启 conceal
--vim.opt_local.concealcursor = "nc"  -- 'nc' Normal & Command Mode 不显示 Concealed text.

--- `:help syn-cchar`, `:help syn-conceal`
--- vim.cmd([[ syntax match Entity "\(^\s*\)\@<=-\(\s\S\+\)\@=" conceal cchar=● ]])
--- NOTE: 使用 matchadd('Conceal', pat, {conceal}) 的时候只能使用 'Conceal' highlight group; {conceal=''} 只能是一个字符.
--- list: `-` | `+` 的前面必须是 0~n 个 \s, 后面必须有一个空格, 空格后面必须有内容.
--vim.fn.matchadd('Conceal', "\\(^\\s*\\)\\@<=[-+]\\( \\S\\+\\)\\@=", 100, -1, {conceal = "•"})  -- list,

--- code block, ```go, ``` go, ...
--vim.fn.matchadd('Conceal', "^```\\s*\\(\\w*\\)\\@=", 100, -1, {conceal = "λ"})  -- lamda code block
--vim.fn.matchadd('SpecialChar', "\\(^```\\s*\\)\\@<=\\w\\+", 100)  -- code block language "```go", NOTE: 这里不是 conceal 设置.



