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

local function check_funcs()
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
    health.report_error('require("nvim-treesitter.parsers").get_buf_lang() is not Exist.\ncheck user/plugin_settings/treesitter.lua')
  end
  if require("nvim-treesitter.parsers").has_parser ~= nil then
    health.report_ok('require("nvim-treesitter.parsers").has_parser() Exists')
  else
    health.report_error('require("nvim-treesitter.parsers").has_parser() is not Exist.\ncheck user/plugin_settings/treesitter.lua')
  end
  if require("nvim-treesitter.parsers").available_parsers ~= nil then
    health.report_ok('require("nvim-treesitter.parsers").available_parsers() Exists')
  else
    health.report_error('require("nvim-treesitter.parsers").available_parsers() is not Exist.\ncheck user/plugin_settings/treesitter.lua')
  end

  if require("luasnip").unlink_current ~= nil then
    health.report_ok('require("luasnip").unlink_current() Exists')
  else
    health.report_error('require("luasnip").unlink_current() is not Exist.\ncheck user/plugin_settings/luasnip_snippets.lua')
  end

  if require("telescope.finders").new_table ~= nil then
    health.report_ok('require("telescope.finders").new_table() Exists')
  else
    health.report_error('require("telescope.finders").new_table() is not Exist.\ncheck user/plugin_settings/telescope_fzf.lua')
  end
  if require("telescope.pickers").new ~= nil then
    health.report_ok('require("telescope.pickers").new() Exists')
  else
    health.report_error('require("telescope.pickers").new() is not Exist.\ncheck user/plugin_settings/telescope_fzf.lua')
  end
  if require("telescope.make_entry").gen_from_vimgrep ~= nil then
    health.report_ok('require("telescope.make_entry").gen_from_vimgrep() Exists')
  else
    health.report_error('require("telescope.make_entry").gen_from_vimgrep() is not Exist.\ncheck user/plugin_settings/telescope_fzf.lua')
  end
  if require("telescope.config").values.grep_previewer ~= nil then
    health.report_ok('require("telescope.config").values.grep_previewer() Exists')
  else
    health.report_error('require("telescope.config").values.grep_previewer() is not Exist.\ncheck user/plugin_settings/telescope_fzf.lua')
  end
  if require("telescope.config").values.generic_sorter ~= nil then
    health.report_ok('require("telescope.config").values.generic_sorter() Exists')
  else
    health.report_error('require("telescope.config").values.generic_sorter() is not Exist.\ncheck user/plugin_settings/telescope_fzf.lua')
  end
end

M.check = function()
  --- module availability check
  health.report_start("check HACK modules availability")
  health.report_info("check HACK function required modules.\n mostly rewrite plugins' internal functions.")
  local errs = check_module()

  --- funciton availability check
  health.report_start("check HACK functions availability")
  if errs then
    health.report_warn('function check aborts due to error in module check.')
    return
  end
  check_funcs()
end

return M
