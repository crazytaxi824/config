--- require vim.health. `:help health-dev`
local health
if vim.fn.has("nvim-0.9") == 1 then
  health = vim.health
else
  health = require("health")
end

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
      health.report_warn('require("' .. req .. '") Failed')
    end
  end
end

M.check = function()
  check_module()
end

return M
