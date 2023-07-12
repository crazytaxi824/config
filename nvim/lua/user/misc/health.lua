--- 自定义 health check

--- require vim.health. `:help health-dev`
local health = vim.health

local M = {}

--- HACK 中用到的 modules, 大多 overwrite 源代码.
local function check_module()
  health.report_start("check HACK required modules")
  health.report_info("check HACK function required modules.\n mostly rewrite plugins' internal functions.")

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
    "telescope.actions.state",
    "telescope.actions.mt",

    "null-ls.utils",
  }

  for _, req in ipairs(require_list) do
    local status_ok, _ = pcall(require, req)
    if status_ok then
      health.report_ok('require("' .. req .. '") Success')
    else
      health.report_error('require("' .. req .. '") Failed')
    end
  end
end

local function check_HACK()
  health.report_start("check HACK required functions")
  if vim.lsp.buf_request ~= nil then
    health.report_ok('vim.lsp.buf_request() Exists')
  else
    health.report_error('vim.lsp.buf_request() is not Exist.\ncheck user/lsp "textDocument/documentHighlight" custom handlers')
  end
end

M.check = function()
  check_module()
  check_HACK()
end

return M
