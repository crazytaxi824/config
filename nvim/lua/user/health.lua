--- 自定义 health check

--- require vim.health. `:help health-dev`
local health = vim.health

local M = {}

--- HACK 中用到的 modules, 大多 overwrite 源代码.
local function check_module()
  local require_list = {
    "bufferline.state",

    "nvim-tree.renderer.components.git",
    "nvim-tree.renderer.builder",

    "nvim-treesitter.ts_utils",
    "nvim-treesitter.parsers",

    "telescope.finders",
    "telescope.make_entry",
    "telescope.pickers",
    "telescope.config",

    "null-ls.utils",
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

local function check_plugin_funcs()
  if vim.lsp.buf_request ~= nil then
    health.report_ok('vim.lsp.buf_request() Exists')
  else
    health.report_error('vim.lsp.buf_request() is not Exist.\ncheck user/lsp "textDocument/documentHighlight" custom handlers')
  end

  if vim.lsp.util.make_floating_popup_options ~= nil then
    health.report_ok('vim.lsp.util.make_floating_popup_options() Exists')
  else
    health.report_error('vim.lsp.util.make_floating_popup_options() is not Exist.\ncheck user/lsp/_user_handlers.lua')
  end

  if require("nvim-treesitter.parsers").get_buf_lang ~= nil then
    health.report_ok('require("nvim-treesitter.parsers").get_buf_lang() Exists')
  else
    health.report_error('require("nvim-treesitter.parsers").get_buf_lang() is not Exist.\ncheck user/plugins/settings/treesitter.lua')
  end
  if require("nvim-treesitter.parsers").has_parser ~= nil then
    health.report_ok('require("nvim-treesitter.parsers").has_parser() Exists')
  else
    health.report_error('require("nvim-treesitter.parsers").has_parser() is not Exist.\ncheck user/plugins/settings/treesitter.lua')
  end
  if require("nvim-treesitter.parsers").available_parsers ~= nil then
    health.report_ok('require("nvim-treesitter.parsers").available_parsers() Exists')
  else
    health.report_error('require("nvim-treesitter.parsers").available_parsers() is not Exist.\ncheck user/plugins/settings/treesitter.lua')
  end

  if require("luasnip").unlink_current ~= nil then
    health.report_ok('require("luasnip").unlink_current() Exists')
  else
    health.report_error('require("luasnip").unlink_current() is not Exist.\ncheck user/plugins/settings/luasnip_snippets.lua')
  end

  if require("telescope.finders").new_table ~= nil then
    health.report_ok('require("telescope.finders").new_table() Exists')
  else
    health.report_error('require("telescope.finders").new_table() is not Exist.\ncheck user/plugins/settings/telescope_fzf.lua')
  end
  if require("telescope.pickers").new ~= nil then
    health.report_ok('require("telescope.pickers").new() Exists')
  else
    health.report_error('require("telescope.pickers").new() is not Exist.\ncheck user/plugins/settings/telescope_fzf.lua')
  end
  if require("telescope.make_entry").gen_from_vimgrep ~= nil then
    health.report_ok('require("telescope.make_entry").gen_from_vimgrep() Exists')
  else
    health.report_error('require("telescope.make_entry").gen_from_vimgrep() is not Exist.\ncheck user/plugins/settings/telescope_fzf.lua')
  end
  if require("telescope.config").values.grep_previewer ~= nil then
    health.report_ok('require("telescope.config").values.grep_previewer() Exists')
  else
    health.report_error('require("telescope.config").values.grep_previewer() is not Exist.\ncheck user/plugins/settings/telescope_fzf.lua')
  end
  if require("telescope.config").values.generic_sorter ~= nil then
    health.report_ok('require("telescope.config").values.generic_sorter() Exists')
  else
    health.report_error('require("telescope.config").values.generic_sorter() is not Exist.\ncheck user/plugins/settings/telescope_fzf.lua')
  end
end

local tools = {
  go = {cmd="go", install="https://go.dev/"},
  ddlve = {cmd="dlv", install="go install github.com/go-delve/delve/cmd/dlv@latest", mason="delve"},
  impl = {cmd="impl", install="go install github.com/josharian/impl@latest", mason="impl"},
  gotests = {cmd="gotests", install="go install github.com/cweill/gotests/gotests@latest", mason="gotests"},
  gomodifytags = {cmd="gomodifytags", install="go install github.com/fatih/gomodifytags@latest", mason="gomodifytags"},
  goimports = {cmd="goimports", install="go install golang.org/x/tools/cmd/goimports@latest", mason="goimports"},
  ["goimports-reviser"] = {cmd="goimports-reviser", install="go install -v github.com/incu6us/goimports-reviser/v3@latest", mason="goimports-reviser"},
  ["golangci-lint"] = {cmd="golangci-lint", install="go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest", mason="golangci-lint"},
  graphviz = {cmd="dot", install="brew info graphviz"},
  buf = {cmd="buf", install="go install github.com/bufbuild/buf/cmd/buf@latest", mason = "buf"},  -- protobuf formatter & linter
  prettier = {cmd="prettier", install=" brew info prettier", mason="prettier"},
  shfmt = {cmd="shfmt", install="brew info shfmt", mason="shfmt"},  -- shell format tools
  flake8 = {cmd="flake8", install="python3 -m pip install flake8", mason="flake8"},
  autopep8 = {cmd="autopep8", install="python3 -m pip install autopep8", mason="autopep8"},
  mypy = {cmd="mypy", install="python3 -m pip install mypy", mason="mypy"}, -- 还有个 mypy-extensions 是 mypy 插件
  eslint = {cmd="eslint", install="npm install -g eslint"}, -- NOTE: mason 暂时不能安装 "eslint"

  --- telescope deps
  fd = {cmd="fd",  install="brew info fd"},
  ripgrep = {cmd="rg",  install="brew info ripgrep"},
}

local function check_cmd_tools()
  local lsp_servers_map = require('user.lsp.lsp_config.lsp_list')
  for name, tool in pairs(vim.tbl_deep_extend('error', tools, lsp_servers_map)) do
    local result = vim.fn.system('which ' .. tool.cmd)
    if vim.v.shell_error == 0 then
      health.report_ok(name .. ': installed')
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

M.check = function()
  --- command line tools
  health.report_start("check command line tools")
  check_cmd_tools()

  --- module availability check
  health.report_start("check HACK modules availability")
  health.report_info("mostly rewrite plugins' internal functions.")
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
