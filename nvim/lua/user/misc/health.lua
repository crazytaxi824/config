--- require vim.health. `:help health-dev`
local health = require("health")

local M = {}

M.check = function()
  health.report_start("check HACK required modules")

  health.report_info("check HACK function required modules.\n mostly rewrite plugins' internal functions.")

  --- HACK 中用到的 modules, 大多 overwrite 源代码.
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

  for _, req in ipairs(require_list) do
    local status_ok, _ = pcall(require, req)
    if status_ok then
      health.report_ok('require("' .. req .. '") Success')
    else
      health.report_warn('require("' .. req .. '") Failed')
    end
  end

  -- health.report_error("error")  -- red
end

return M