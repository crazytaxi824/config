--- 使用 gomodifytags 给 struct 添加/移除 tags -----------------------------------------------------
-- 命令行工具使用: `gomodifytags --help`
-- silent execute "!gomodifytags -file src/main.go -offset 219 -add-tags json,xml -add-options json=omitempty,xml=omitempty -transform snakecase -skip-unexported -quiet -w" | checktime
-- silent execute "!gomodifytags -file src/main.go -offset 219 -clear-tags -quiet -w" | checktime  -- 删除所有 tag
-- silent execute "!gomodifytags -file src/main.go -offset 219 -clear-options -quiet -w" | checktime  -- 删除所有 tag 的所有 options
-- silent execute "!gomodifytags -file src/main.go -offset 219 -remove-tags json -quiet -w" | checktime  -- 删除指定 tag
-- silent execute "!gomodifytags -file src/main.go -offset 219 -remove-options json=omitempty -quiet -w" | checktime  -- 删除指定 tag 的指定 option.
--
-- gomodifytags 命令行工具.
-- checktime - refresh buffer. 主要用于文件在 vim 外部被修改后刷新. eg: `gomodifytags`, `call writefile()` 等
--      NOTE: 文件被外部修改之后会重新加载所有针对该 <buffer> 的插件, eg: rundo - read undo file.
--
-- 可选填项:
--    -file       filepath
--    -offset     n (num, byte offset) VVI: 主要利用这个功能实现, vim.fn.line2byte() 获取 offset
--    -tagname    json,xml,sql ...
--    -transform  snakecase(*) | camelcase | lispcase | pascalcase | titlecase | keep
--
-- NOTE: 本文件不准备实现 options 功能. 只实现 -add-tags -clear-tags -remove-tags 三个功能.
--
-- 操作方法: cursor 在 struct 的 {} 内, 使用以下 Command
--   :GoAddTags json,xml camelcase
--   :GoAddTags json,xml <omit>
--   :GoRemoveAllTags
--   :GoRemoveTags json,xml

--- GoAddTags --------------------------------------------------------------------------------------
local function goAddTags(arglist)
  if vim.bo.readonly then
    Notify("this is a readonly file","ERROR",{title={"goAddTags()","tool_gomodifytags.lua"}})
    return
  end

  if #arglist > 2 then
    Notify(
      {"too many args",'eg: ":GoAddTags json,xml | :GoAddTags json,xml camelcase"'},
      "ERROR",
      {title={"goAddTags()","tool_gomodifytags.lua"}}
    )
    return
  end

  local fp = vim.fn.expand("%:.")  -- current filepath

  --- 获取当前 cursor offset, 即在整个文档中的 byte 位置.
  local offset = vim.fn.line2byte('.')  -- 当前行的 col(1) 的 byte 位置,
                                        -- NOTE: 不管 cursor 在本行的任意 col, 返回值都相同.

  -- local tag_opt = "json=omitempty,xml=omitempty"

  local transform = ""

  if arglist[2] == nil then
    transform = "snakecase"  -- default case
  elseif arglist[2] == 's' or arglist[2] == 'snake' or arglist[2] == 'snakecase' then  -- foo_bar
    transform = "snakecase"
  elseif arglist[2] == 'c' or arglist[2] == 'camel' or arglist[2] == 'camelcase' then   -- fooBar
    transform = "camelcase"
  elseif arglist[2] == 'p' or arglist[2] == 'pascal' or arglist[2] == 'pascalcase' then  -- FooBar
    transform = "pascalcase"
  elseif arglist[2] == 'l' or arglist[2] == 'lisp' or arglist[2] == 'lispcase' then    -- foo-bar
    transform = "lispcase"
  elseif arglist[2] == 't' or arglist[2] == 'title' or arglist[2] == 'titlecase' then   -- Foo Bar
    transform = "titlecase"
  elseif arglist[2] == 'k' or arglist[2] == 'keep' then  -- 和 field name 一样
    transform = "keep"
  else
    Notify(
      {
        "transform error: snakecase(*) | camelcase | lispcase | pascalcase | titlecase | keep",
        'eg: ":GoAddTags json,xml snakecase"'
      },
      "ERROR",
      {title={"goAddTags()","tool_gomodifytags.lua"}}
    )
    return
  end

  local sh_cmd = "gomodifytags -file " .. fp ..
    " -offset " .. offset ..
    " -add-tags " .. arglist[1] ..
    -- " -add-options " .. tag_opt ..  -- NOTE: 不准备实现 options
    " -transform " .. transform ..
    " -skip-unexported -sort -quiet -w -override"

  print(sh_cmd)
  local result = vim.fn.system(sh_cmd)

  --- 判断结果是否错误
  if vim.v.shell_error ~= 0 then
    Notify(result, "ERROR", {title={"goAddTags()","tool_gomodifytags.lua"}})
    return
  end

  vim.cmd('checktime')  -- refresh & reload buffer
end

--- NOTE: *.go 被重新加载时, 本文件会被重新读取. 会造成重复设置 command, 所以必须使用 `command!`
--  eg: `:GoAddTags json,xml c`, `:GoAddTags json,xml camel`, `:GoAddTags json`
-- command! -buffer -nargs=+ GoAddTags :lua _GoAddTags(<f-args>)
vim.api.nvim_buf_create_user_command(
  0,
  "GoAddTags",
  function(input)
    goAddTags(input.fargs)
  end,
  {nargs = "+", bang = true}
)

--- GoRemoveTags -----------------------------------------------------------------------------------
local function goRemoveTags(arglist)
  if vim.bo.readonly then
    Notify("this is a readonly file","ERROR",{title={"goRemoveTags()", "tool_gomodifytags.too"}})
    return
  end

  if #arglist > 1 then
    Notify(
      {"too many args",'eg: ":GoRemoveTags | :GoRemoveTags json,xml"'},
      "ERROR",
      {title={"goRemoveTags()", "tool_gomodifytags.too"}}
    )
    return
  end

  local fp = vim.fn.expand("%:.")  -- current filepath
  local offset = vim.fn.line2byte('.')
  local sh_cmd = ""


  if #arglist == 0 then
    sh_cmd = "gomodifytags -file " .. fp ..
      " -offset " .. offset ..
      " -clear-tags -quiet -w"
  else
    sh_cmd = "gomodifytags -file " .. fp ..
      " -offset " .. offset ..
      " -remove-tags " .. arglist[1] ..
      " -quiet -w"
  end

  print(sh_cmd)
  local result = vim.fn.system(sh_cmd)

  --- 判断结果是否错误
  if vim.v.shell_error ~= 0 then
    Notify(result,"ERROR",{title={"goRemoveTags()", "tool_gomodifytags.too"}})
    return
  end

  vim.cmd('checktime')  -- refresh & reload buffer
end

vim.api.nvim_buf_create_user_command(
  0,
  "GoRemoveTags",
  function(input)
    goRemoveTags(input.fargs)
  end,
  {bang = true, nargs = "*"}
)


