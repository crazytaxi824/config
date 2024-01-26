--- 自定义 health check

--- require vim.health. `:help health-dev`
local health = vim.health

local M = {}

--- HACK 中用到的 modules, 大多 overwrite 源代码 --------------------------------------------------- {{{
local function check_module()
  local require_list = {
    "bufferline.state",

    "nvim-treesitter.ts_utils",
    "nvim-treesitter.parsers",

    "telescope.finders",
    "telescope.make_entry",
    "telescope.pickers",
    "telescope.config",
  }

  local err_list = {}
  for _, req in ipairs(require_list) do
    local status_ok, _ = pcall(require, req)
    if status_ok then
      health.report_ok('require("' .. req .. '") Success')
    else
      table.insert(err_list, req)
      health.report_error('require("' .. req .. '") Failed')
    end
  end

  if #err_list > 0 then
    return err_list
  end
end

local funcs_list = {
  'vim.lsp.buf_request',
  'vim.lsp.util.make_floating_popup_options',
  'require("nvim-treesitter.parsers").get_buf_lang',
  'require("nvim-treesitter.parsers").has_parser',
  'require("nvim-treesitter.parsers").available_parsers',
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
      health.report_error(fn_str .. ' is not Exist. Error: ' .. err)
    end

    if fn and fn() ~= nil then
      health.report_ok(fn_str .. ' Exists')
    else
      health.report_error(fn_str .. ' is not Exist.')
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

  --- javascript / typescript
  eslint = {cmd="eslint", install="npm install -g eslint"}, -- NOTE: mason 目前不能安装 "eslint"
  jest = {cmd="jest", install="npm install -g jest"},
  --tsc = {cmd="tsc", install="npm install -g typescript"}, -- NOTE: 弃用 typescript.

  --- telescope deps
  fd = {cmd="fd",  install="brew info fd"},
  ripgrep = {cmd="rg",  install="brew info ripgrep"},
}

local function check_cmd_tools(tools)
  for name, tool in pairs(tools) do
    local result = vim.fn.system('which ' .. tool.cmd)
    if vim.v.shell_error == 0 then
      health.report_ok(name)
    else
      local errmsg = {name .. ':'}
      if tool.install then
        table.insert(errmsg, '  - `' .. tool.install .. '`')
      end
      if tool.mason then
        table.insert(errmsg, '  - `:MasonInstall ' .. tool.mason .. '`')
      end
      health.report_error(table.concat(errmsg, '\n'))
    end
  end
end

local mason_tools = {
  "json-lsp",
  "goimports-reviser",
  "goimports",
  "autopep8",
  "bash-language-server",
  "flake8",
  "buf",
  "shfmt",
  "mypy",
  "css-lsp",
  "buf-language-server",
  "prettier",
  "html-lsp",
  "pyright",
  "lua-language-server",
  "typescript-language-server",
}

local function check_mason_tools()
  local pkgs = require("mason-registry").get_installed_packages()
  local t = vim.tbl_filter(function(elem)
    for _, pkg in ipairs(pkgs) do
      if elem == pkg.name then
        health.report_ok(elem)
        return false
      end
    end
    return true
  end, mason_tools)

  for _, tool in ipairs(t) do
    health.report_error(tool)
  end
end

-- }}}

M.check = function()
  --- command line tools
  health.report_start("check command line tools")
  check_cmd_tools(cmd_tools)

  --- lsp tools
  local lsp_servers_map = require('lsp.lsp_config.lsp_list')
  health.report_start("check LSP tools")
  check_cmd_tools(lsp_servers_map)

  --- mason tools
  health.report_start("check mason tools")
  check_mason_tools()

  --- module availability check
  health.report_start("check HACK modules availability")
  local errs = check_module()
  if errs then
    health.report_warn('function check aborts due to error in module check.')
    return
  end

  --- funciton availability check
  health.report_start("check HACK functions availability")
  check_plugin_funcs()
end

return M
