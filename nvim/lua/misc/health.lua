-- 自定义 health check

-- require vim.health. `:help health-dev`
local health = vim.health

local M = {}

local mason_record = [[
  bash-language-server
  buf
  css-lsp
  delve
  eslint-lsp
  gdtoolkit
  goimports
  goimports-reviser
  golangci-lint
  gomodifytags
  gopls
  gotests
  html-lsp
  impl
  json-lsp
  lua-language-server
  prettier
  ruff
  shfmt
  sql-formatter
  sqls
  stylua
  tombi
  tree-sitter-cli
  ty
  typescript-language-server
  yaml-language-server
]]

local function check_mason_tools()
  -- 分析 mason_record string
  ---@type string[]
  local lines = vim.split(mason_record, "\n", { plain = true, trimempty = true })

  ---@type string[]
  local mason_tools = vim.tbl_map(vim.trim, lines)

  local pkgs = require("mason-registry").get_installed_packages()

  ---@type string[]  not installed by mason
  local t = vim.tbl_filter(function(elem)
    for _, pkg in ipairs(pkgs) do
      if elem == pkg.name then
        health.ok(elem)
        return false
      end
    end
    return true
  end, mason_tools)

  for _, tool in ipairs(t) do
    if vim.fn.executable(tool) == 1 then
      health.warn(tool, { "is not installed by Mason" })
    else
      health.error(tool, { "is not installed" })
    end
  end
end


-- check command line tools ----------------------------------------------------------------------- {{{

---@type table<string, ToolProps>
local cmd_tools = {
  go = { cmd = "go", install = "https://go.dev" },
  graphviz = { cmd = "dot", install = "brew info graphviz" },
  ripgrep =  { cmd = "rg",  install = "brew info ripgrep" },
  fd =       { cmd = "fd",  install = "brew info fd" },
}


-- print error message
---@param name string
---@param tool ToolProps
local function tool_error_msg(name, tool)
  local errmsg = { name .. ':' }
  if tool.install then
    table.insert(errmsg, '  - `' .. tool.install .. '`')
  end
  if tool.mason then
    table.insert(errmsg, '  - `:MasonInstall ' .. tool.mason .. '`')
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
      health.error(fn_str .. ' is not Exist. Error: ' .. err)
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
