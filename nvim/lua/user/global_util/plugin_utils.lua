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
    --- NOTE: debug.getinfo() 获取 source filename & function name
    --- debug.getinfo() 第一个参数是 stack level, 如果是 1 则会返回本文件名, 即: 'plugin_utils.lua'.
    --- 如果是 2 则会返回调用 Notify() 的文件名.
    --- source 返回的内容中:
    ---   If source starts with a '@', it means that the function was defined in a file;
    ---   If source starts with a '=', the remainder of its contents describes the source in a user-dependent manner.
    ---   Otherwise, the function was defined in a string where source is that string.
    local call_file = debug.getinfo(2, 'S').source

    local default_title = {}
    if string.sub(call_file, 1, 1) == '@' then
      local file_path_list = vim.split(call_file, '/')
      local script_filename = file_path_list[#file_path_list]
      default_title = {title = script_filename}
    end

    opt = opt or {}  -- 确保 opt 是 table, 而不是 nil. 否则无法用于 vim.tbl_deep_extend()
    opt = vim.tbl_deep_extend('force', default_title, opt)

    --- 如果调用本函数时传入了 opt, 则使用传入的值.
    notify.notify(msg, l, opt)

  else
    --- 如果 nvim-notify 不存在则使用 vim.notify()
    if type(msg) == 'table' then
      --- msg should be table array, join message []string with '\n'
      vim.notify(vim.fn.join(msg, '\n'), l)
    else
      vim.notify(msg, l)
    end
  end
end

--- 使用 `$ which` 查看插件所需 tools 是否存在 -----------------------------------------------------
function Check_cmd_tools(tools, opt)
  --- NOTE: "vim.schedule(function() ... end)" is a async function
  vim.schedule(function()
    local result = {"These Tools should be in the $PATH, or `:Mason` install"}
    local count = 0
    for tool, install in pairs(tools) do
      vim.fn.system('which '.. tool)
      if vim.v.shell_error ~= 0 then
        table.insert(result, tool .. ": " .. install)
        count = count + 1
      end
    end

    if count > 0 then
      opt = opt or {}  -- 确保 opt 是 table, 而不是 nil. 否则无法用于 vim.tbl_deep_extend()
      opt = vim.tbl_deep_extend('force', {timeout=false}, opt)
      Notify(result, "WARN", opt)
    end
  end)
end

--- key-settings for both vim.keymap.set() and which_key.register() --------------------------------
--- keymap_list: { mode, key, remap, opt, description }  - description for 'which-key'
--- keys_desc_only: which_key.register({keymap},{opts}) 中的两个入参. 用于只注册到 which-key 中显示, 而不用真的 keymap.
function Keymap_set_and_register(keymap_list, keys_desc_only)
  --- NOTE: 这里是正真设置 keymap 的地方, 下面的 which-key 如果不存在, 也不会影响 keymap 设置.
  for _, keymap in ipairs(keymap_list) do
    vim.keymap.set(keymap[1], keymap[2], keymap[3], keymap[4])
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
  --- 如果 opts 为 nil, 则使用默认值 --- {{{
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
  if keys_desc_only and keys_desc_only.key_desc then
    which_key.register(keys_desc_only.key_desc, keys_desc_only.opts)
  end
end



