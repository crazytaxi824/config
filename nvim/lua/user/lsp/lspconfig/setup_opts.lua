--- NOTE: handlers.lua 主要返回一个 table, 带 "on_attach", "capabilities" 属性.
--  - on_attach     当 LSP 存在时加载设置 key_mapping, highlight ... 等设置.
--  - capabilities  给 cmp 自动补全提供内容.
--
--- 其他非必需属性:
--  - on_init = function(lsp_client) -- https://github.com/neovim/nvim-lspconfig/wiki/Project-local-settings
--    可以用来加载 project local settings.
--    修改之后使用 lsp_client.notify("workspace/didChangeConfiguration") 通知 LSP server.

local M = {}

--- work like Same_ID, `:help vim.lsp.buf.document_highlight()` ------------------------------------ {{{
--    NOTE: Usage of |vim.lsp.buf.document_highlight()| requires the
--    following highlight groups to be defined or you won't be able
--    to see the actual highlights. |LspReferenceText|
--    |LspReferenceRead| |LspReferenceWrite|
local function lsp_highlight(client)
  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    -- TODO clear_references() when 'documentHighlight' return different result.
    -- vim.lsp.buf_request(0, 'textDocument/documentHighlight',
    --    vim.lsp.util.make_position_params(), function(_,r,_,_) print(vim.inspect(r)) end)
    -- 判断两个 table 的内容是否相同.
    vim.cmd [[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        "autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()  -- insert mode
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        autocmd CursorMovedI <buffer> lua vim.lsp.buf.clear_references()   -- insert mode
      augroup END
    ]]
  end
end
-- -- }}}

--- NOTE: on_attach - 加载 Key mapping & highlight 设置 --------------------------------------------
---       这里传入的 client 是正在加载的 lsp_client, vim.inspect(client) 中可以看到 codeActionKind.
M.on_attach = function(client, bufnr)
  --- VVI: 禁止使用 LSP 的 formatting 功能, 在 null-ls 中使用其他 format 工具
  --- `:lua print(vim.inspect(vim.lsp.buf_get_clients()))` 查看启动的 lsp 和所有相关设置
  --- ts, js, html, json, jsonc ... 使用 'prettier'
  --- lua 使用 'stylua'
  local disable_format = {"tsserver", "html", "sumneko_lua", "jsonls"}
  if vim.tbl_contains(disable_format, client.name) then
    client.resolved_capabilities.document_formatting = false
  end

  --- 加载自定义设置 ---
  --- Same_ID
  lsp_highlight(client)

  --- 设置 lsp 专用 keymaps
  local lsp_keymaps = require("user.lsp.util.lsp_keymaps")
  lsp_keymaps.textDocument_keymaps(bufnr)
  lsp_keymaps.diagnostic_keymaps(bufnr)
end

--- NOTE: capabilities - Provides content to "hrsh7th/cmp-nvim-lsp" Completion ---------------------
local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
  return
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

--- https://github.com/neovim/nvim-lspconfig/wiki/Project-local-settings
--- NOTE: LSP settings Hook, 不是必要设置 ----------------------------------------------------------
--- 这里是为了能单独给 project 设置 LSP setting
M.on_init = function(client)
  --- 加载项目本地设置, 覆盖 global settings.
  if __Proj_local_settings.exists("settings", client.name) then
    client.config.settings[client.name] = __Proj_local_settings.exists_keep_extend("settings", client.name,
      client.config.settings[client.name])

    --- VVI: tell LSP configs are changed.
    --- 有些 LSP server 不支持 didChangeConfiguration. eg: jsonls
    client.notify("workspace/didChangeConfiguration")
  end

  return true  -- VVI: 如果 return false 则 LSP 不启动.
end

return M



