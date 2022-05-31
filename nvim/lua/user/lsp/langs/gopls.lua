-- 官方文档
-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
-- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#neovim-config


return {
  --cmd = { "gopls" },
  --filetypes = {"go", "gomod"},

  --- NOTE: lspconfig.util.root_pattern() 只能在这里使用, 不能在 project_lsp_config 中使用.
  --- project_lsp_config 中设置 root_dir 直接使用 string. eg: root_dir = "/a/b/c"; root_dir = vim.fn.getcwd().
  --root_dir = function(fname)  -- fname == :echo expand('%:p')
  --  local util = require("lspconfig/util")
  --  return util.root_pattern 'go.work'(fname) or util.root_pattern('go.mod', '.git')(fname)
  --end,

  settings = {
    gopls = {
      ["ui.completion.usePlaceholders"] = true,
      ["ui.diagnostic.staticcheck"] = false,
    },
  },
}
