--- 获取 lsp 列表
local lsp_servers_map = require('lsp.svr_list').list

--- 设置 lsp config
local lsp_update_config = require("lsp.lsp_config.update_config")

--- 读取 & cache local_settings files
lsp_update_config.reload_local_settings()

--- setup 所有 lsp
for lsp_tool, _ in pairs(lsp_servers_map) do
  lsp_update_config.lspconfig_setup(lsp_tool)
end

--- `set filetype=xxx` 时 detach previous LSP.
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"*"},
  callback = function(params)
    local lsp_clients = vim.lsp.get_clients({ bufnr = params.buf })
    for _, c in ipairs(lsp_clients) do
      --- `set filetype` 后, detach 所有不匹配该 buffer 新 filetype 的 lsp client.
      --- NOTE: 排除 null-ls
      if c.name ~= 'null-ls'
        and not vim.tbl_contains(c.config['filetypes'], vim.bo[params.buf].filetype)
      then
        vim.lsp.buf_detach_client(params.buf, c.id)
      end
    end
  end,
  desc = "LSP: detach previous LSP when `set filetype=xxx`",
})



