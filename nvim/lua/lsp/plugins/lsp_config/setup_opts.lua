--- DOCS: `:help vim.lsp.ClientConfig`

local ms = vim.lsp.protocol.Methods

local M = {}

--- 停止输入文字的时间超过该数值, 则向 lsp server 发送请求.
--- 如果 "diagnostic.config({update_in_insert = false})", 则该设置应该不生效.
M.flags = { debounce_text_changes = 500 }   --- 默认 150.

--- on_error() invoked when the client operation throws an error. ----------------------------------
M.on_error = function(code)
  Notify(vim.inspect(vim.lsp.rpc.client_errors[code]), "ERROR", {title = "lspconfig/setup_opts.lua"})
end

--- capabilities -----------------------------------------------------------------------------------
--- VVI: lspconfig 必须在 cmp_nvim_lsp 之后加载, 否则可能无法提供代码补全.
local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
  --- "cmp_nvim_lsp" 不存在的情况, 可以使用 lsp 功能, 但是无法提供 lsp 代码补全.
  Notify({
    '"cmp_nvim_lsp" can NOT be loaded when setup lsp.capabilities.',
    'LSP Auto-Completion may NOT be able to use.',
  }, 'INFO')

  --- lspconfig default_config 中 capabilities 有默认设置.
  --- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/util.lua
  M.capabilities = vim.lsp.protocol.make_client_capabilities()
else
  --- "cmp_nvim_lsp" 存在的情况, 可以使用 lsp 功能, 也可以提供 lsp 代码补全.
  --- https://github.com/hrsh7th/cmp-nvim-lsp#setup
  M.capabilities = cmp_nvim_lsp.default_capabilities()
end

--- lsp_fold 设置
--- https://github.com/kevinhwang91/nvim-ufo
--- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/
M.capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true
}

--- before_init() can be used to debug lsp configs. ------------------------------------------------
-- M.before_init = function(initialize_params, config)
--   vim.print(initialize_params)
--   vim.print(config)
-- end

--- on_init() run before on_attach(), 可以通过打印看出先后顺序.
M.on_init = function(client, result)
  -- if client.server_capabilities then
  --   --- semantic token: https://code.visualstudio.com/api/language-extensions/semantic-highlight-guide
  --   --- `:help vim.lsp.semantic_tokens.start()`
  --   client.server_capabilities.semanticTokensProvider = nil  -- lsp: "textDocument/semanticTokens" highlight
  --
  --   --- DEBUG: lsp-fold 设置
  --   client.server_capabilities.foldingRangeProvider = nil
  -- end

  --- DEBUG: 用
  if __Debug_Neovim.lsp then
    Notify("LSP Server init: " .. client.name, "DEBUG", {title="LSP"})
  end

  --- VVI: 如果 return false 则 LSP 不启动.
  return true
end

--- on_attach - 加载 Key mapping & highlight 设置
--- 这里传入的 client 是正在加载的 lsp_client, vim.print(client) 中可以看到 codeActionKind.
M.on_attach = function(client, bufnr)
  --- 加载自定义设置 ---
  --- textDocument/documentHighlight, 显示 references
  if client:supports_method(ms.textDocument_documentHighlight, bufnr) then
    require("lsp.plugins.custom_requests.doc_highlight").setup(client, bufnr)
  end

  --- keymaps ---
  local lsp_keymaps = require("lsp.plugins.lsp_keymaps")
  lsp_keymaps.textDocument_keymaps(bufnr)
  lsp_keymaps.diagnostic_keymaps(bufnr)

  --- DEBUG: 用
  if __Debug_Neovim.lsp then
    Notify("LSP Server attach: " .. client.name .. " - bufnr(" .. bufnr .. ")", "DEBUG", {title="LSP"})
  end
end

return M
