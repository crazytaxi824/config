-- NOTE: 返回光标所在位置是否已经在最左侧了, 或者光标前一个字符是否为 %s, 即:\n \t \r space ...
--       目的是判断是否需要执行 backspace.
--       true - 本行前一位没有任何字符; nil - 本行前一位有字符.
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
    Notify(result, "WARN", {title = {"Check_Tools()", "util.lua"}, timeout = false})
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



