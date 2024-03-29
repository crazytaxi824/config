--- DOCS: `:help vim.lsp.start_client()`.
--  - capabilities  给 cmp 自动补全提供内容.
--  - on_attach     当 LSP 存在时加载设置 key_mapping, highlight ... 等设置.
--  - on_init = function(lsp_client) -- https://github.com/neovim/nvim-lspconfig/wiki/Project-local-settings
--      可以用来加载 project local settings.
--      修改之后使用 lsp_client.notify("workspace/didChangeConfiguration") 通知 LSP server.

local M = {}

--- NOTE: 停止输入文字的时间超过该数值, 则向 lsp server 发送请求.
--- 如果 "diagnostic.config({update_in_insert = false})", 则该设置应该不生效.
M.flags = { debounce_text_changes = 500 }   --- 默认 150.

--- NOTE: before_init() can be used to debug lsp configs.
-- M.before_init = function(initialize_params, config)
--   vim.print(initialize_params)
--   vim.print(config)
-- end

--- NOTE: on_error() invoked when the client operation throws an error.
M.on_error = function (code)
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

--- https://github.com/neovim/nvim-lspconfig/wiki/Project-local-settings
--- NOTE: LSP settings Hook ------------------------------------------------------------------------
--- 这里是为了能单独给 project 设置 LSP setting.
--- init() runs Before attach().

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

--- NOTE: on_init() run before on_attach(), 可以通过打印看出先后顺序.
M.on_init = function(client)
  --- NOTE: 加载项目本地设置, 覆盖 global settings -----------------------------
  local proj_local_settings = require("lsp._load_proj_settings")
  client.config.settings[client.name] = proj_local_settings.keep_extend(M.local_lspconfig_key, client.name,
    client.config.settings[client.name])

  --- semantic token: https://code.visualstudio.com/api/language-extensions/semantic-highlight-guide
  --- nvim-0.9 中禁止 LSP semantic highlight (根据语义的 highlight) 否则 highlight 显示不正确.
  --- VVI: https://github.com/neovim/nvim-lspconfig/issues/2542
  --- DONOT follow `:help vim.lsp.semantic_tokens.start()` place this in on_attach() function.
  --- 如果需要更改 LSP semantic highlight 颜色, 使用 `:hi @lsp.type...`
  if client.server_capabilities then
    client.server_capabilities.semanticTokensProvider = nil
    -- client.server_capabilities.foldingRangeProvider = nil  -- debug: 下面的 fold 设置
  end

  --- NOTE: notify lsp config is changed.
  client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })

  --- DEBUG: 用
  if __Debug_Neovim.lspconfig then
    Notify("LSP Server init: " .. client.name, "DEBUG", {title="LSP"})
  end

  return true  -- VVI: 如果 return false 则 LSP 不启动.
end

--- NOTE: on_attach - 加载 Key mapping & highlight 设置
---       这里传入的 client 是正在加载的 lsp_client, vim.print(client) 中可以看到 codeActionKind.
M.on_attach = function(client, bufnr)
  --- 加载自定义设置 ---
  --- textDocument/documentHighlight, 显示 references
  require("lsp.lsp_config.doc_hl").fn(client, bufnr)

  --- keymaps ---
  local lsp_keymaps = require("lsp.lsp_keymaps")
  lsp_keymaps.textDocument_keymaps(bufnr)
  lsp_keymaps.diagnostic_keymaps(bufnr)

  --- DEBUG: 用
  if __Debug_Neovim.lspconfig then
    Notify("LSP Server attach: " .. client.name, "DEBUG", {title="LSP"})
  end
end

--- VVI: autostart 不要设置为 false, 会造成很多问题.
--- 需要启动多个 lsp 实例的时候, 如果 autostart 为 false, 则每次都需要手动启动. eg: `:LspStart pyright`
--M.autostart = false  -- 默认为 true

return M
