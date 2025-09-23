--- DOCS: `:help vim.lsp.start()` & `:help vim.lsp.ClientConfig`
--  - capabilities  给 cmp 自动补全提供内容.
--  - on_attach     当 LSP 存在时加载设置 key_mapping, highlight ... 等设置.
--  - on_init = function(lsp_client) -- https://github.com/neovim/nvim-lspconfig/wiki/Project-local-settings
--      可以用来加载 project local settings.
--      修改之后使用 lsp_client.notify("workspace/didChangeConfiguration") 通知 LSP server.

local M = {}

--- cache default configs. map[lsp: settings]
M.default_config = {}

--- NOTE: 停止输入文字的时间超过该数值, 则向 lsp server 发送请求.
--- 如果 "diagnostic.config({update_in_insert = false})", 则该设置应该不生效.
M.flags = { debounce_text_changes = 500 }   --- 默认 150.

--- NOTE: on_error() invoked when the client operation throws an error.
M.on_error = function(code)
  Notify(vim.inspect(vim.lsp.rpc.client_errors[code]), "ERROR", {title = "lspconfig/setup_opts.lua"})
end

--- VVI: lspconfig 必须在 cmp_nvim_lsp 之后加载, 否则可能无法提供代码补全.
local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
  --- "cmp_nvim_lsp" 不存在的情况, 可以使用 lsp 功能, 但是无法提供 lsp 代码补全.
  Notify({
    '"cmp_nvim_lsp" can NOT be loaded when setup lsp.capabilities.',
    'LSP Auto-Completion may NOT be able to use.',
  }, 'INFO')

  --- NOTE: lspconfig default_config 中 capabilities 有默认设置.
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

--- NOTE: before_init() can be used to debug lsp configs.
-- M.before_init = function(initialize_params, config)
--   vim.print(initialize_params)
--   vim.print(config)
-- end

--- .nvim/settings.lua 中的 local 设置. ---------------------------------------- {{{
-- return {
--   lsp = {
--     gopls = {
--       -- ["ui.completion.usePlaceholders"] = false,
--       -- ["ui.diagnostic.staticcheck"] = false,
--     }
--   },
-- }
-- -- }}}
M.local_lspconfig_key = "lsp"

--- on_init() run before on_attach(), 可以通过打印看出先后顺序.
M.on_init = function(client, result)
  --- 加载项目本地设置, 覆盖 global settings -----------------------------
  --- DOCS: https://github.com/neovim/nvim-lspconfig/wiki/Project-local-settings
  local proj_local_settings = require("lsp.plugins.load_proj_settings")
  if proj_local_settings.content[M.local_lspconfig_key] and proj_local_settings.content[M.local_lspconfig_key][client.name] then
    local local_settings = proj_local_settings.content[M.local_lspconfig_key][client.name]
    for key, value in pairs(local_settings) do
      local lsetting = client.config.settings[key] or {}
      client.config.settings[key] = vim.tbl_deep_extend('force', lsetting, value)
    end
  end

  --- semantic token: https://code.visualstudio.com/api/language-extensions/semantic-highlight-guide
  --- nvim-0.9 中禁止 LSP semantic highlight (根据语义的 highlight) 否则 highlight 显示不正确.
  --- VVI: https://github.com/neovim/nvim-lspconfig/issues/2542
  --- DONOT follow `:help vim.lsp.semantic_tokens.start()` place this in on_attach() function.
  --- 设置 "textDocument/semanticTokens" 是否开启
  -- if client.server_capabilities then
  --   -- client.server_capabilities.semanticTokensProvider = nil  -- lsp: semantic token highlight
  --   -- client.server_capabilities.foldingRangeProvider = nil  -- debug: lsp-fold 设置
  -- end

  --- NOTE: 这里不需要 notify change. on_init() 是在 start 之前执行的.
  -- client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })

  --- DEBUG: 用
  if __Debug_Neovim.lsp then
    Notify("LSP Server init: " .. client.name, "DEBUG", {title="LSP"})
  end

  --- VVI: 如果 return false 则 LSP 不启动.
  return true
end

--- NOTE: on_attach - 加载 Key mapping & highlight 设置
---       这里传入的 client 是正在加载的 lsp_client, vim.print(client) 中可以看到 codeActionKind.
M.on_attach = function(client, bufnr)
  --- 加载自定义设置 ---
  --- textDocument/documentHighlight, 显示 references
  if client:supports_method('textDocument/documentHighlight', bufnr) then
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

--- VVI: autostart 不要设置为 false, 会造成很多问题.
--- 需要启动多个 lsp 实例的时候, 如果 autostart 为 false, 则每次都需要手动启动. eg: `:LspStart pyright`
--M.autostart = false  -- 默认为 true

return M
