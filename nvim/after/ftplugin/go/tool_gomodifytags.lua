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
--- NOTE: *.go 被重新加载时, 本文件会被重新读取. 会造成重复设置 command, 所以必须使用 `command!`
--- eg: `:GoAddTags json,xml c`, `:GoAddTags json,xml camel`, `:GoAddTags json`
--- command! -buffer -nargs=+ GoAddTags :lua _GoAddTags(<f-args>)
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
    require("user.ftplugin_deps.go").go_add_tags_and_opts(params.fargs, go_add_tags_cmd, offset)
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
    require("user.ftplugin_deps.go").go_add_tags_and_opts(params.fargs, go_add_tags_all_struct_cmd)
  end,
  {nargs = "+", bang = true}
)

--- Remove Tags and Options ------------------------------------------------------------------------
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
    require("user.ftplugin_deps.go").go_remove_tags(params.fargs, go_remove_tags_cmd, offset)
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
    require("user.ftplugin_deps.go").go_remove_tags(params.fargs, go_remove_tags_all_struct_cmd)
  end,
  {bang = true, nargs = "*"}
)

--- Remove Tag's Options ---------------------------------------------------------------------------
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
    require("user.ftplugin_deps.go").go_remove_tags_opts(params.fargs, go_remove_tag_opts_cmd, offset)
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
    require("user.ftplugin_deps.go").go_remove_tags_opts(params.fargs, go_remove_tag_opts_all_struct_cmd)
  end,
  {bang = true, nargs = "*"}
)



