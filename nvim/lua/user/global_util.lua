--- NOTE: 返回光标所在位置是否已经在最左侧了, 或者光标前一个字符是否为 %s, 即:\n \t \r space ...
---       目的是判断是否需要执行 backspace.
---       true - 本行前一位没有任何字符; nil - 本行前一位有字符.
function Check_backspace()
  local col = vim.fn.col(".") - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

--- 去掉 string prefix suffix whitespace -----------------------------------------------------------
function Trim_string(str)
  return string.match(str, "^%s*(.-)%s*$")
end

--- escape charactor -------------------------------------------------------------------------------
function Escape_chars(string)
  return string.gsub(string, "[%(|%)|\\|%[|%]|%-|%{%}|%?|%+|%*|%^|%$|%.]", {
    ["\\"] = "\\\\",
    ["-"] = "\\-",
    ["("] = "\\(",
    [")"] = "\\)",
    ["["] = "\\[",
    ["]"] = "\\]",
    ["{"] = "\\{",
    ["}"] = "\\}",
    ["?"] = "\\?",
    ["+"] = "\\+",
    ["*"] = "\\*",
    ["^"] = "\\^",
    ["$"] = "\\$",
    ["."] = "\\.",
  })
end

--- 提醒使用 notify 插件或者 vim.notify() 函数 -----------------------------------------------------
--- msg - string|[]string
--- lvl - string|number. "TRACE"-0, "DEBUG"-1, "INFO"-2, "WARN"-3, "ERROR"-4, `:help vim.log.levels`, `:help notify.setup`
--- opt - table, nvim-notify 插件专用 `:help notify.Options`, title, timeout...
function Notify(msg, lvl, opt)
  --- switch to vim.log.levels
  local l = nil
  if type(lvl) == 'number' then
    l = lvl
  elseif type(lvl) == 'string' then
    if string.upper(lvl) == "TRACE" then
      l = 0
    elseif string.upper(lvl) == "DEBUG" then
      l = 1
    elseif string.upper(lvl) == "INFO" then
      l = 2
    elseif string.upper(lvl) == "WARN" then
      l = 3
    elseif string.upper(lvl) == "ERROR" then
      l = 4
    end
  end

  local notify_status_ok, notify = pcall(require, "notify")
  if notify_status_ok then
    notify(msg, l, opt)
  else
    if type(msg) == 'table' then
      --- msg should be table array, join message []string with '\n'
      vim.notify(vim.fn.join(msg, '\n'), l)
    else
      vim.notify(msg, l)
    end
  end
end

--- 使用 `$ which` 查看插件所需 tools 是否存在 -----------------------------------------------------
function Check_cmd_tools(tools)
  local result = {"These Tools should be in the $PATH"}
  local count = 0
  for tool, install in pairs(tools) do
    vim.fn.system('which '.. tool)
    if vim.v.shell_error ~= 0 then
      table.insert(result, tool .. ": " .. install)
      count = count + 1
    end
  end

  if count > 0 then
    Notify(result, "WARN", {title = {"Check_Tools()", "global_util.lua"}, timeout = false})
  end
end

--- key-settings for both vim.keymap.set() and which_key.register() --------------------------------
--- keymap_list: { mode, key, remap, opt, description }  - description for 'which-key'
--- register: which_key.register({keymap},{opts}) 中的两个入参.
function Keymap_set_and_register(keymap_list, register)
  --- NOTE: 这里是正真设置 keymap 的地方, 下面的 which-key 如果不存在, 也不会影响 keymap 设置.
  for _, kv in ipairs(keymap_list) do
    vim.keymap.set(kv[1], kv[2], kv[3], kv[4])
  end

  --- NOTE: which-key 主要是起到显示 description 的作用.
  local wk_status_ok, which_key = pcall(require, "which-key")
  if not wk_status_ok then
    return
  end

  --- NOTE: 参考 which_key.register({keymap},{opts}) 设置
  --- https://github.com/folke/which-key.nvim#%EF%B8%8F-mappings
  for _, keymap in ipairs(keymap_list) do
    if keymap[5] then
      which_key.register({[keymap[2]] = keymap[5]},{mode = keymap[1]})
    end
  end

  --- set group name manually ---
  --- 如果 register.opts 为 nil, 则使用默认值 --- {{{
  -- {
  --   mode = "n", -- NORMAL mode
  --   -- prefix: use "<leader>f" for example for mapping everything related to finding files
  --   -- the prefix is prepended to every mapping part of `mappings`
  --   prefix = "",
  --   buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  --   silent = true, -- use `silent` when creating keymaps
  --   noremap = true, -- use `noremap` when creating keymaps
  --   nowait = false, -- use `nowait` when creating keymaps
  -- }
  -- -- }}}
  if register and register.key_desc then
    which_key.register(register.key_desc, register.opts)
  end
end

--- Jump to file -----------------------------------------------------------------------------------
--- 利用 local list 跳转到 log 文件
function Jump_to_file(filepath, lnum)
  if not filepath then
    return
  end

  if not lnum then  --- 如果 lnum 不存在, 跳到文件第一行.
    lnum = 1
  end

  local same_file_win_id = -1  -- 用于设置 setloclist()
  local loc_items = nil     -- 初始化 local list item

  -- 寻找和 log 打印的 filepath 相同的 win_id. 如果有则跳转到该 window.
  for _, win_info in ipairs(vim.fn.getwininfo()) do
    local bufpath = vim.fn.fnamemodify(vim.fn.bufname(win_info.bufnr), ':p')  -- convert bufname to absolute path
    local logpath = vim.fn.fnamemodify(filepath, ':p')  -- convert log path to absolute path

    if bufpath == logpath then  -- bufpath 和 logpath 相同的情况下, 跳转到该 window.
      same_file_win_id = win_info.winid
      loc_items = {filename = bufpath, lnum = lnum, text='jump_to_log_file()'}
      break
    elseif vim.fn.buflisted(win_info.bufnr) == 1 then
      -- 如果所有的 win 中都没有 log 打印的 filepath, 则选择一个 listed buffer 的 winid 用于跳转.
      same_file_win_id = win_info.winid
      break
    end
  end

  -- 如果所有的 win 中都没有 log 打印的 filepath, 则检查该 filepath 是否是可以打开的文件.
  if not loc_items then
    if vim.fn.filereadable(filepath) == 1 then
      loc_items = {filename = filepath, lnum = lnum, text='jump_to_log_file()'}
    end
  end

  -- 如果有 local list item, 则进行跳转.
  if loc_items then
    if vim.fn.win_gotoid(same_file_win_id) == 1 then
      vim.fn.setloclist(same_file_win_id, {loc_items}, 'r')  -- 给指定 window 设置 loclist
      vim.cmd('silent lfirst')  -- jump to loclist first item
      vim.fn.setloclist(same_file_win_id, {}, 'r')  -- clear loclist
    else
      -- 如果 go_run_win_id 不存在, 则在 terminal 正上方创建一个新的 window.
      vim.cmd('leftabove split ' .. loc_items.filename)
      same_file_win_id = vim.fn.win_getid()
      vim.fn.setloclist(same_file_win_id, {loc_items}, 'r')  -- 给指定 window 设置 loclist
      vim.cmd('silent lfirst')  -- jump to loclist first item
      vim.fn.setloclist(same_file_win_id, {}, 'r')  -- clear loclist
    end
  end
end

--- terminal normal 模式跳转文件 -------------------------------------------------------------------
--- 操作方法: 在 terminal normal 模式中, 在行的任意位置使用 <CR> 跳转到文件.
function Line_filepath()
  return Parse_line_filepath(vim.fn.getline('.'))
end

function Parse_line_filepath(lcontent)
  local fp = vim.split(vim.fn.trim(lcontent), ":")
  if fp[2] then
    local lnum = tonumber(vim.split(fp[2], " ")[1])  -- tonumber(nil) = nil; tonumber('a') = nil
    return fp[1], lnum
  end
  return fp[1], nil
end

--- TermClose 意思是 job done
--- TermLeave 意思是 term 关闭
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = {"term://*"},
  callback = function()
    vim.keymap.set('n', '<CR>',
      "<cmd>lua Jump_to_file(Line_filepath())<CR>",
      {noremap = true, silent = true, buffer = true} -- local to Terminal buffer
    )
  end,
})

--- VISIAL 模式跳转文件 ----------------------------------------------------------------------------
--- VISUAL 选中的 filepath, 不管在什么 filetype 中都跳转
--- 操作方法: visual select 'filepath:lnum', 然后使用 <CR> 跳转到文件.
function Visual_selected_filepath()
  --- NOTE: getpos("'<") 和 getpos("'>") 必须在 normal 模式执行, 意思是从 visual mode 退出后再执行以下函数.
  --- `:echo getline("'<")[getpos("'<")[2]-1:getpos("'>")[2]-1]`
  local startpos = vim.fn.getpos("'<")
  local endpos = vim.fn.getpos("'>")
  --- 如果不在同一行则 return
  if startpos[2] ~= endpos[2] then
    return
  end

  local v_content = string.sub(vim.fn.getline("'<"), startpos[3], endpos[3])
  local fp = vim.split(v_content, ":")
  local lnum = tonumber(fp[2])  -- tonumber(nil) = nil; tonumber('a') = nil
  return fp[1], lnum
end

vim.keymap.set('v', '<CR>',
  "<C-c>:lua Jump_to_file(Visual_selected_filepath())<CR>",
  {noremap = true, silent = true}
)



