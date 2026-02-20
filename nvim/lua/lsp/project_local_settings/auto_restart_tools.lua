local utils = require("lsp.project_local_settings.utils")

--- reload local settings when ".nvim/lsp.json" changed
local lsp_gid = vim.api.nvim_create_augroup("my_reload_local_lsp_settings", {clear=true})
vim.api.nvim_create_autocmd({'BufWritePost'}, {
  group = lsp_gid,
  pattern = { "**/" .. utils.lsp_file },
  callback = function(params)
    if vim.fs.abspath(params.file) == utils.find_local_settings_file(utils.lsp_file) then
      local p = require("lsp.lsp_config.update_config")
      local old = p.exist_settings()
      p.reload_local_settings()
      local new = p.exist_settings()

      local tools = utils.find_diff_tool(old, new)
      p.restart_lsps(tools)
      vim.notify("restart lsp: " .. table.concat(tools, ", "))
    end
  end,
  desc = "reload local settings when '.nvim/lsp.json' changed",
})

--- reload local settings when ".nvim/linter.json" changed
local linter_gid = vim.api.nvim_create_augroup("my_reload_local_linter_settings", {clear=true})
vim.api.nvim_create_autocmd({'BufWritePost'}, {
  group = linter_gid,
  pattern = { "**/" .. utils.linter_file },
  callback = function(params)
    if vim.fs.abspath(params.file) == utils.find_local_settings_file(utils.linter_file) then
      local p = require("lsp.null_ls.sources")
      local old = p.exist_settings()
      p.reload_local_settings()
      local new = p.exist_settings()

      local tools = utils.find_diff_tool(old, new)
      p.restart_linters(tools)
    end
  end,
  desc = "reload local settings when '.nvim/linter.json' changed",
})



