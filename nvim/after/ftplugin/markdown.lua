-- 创建 markdown table
local function markdown_create_table(arglist)  -- args: 创建一个 row * col 的表.
  if vim.bo.readonly then
    Notify("this is a readonly file","ERROR",{title={"markdown_create_table()", "markdown.lua"}})
    return
  end

  if #arglist ~= 2 then
    Notify(
      'args error. eg: "MarkdownCreateTable row:number col:number"',
      "ERROR",
      {title={"markdown_create_table()", "markdown.lua"}}
    )
    return
  end

  -- 类型转换
  local row = tonumber(arglist[1])
  local col = tonumber(arglist[2])
  if row == nil or col == nil then
    Notify("args need to be number","ERROR",{title={"markdown_create_table()", "markdown.lua"}})
    return
  end

  if row < 1 or col < 1 then
    Notify("row & col needs to > 0","ERROR",{title={"markdown_create_table()", "markdown.lua"}})
    return
  end

  local _colspace = "|       "
  local _rowsplit = "| ----- "

  local col_placeholder = ""   -- '|     |     |     |\<CR>'
  local table_split = ""       -- '| --- | --- | --- |\<CR>'
  for _ = 1, col, 1 do
    col_placeholder = col_placeholder .. _colspace
    table_split = table_split .. _rowsplit
  end
  col_placeholder = col_placeholder .. "|\\<CR>"
  table_split = table_split .. "|\\<CR>"

  local result = col_placeholder .. table_split

  for _ = 1, row, 1 do
    result = result .. col_placeholder
  end

  -- 换一行输出整个 table
  local cmd = "normal! A\\<CR>" .. result
  vim.cmd(':execute "' .. cmd .. '"')
end

--- 设置 command
vim.api.nvim_buf_create_user_command(
  0,
  "MarkdownCreateTable",
  function(input)
    markdown_create_table(input.fargs)
  end,
  {nargs="+"}
)



