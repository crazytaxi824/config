-- 自定义 health check

-- require vim.health. `:help health-dev`
local health = vim.health

local M = {}

local function check_mason_tools()
  -- 分析 mason_record
  local stat = vim.uv.fs_stat(Mason.lock_file)
  if not stat then
    health.error(Mason.lock_file, "file is not available")
    return
  end

  local lines = vim.fn.readfile(Mason.lock_file)
  local json_str = table.concat(lines, "")

  local dec_ok, mason_records = pcall(vim.json.decode, json_str)
  if not dec_ok then
    health.error(Mason.lock_file, "json decode error")
    return
  end

  -- not installed by Mason
  ---@type { name:string, cmds:string[], version:string, lspconfig?:string }[]
  local not_installed = vim.tbl_filter(function(elem)
    if require("mason-registry").is_installed(elem.name) then
      health.ok(elem.name)
      return false
    end
    return true
  end, mason_records)

  -- in $PATH
  for _, tool in ipairs(not_installed) do
    local executable = false
    for _, cmd in ipairs(tool.cmds) do
      if vim.fn.executable(cmd) == 1 then
        executable = true
        break
      end
    end
    if executable then
      health.warn(tool.name, { "is not installed by Mason" })
    else
      health.error(tool.name, { "is not installed" })
    end
  end
end


-- check command line tools ----------------------------------------------------------------------- {{{

---@type table<string, ToolProps>
local cmd_tools = {
  go       = { cmd = "go", install = "https://go.dev" },
  fd       = { cmd = { "fd", "fdfind" },  install = "brew info fd; `Ubuntu/Fedora: fd-find`" },
  graphviz = { cmd = "dot", install = "brew info graphviz" },
  ripgrep  = { cmd = "rg",  install = "brew info ripgrep" },
}


-- print error message
---@param name string
---@param tool ToolProps
local function tool_error_msg(name, tool)
  local errmsg = { name .. ':' }
  if tool.install then
    table.insert(errmsg, string.format('  - `%s`', tool.install))
  end
  if tool.mason then
    table.insert(errmsg, string.format('  - `:MasonInstall %s`', tool.mason))
  end
  health.error(table.concat(errmsg, '\n'))
end


---@param tools table<string, ToolProps>
local function check_cmd_tools(tools)
  for name, tool in pairs(tools) do
    local tool_cmd = tool.cmd
    if type(tool_cmd) == "string" then
      if vim.fn.executable(tool_cmd) == 1 then
        health.ok(name)
      else
        tool_error_msg(name, tool)
      end
    else
      local installed = false
      for _, cmd in ipairs(tool_cmd) do
        if vim.fn.executable(cmd) == 1 then
          installed = true
          break
        end
      end

      if not installed then
        tool_error_msg(name, tool)
      end
    end
  end
end

-- }}}

-- HACK 中用到的 modules & functions, 大多 overwrite 源代码 --------------------------------------- {{{

---@type string[]
local funcs_list = {
  'require("cmp").core.reset',
  'require("luasnip").unlink_current',
  'require("telescope.pickers").new',
  'require("telescope.finders").new_table',
  'require("telescope.make_entry").gen_from_vimgrep',
  'require("telescope.config").values.grep_previewer',
  'require("telescope.config").values.generic_sorter',
}

local function check_plugin_funcs()
  for _, fn_str in ipairs(funcs_list) do
    -- 使用loadstring (Lua 5.1) 或 load (Lua 5.2及更高版本) 函数将表达式编译成函数
    local fn, err = load("return " .. fn_str)
    if err then
      health.error(string.format('%s is not Exist. Error: %s', fn_str, err))
    end

    if fn and fn() ~= nil then
      health.ok(fn_str .. ' Exists')
    else
      health.error(fn_str .. ' is not Exist.')
    end
  end
end

-- }}}

M.check = function()
  -- |xxx|: Underlined
  -- {xxx}: cyan Identifier
  -- `xxx`: blue Special
  -- <xxx>: SpecialChar
  health.start("vimdoc highlight, `eg`:")
  health.ok("<SpecialChar>, `Special`, |Underlined|, {Identifier}")

  -- command line tools
  health.start("check command line tools")
  check_cmd_tools(cmd_tools)

  -- lsp tools
  local lsp_servers_map = require('lsp.svr_list').list
  health.start("check LSP tools")
  check_cmd_tools(lsp_servers_map)

  -- mason tools
  health.start("check mason tools")
  check_mason_tools()

  -- funciton availability check
  health.start("check HACK functions availability")
  check_plugin_funcs()
end

return M
