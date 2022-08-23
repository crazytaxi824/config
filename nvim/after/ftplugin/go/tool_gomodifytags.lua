--- 使用 gomodifytags 给 struct 添加/移除 tags -----------------------------------------------------
--- 操作方法: cursor 在 struct 的 {} 内, 使用以下 Command
---   :GoTagAdd json,xml            -- 默认: snakecase. use '-add-tags'
---   :GoTagAdd json,xml camelcase  -- camelcase. use '-add-tags' & '-transform'
---   :GoTagAdd json=foo,xml=bar    -- use '-add-tags' & '-add-options'
---   :GoTagAdd json=foo,json=bar   -- NOTE: add multi-options to a Single tag. use '-add-tags' & '-add-options'
---
---   :GoTagRemove           -- remove all tags and their options. use '-clear-tags'
---   :GoTagRemove json,xml  -- remove specified tags and it's options. use '-remove-tags''
---
---   :GoTagOptionsRemove   -- Clear all tag options. use '-clear-options'
---   :GoTagOptionsRemove json=foo,xml=bar  -- remove specified tags and it's options. use '-remove-options'
---
---   :GoTagAddAllStruct     -- add tags to all struct in this file.
---   :GoTagRemoveAllStruct  -- remove tags to all struct in this file.
---   :GoTagOptionsRemoveAllStruct  -- remove tag's options to all struct in this file.
---
--- 命令行工具使用: `gomodifytags --help`
--- silent execute "!gomodifytags -file src/main.go -offset 219 -add-tags json,xml -add-options json=omitempty,xml=omitempty -transform snakecase -skip-unexported -quiet -w" | checktime
--- silent execute "!gomodifytags -file src/main.go -offset 219 -clear-tags -quiet -w" | checktime  -- 删除所有 tag
--- silent execute "!gomodifytags -file src/main.go -offset 219 -clear-options -quiet -w" | checktime  -- 删除所有 tag 的所有 options
--- silent execute "!gomodifytags -file src/main.go -offset 219 -remove-tags json -quiet -w" | checktime  -- 删除指定 tag
--- silent execute "!gomodifytags -file src/main.go -offset 219 -remove-options json=omitempty -quiet -w" | checktime  -- 删除指定 tag 的指定 option.
---
--- 可选填项:
---   -file       filepath
---   -add-tags / -add-options
---   -remove-tags / -remove-options
---   -clear-tags / -clear-options
---   -offset     n (num, byte offset) VVI: 主要利用这个功能实现, vim.fn.line2byte() 获取 offset
---   -all        本文件中的所有 struct. NOTE: 使用该参数不需要设置 -offset
---   -transform  snakecase(*) | camelcase | lispcase | pascalcase | titlecase | keep
---   -sort       按照 tags 首字母排序
---   -override   覆盖更改
---   -quiet      不打印运行结果
---   -w          保存文件
---
--- NOTE: checktime - refresh buffer. 主要用于文件在 vim 外部被修改后刷新. eg: `gomodifytags`, `call writefile()` 等
---       文件被外部修改之后会重新加载所有针对该 <buffer> 的插件, eg: rundo - read undo file.

--- ADD Tags and Options ---------------------------------------------------------------------------
--- arglist[1] is tag options. could be 'json','json=foo', 'json,xml=bar', 'json=foo,xml=bar', , 'json=foo,json=fuz,xml=bar'
--- arglist[2] = <可为空>|snakecase|camelcase|...
local function go_add_tags_and_opts(arglist, go_add_tags_cmd, offset)
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
        '  :' .. go_add_tags_cmd .. ' json,xml=foo',
        '  :' .. go_add_tags_cmd .. ' json,xml=foo camelcase',
        '  :' .. go_add_tags_cmd .. ' json=omitempty,xml=foo',
        '  :' .. go_add_tags_cmd .. ' json=omitempty,xml=foo camelcase',
        "transform:",
        "  snakecase(*) | camelcase | lispcase | pascalcase | titlecase | keep",
      },
      "ERROR"
    )
    return
  end

  local sh_cmd = "gomodifytags -file " .. fp ..
    " -add-tags " .. vim.fn.join(tag_list,',') ..
    " -transform " .. transform ..
    " -skip-unexported -quiet -w -override"

  --- -offset / -all
  if offset then
    sh_cmd = sh_cmd .. " -offset " .. offset
  else
    sh_cmd = sh_cmd .. " -all"
  end

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
local go_add_tags_cmd = "GoTagAdd"
vim.api.nvim_buf_create_user_command(
  0,
  go_add_tags_cmd,
  function(params)
    --- 获取当前 cursor 的 offset, 即在整个文档中的 byte 位置.
    --- VVI: 这里的 cursor 位置不是准确的 cursor byte 位置. 因为:
    --- line2byte('.') 返回当前行第一列的 byte 位置. 不管 cursor 在本行的任意 column, 返回值都相同.
    local offset = vim.fn.line2byte('.')
    --- 'gomodifytags -add-tags [tags] -offset [n]'
    --- 'gomodifytags -add-tags [tags] -add-options [tag=option] -offset [n]'
    go_add_tags_and_opts(params.fargs, go_add_tags_cmd, offset)
  end,
  {nargs = "+", bang = true}
)

local go_add_tags_all_struct_cmd = "GoTagAddAllStruct"
vim.api.nvim_buf_create_user_command(
  0,
  go_add_tags_all_struct_cmd,
  function(params)
    --- 通过判断 offset 是否为 nil, 来确定是否需要使用 '-all'.
    --- 'gomodifytags -add-tags [tags] -all'
    --- 'gomodifytags -add-tags [tags] -add-options [tag=option] -all'
    go_add_tags_and_opts(params.fargs, go_add_tags_all_struct_cmd)
  end,
  {nargs = "+", bang = true}
)

--- Remove Tags and Options ------------------------------------------------------------------------
--- if no args,  remove all tags, use '-clear-tags'
--- if has args, remove specified tags, use '-remove-tags'
local function go_remove_tags(arglist, go_remove_tags_cmd, offset)
  if vim.bo.readonly then
    Notify("cannot remove tags from readonly file","ERROR")
    return
  end

  if #arglist > 1 then
    Notify(
      {
        "too many args.",
        "Command examples:",
        '  :' .. go_remove_tags_cmd,
        '  :' .. go_remove_tags_cmd .. ' json,xml',
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

  local sh_cmd = "gomodifytags -file " .. fp

  --- -offset / -all
  if offset then
    sh_cmd = sh_cmd .. " -offset " .. offset
  else
    sh_cmd = sh_cmd .. " -all"
  end

  --- -clear-tags / -remove-tags
  if #arglist == 0 then
    sh_cmd = sh_cmd ..
      " -clear-tags -quiet -w"
  else
    sh_cmd = sh_cmd ..
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

local go_remove_tags_cmd = "GoTagRemove"
vim.api.nvim_buf_create_user_command(
  0,
  go_remove_tags_cmd,
  function(params)
    --- 获取当前 cursor 的 offset, 即在整个文档中的 byte 位置.
    --- VVI: 这里的 cursor 位置不是准确的 cursor byte 位置. 因为:
    --- line2byte('.') 返回当前行第一列的 byte 位置. 不管 cursor 在本行的任意 column, 返回值都相同.
    local offset = vim.fn.line2byte('.')
    --- 'gomodifytags -clear-tags -offset n'
    --- 'gomodifytags -remove-tags [tags] -offset n'
    go_remove_tags(params.fargs, go_remove_tags_cmd, offset)
  end,
  {bang = true, nargs = "*"}
)

local go_remove_tags_all_struct_cmd = "GoTagRemoveAllStruct"
vim.api.nvim_buf_create_user_command(
  0,
  go_remove_tags_all_struct_cmd,
  function(params)
    --- 通过判断 offset 是否为 nil, 来确定是否需要使用 '-all'.
    --- 'gomodifytags -clear-tags -all'
    --- 'gomodifytags -remove-tags [tags] -all'
    go_remove_tags(params.fargs, go_remove_tags_all_struct_cmd)
  end,
  {bang = true, nargs = "*"}
)

--- Remove Tag's Options ---------------------------------------------------------------------------
--- if no args,  remove all tags' options, use '-clear-options'
--- if has args, remove specified tag's options, use '-remove-options'
local function go_remove_tags_opts(arglist, go_remove_tag_opts_cmd, offset)
  if vim.bo.readonly then
    Notify("cannot remove tags's options from readonly file","ERROR")
    return
  end

  if #arglist > 1 then
    Notify(
      {
        "too many args.",
        "Command examples:",
        '  :' .. go_remove_tag_opts_cmd,
        '  :' .. go_remove_tag_opts_cmd .. ' json=foo,xml=bar',
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

  local sh_cmd = "gomodifytags -file " .. fp

  --- -offset / -all
  if offset then
    sh_cmd = sh_cmd .. " -offset " .. offset
  else
    sh_cmd = sh_cmd .. " -all"
  end

  --- -clear-options / -remove-options
  if #arglist == 0 then
    sh_cmd = sh_cmd ..
      " -clear-options -quiet -w"
  else
    sh_cmd = sh_cmd ..
      " -remove-options " .. arglist[1] ..
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

local go_remove_tag_opts_cmd = "GoTagOptionsRemove"
vim.api.nvim_buf_create_user_command(
  0,
  go_remove_tag_opts_cmd,
  function(params)
    --- 获取当前 cursor 的 offset, 即在整个文档中的 byte 位置.
    --- VVI: 这里的 cursor 位置不是准确的 cursor byte 位置. 因为:
    --- line2byte('.') 返回当前行第一列的 byte 位置. 不管 cursor 在本行的任意 column, 返回值都相同.
    local offset = vim.fn.line2byte('.')

    --- 'gomodifytags -clear-options -offset n'
    --- 'gomodifytags -remove-options [tag=option] -offset n'
    go_remove_tags_opts(params.fargs, go_remove_tag_opts_cmd, offset)
  end,
  {bang = true, nargs = "*"}
)

local go_remove_tag_opts_all_struct_cmd = "GoTagOptionsRemoveAllStruct"
vim.api.nvim_buf_create_user_command(
  0,
  go_remove_tag_opts_all_struct_cmd,
  function(params)
    --- 通过判断 offset 是否为 nil, 来确定是否需要使用 '-all'.
    --- 'gomodifytags -clear-options -all'
    --- 'gomodifytags -remove-options [tag=option] -all'
    go_remove_tags_opts(params.fargs, go_remove_tag_opts_all_struct_cmd)
  end,
  {bang = true, nargs = "*"}
)



