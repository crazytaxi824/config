--- 使用 gomodifytags 给 struct 添加/移除 tags -----------------------------------------------------
--- 命令行工具使用: `gomodifytags --help`
--- silent execute "!gomodifytags -file src/main.go -offset 219 -add-tags json,xml -add-options json=omitempty,xml=omitempty -transform snakecase -skip-unexported -quiet -w" | checktime
--- silent execute "!gomodifytags -file src/main.go -offset 219 -clear-tags -quiet -w" | checktime  -- 删除所有 tag
--- silent execute "!gomodifytags -file src/main.go -offset 219 -clear-options -quiet -w" | checktime  -- 删除所有 tag 的所有 options
--- silent execute "!gomodifytags -file src/main.go -offset 219 -remove-tags json -quiet -w" | checktime  -- 删除指定 tag
--- silent execute "!gomodifytags -file src/main.go -offset 219 -remove-options json=omitempty -quiet -w" | checktime  -- 删除指定 tag 的指定 option.
--- NOTE: 本文件不准备实现 -add-options -remove-options -clear-options 功能.
---
--- 操作方法: cursor 在 struct 的 {} 内, 使用以下 Command
---   :GoTagAdd json,xml            -- 默认: snakecase
---   :GoTagAdd json,xml camelcase  -- camelcase
---   :GoTagAdd json=foo,xml=bar    -- add-options
---   :GoTagAdd json=foo,json=bar   -- NOTE: add multi-options to a Single tag.
--
---   :GoTagRemove           -- remove all tags and their options
---   :GoTagRemove json,xml  -- remove specified tags and it's options
--
---   :GoTagOptionsClear   -- Clear all tag options
---   :GoTagOptionsRemove json=foo,xml=bar  -- remove specified tags and it's options
---
--- gomodifytags 命令行工具.
--- checktime - refresh buffer. 主要用于文件在 vim 外部被修改后刷新. eg: `gomodifytags`, `call writefile()` 等
---      NOTE: 文件被外部修改之后会重新加载所有针对该 <buffer> 的插件, eg: rundo - read undo file.
---
--- 可选填项:
---    -file       filepath
---    -offset     n (num, byte offset) VVI: 主要利用这个功能实现, vim.fn.line2byte() 获取 offset
---    -tagname    json,xml,sql ...
---    -transform  snakecase(*) | camelcase | lispcase | pascalcase | titlecase | keep

--- GoAddTags --------------------------------------------------------------------------------------
--- arglist[1] is tag options. could be 'json','json=foo', 'json,xml=bar', 'json=foo,xml=bar', , 'json=foo,json=fuz,xml=bar'
--- arglist[2] = <可为空>|snakecase|camelcase|...
local go_add_tags_cmd = "GoTagAdd"

local function go_add_tags(arglist)
  if vim.bo.readonly then
    Notify("cannot add tags to readonly file","ERROR")
    return
  end

  if #arglist > 2 then
    Notify(
      {
        "too many args.",
        "Command examples:",
        '  :' .. go_add_tags_cmd .. ' json,xml',
        '  :' .. go_add_tags_cmd .. ' json,xml camelcase',
        '  :' .. go_add_tags_cmd .. ' json=omitempty,xml=omitempty',
        '  :' .. go_add_tags_cmd .. ' json=omitempty,xml=omitempty camelcase',
        "transform:",
        "  snakecase(*) | camelcase | lispcase | pascalcase | titlecase | keep",
      },
      "ERROR"
    )
    return
  end

  local fp = vim.fn.expand("%:.")  -- current filepath
  if fp == "" then
    Notify("filepath/bufname is empty", "ERROR")
    return
  end

  --- 获取当前 cursor offset, 即在整个文档中的 byte 位置.
  local offset = vim.fn.line2byte('.')  -- 当前行的 col(1) 的 byte 位置,
                                        -- NOTE: 不管 cursor 在本行的任意 col, 返回值都相同.

  --- parse tag name and tag options from arglist[1].
  local tag_list = {}
  local tag_opt_list = {}
  for _, tag_opt in ipairs(vim.split(arglist[1], ',')) do
    local to = vim.split(tag_opt, '=')
    if #to > 0 and to[1] ~= '' then  -- 'json'|'json=foo'
      table.insert(tag_list, to[1])
    end
    if #to == 2 then  -- 'json=foo'
      table.insert(tag_opt_list, tag_opt)
    end
  end

  local transform = ""
  if not arglist[2] then
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
        "transform error.",
        "Command examples:",
        '  :' .. go_add_tags_cmd .. ' json,xml',
        '  :' .. go_add_tags_cmd .. ' json,xml camelcase',
        '  :' .. go_add_tags_cmd .. ' json=omitempty,xml=omitempty',
        '  :' .. go_add_tags_cmd .. ' json=omitempty,xml=omitempty camelcase',
        "transform:",
        "  snakecase(*) | camelcase | lispcase | pascalcase | titlecase | keep",
      },
      "ERROR"
    )
    return
  end

  local sh_cmd = "gomodifytags -file " .. fp ..
    " -offset " .. offset ..
    " -add-tags " .. vim.fn.join(tag_list,',') ..
    " -transform " .. transform ..
    " -skip-unexported -sort -quiet -w -override"

  --- -add-options
  if #tag_opt_list > 0 then
    sh_cmd = sh_cmd ..
      " -add-options " .. vim.fn.join(tag_opt_list,',')
  end

  print(sh_cmd)
  local result = vim.fn.system(sh_cmd)
  if vim.v.shell_error ~= 0 then  --- 判断 system() 结果是否错误
    Notify(result, "ERROR")
    return
  end

  vim.cmd('checktime')  -- VVI: refresh & reload buffer
end

--- NOTE: *.go 被重新加载时, 本文件会被重新读取. 会造成重复设置 command, 所以必须使用 `command!`
--  eg: `:GoAddTags json,xml c`, `:GoAddTags json,xml camel`, `:GoAddTags json`
-- command! -buffer -nargs=+ GoAddTags :lua _GoAddTags(<f-args>)
vim.api.nvim_buf_create_user_command(
  0,
  go_add_tags_cmd,
  function(params)
    go_add_tags(params.fargs)
  end,
  {nargs = "+", bang = true}
)

--- GoRemoveTags -----------------------------------------------------------------------------------
local go_remove_tags_cmd = "GoTagRemove"

local function go_remove_tags(arglist)
  if vim.bo.readonly then
    Notify("cannot remove tags from readonly file","ERROR")
    return
  end

  if #arglist > 1 then
    Notify(
      {
        "too many args, eg:",
        '  :' .. go_remove_tags_cmd,
        '  :' .. go_remove_tags_cmd .. 'json,xml',
      },
      "ERROR"
    )
    return
  end

  local fp = vim.fn.expand("%:.")  -- current filepath
  if fp == "" then
    Notify("filepath/bufname is empty", "ERROR")
    return
  end

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
    Notify(result, "ERROR")
    return
  end

  vim.cmd('checktime')  -- VVI: refresh & reload buffer
end

vim.api.nvim_buf_create_user_command(
  0,
  go_remove_tags_cmd,
  function(params)
    go_remove_tags(params.fargs)
  end,
  {bang = true, nargs = "*"}
)



