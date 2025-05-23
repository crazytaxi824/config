--- 自定义 health check

--- require vim.health. `:help health-dev`
local health = vim.health

local M = {}

--- HACK 中用到的 modules, 大多 overwrite 源代码 --------------------------------------------------- {{{
local function check_module()
  local require_list = {
    "bufferline.state",
    "nvim-treesitter.parsers",
    "telescope.make_entry",
  }

  local err_list = {}
  for _, req in ipairs(require_list) do
    local status_ok, _ = pcall(require, req)
    if status_ok then
      health.ok('require("' .. req .. '") Success')
    else
      table.insert(err_list, req)
      health.error('require("' .. req .. '") Failed')
    end
  end

  if #err_list > 0 then
    return err_list
  end
end

local funcs_list = {
  'require("lspconfig.configs")',
  'vim.lsp.buf_request',

  'require("cmp").core',
  'require("luasnip").unlink_current',
  'require("telescope.finders").new_table',
  'require("telescope.pickers").new',
  'require("telescope.make_entry").gen_from_vimgrep',
  'require("telescope.config").values.grep_previewer',
  'require("telescope.config").values.generic_sorter',
}

local function check_plugin_funcs()
  for _, fn_str in ipairs(funcs_list) do
    --- 使用loadstring (Lua 5.1) 或 load (Lua 5.2及更高版本) 函数将表达式编译成函数
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

--- check command line tools ----------------------------------------------------------------------- {{{
local cmd_tools = {
  go = {cmd="go", install="https://go.dev/"},
  delve = {cmd="dlv", install="go install github.com/go-delve/delve/cmd/dlv@latest", mason="delve"},
  impl = {cmd="impl", install="go install github.com/josharian/impl@latest", mason="impl"},
  gotests = {cmd="gotests", install="go install github.com/cweill/gotests/gotests@latest", mason="gotests"},
  gomodifytags = {cmd="gomodifytags", install="go install github.com/fatih/gomodifytags@latest", mason="gomodifytags"},
  ["golangci-lint"] = {cmd="golangci-lint", install="go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest", mason="golangci-lint"},
  graphviz = {cmd="dot", install="brew info graphviz"},

  wc = { cmd = "wc", install="system builtin" },  -- word, line, byte count of files

  --- telescope deps
  fd = {cmd="fd",  install="brew info fd"},
  ripgrep = {cmd="rg",  install="brew info ripgrep"},
}

local function check_cmd_tools(tools)
  for name, tool in pairs(tools) do
    if vim.fn.executable(tool.cmd) == 1 then
      health.ok(name)
    else
      local errmsg = {name .. ':'}
      if tool.install then
        table.insert(errmsg, '  - `' .. tool.install .. '`')
      end
      if tool.mason then
        table.insert(errmsg, '  - `:MasonInstall ' .. tool.mason .. '`')
      end
      health.error(table.concat(errmsg, '\n'))
    end
  end
end

local mason_tools = {
  "bash-language-server",
  "buf",
  "css-lsp",
  "eslint-lsp",
  -- "gdtoolkit",  -- GDScript
  "goimports",
  "goimports-reviser",
  "html-lsp",
  "json-lsp",
  "lua-language-server",
  "prettier",
  "pyright",
  "ruff",
  "shfmt",
  -- "sql-formatter",
  -- "sqls",  -- sql lsp
  "stylua",
  "typescript-language-server",
}

local function check_mason_tools()
  local pkgs = require("mason-registry").get_installed_packages()
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
    health.error(tool)
  end
end

-- }}}

M.check = function()
  --- command line tools
  health.start("check command line tools")
  check_cmd_tools(cmd_tools)

  --- lsp tools
  local lsp_servers_map = require('lsp.svr_list').list
  health.start("check LSP tools")
  check_cmd_tools(lsp_servers_map)

  --- mason tools
  health.start("check mason tools")
  check_mason_tools()

  --- module availability check
  health.start("check HACK modules availability")
  local errs = check_module()
  if errs then
    health.warn('function check aborts due to error in module check.')
    return
  end

  --- funciton availability check
  health.start("check HACK functions availability")
  check_plugin_funcs()
end

return M
