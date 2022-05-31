--- NOTE: handlers.lua 主要返回一个类型实例, 带 on_attach, capabilities 属性.
--  on_attach 当 LSP 存在时加载设置 key mapping, highlight ... 等设置.
--  capabilities 给 cmp 自动补全提供内容.
local M = {}

--- work like Same_ID, `:help vim.lsp.buf.document_highlight()`
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

--- define Key mapping, NOTE: 只在有 LSP 的时候生效, LSP 针对 buffer 加载 ---
local function lsp_keymaps(bufnr)
  local opts = { noremap = true }
  --- <S-F12> 在 neovim 中是 <F24>, <C-F12> 是 <F36>, <C-S-F12> 是 <F48>. 其他组合键都可以通过 insert 模式打印出来.
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "i", "<F2>", "<C-o><cmd>lua vim.lsp.buf.rename()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F4>", "<cmd>lua vim.lsp.buf.hover()<CR>", opts) -- NOTE: 连续两次 F4 会进入 floating window, q 退出 floating window.
  vim.api.nvim_buf_set_keymap(bufnr, "i", "<F4>", "<C-o><cmd>lua vim.lsp.buf.hover()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-CR>", "", {noremap = true, callback = HoverShort})  -- lua HoverShort()
  vim.api.nvim_buf_set_keymap(bufnr, "i", "<C-CR>", "", {noremap = true, callback = HoverShort})  -- lua HoverShort()
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F12>", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F24>", "<cmd>lua vim.lsp.buf.references()<CR>", opts)  -- <S-F12>
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F36>", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts) -- <C-F12>
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F8>", '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F20>", '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts) -- <S-F8>
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  --vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)  -- 可以使用 hover 代替.

  --- https://github.com/neovim/neovim/pull/16057
  --- 也可以使用 vim.diagnostic.setqflist({open = false}) 禁止打开 quickfix window
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.diagnostic.setqflist()<CR>", opts)

  --- VVI: vim.lsp.handlers 中使用 CompleteDone event 来触发 close hover window.
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", '<Esc><cmd>doautocmd CompleteDone<CR>', opts)
end

--- NOTE: on_attach - 加载 Key mapping & highlight 设置 --------------------------------------------
---       这里传入的 client 是正在加载的 lsp_client, vim.inspect(client) 中可以看到 codeActionKind.
M.on_attach = function(client, bufnr)
  --- VVI: 禁止使用 LSP 的 formatting 功能, 在 null-ls 中使用其他 format 工具
  --- `:lua print(vim.inspect(vim.lsp.buf_get_clients()))` 查看启动的 lsp 和所有相关设置
  --- ts, js, html, json, jsonc ... 使用 'prettier'
  --- lua 使用 'stylua'
  local disable_format = {"tsserver", "html", "sumneko_lua", "jsonls"}
  for _, server in ipairs(disable_format) do
    if client.name == server then
      client.resolved_capabilities.document_formatting = false
    end
  end

  --- 加载 Key mapping & highlight 设置
  lsp_keymaps(bufnr)
  lsp_highlight(client)

  --- NOTIFY: 加载某个 lsp 的时候通知 --- {{{
  -- local notify_status_ok, notify = pcall(require, "notify")
  -- if not notify_status_ok then
  --   return
  -- end
  -- notify("LSP loaded: " .. client.name, "INFO", {title = {"LSP", "handlers.lua"}, timeout=2000})
  -- -- }}}
end

--- NOTE: capabilities - Provides content to "hrsh7th/cmp-nvim-lsp" Completion ---------------------
local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
  return
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

--- https://github.com/neovim/nvim-lspconfig/wiki/Project-local-settings
--- NOTE: LSP settings Hook, 不是必要设置 ---------------------------------------------------------
--- 这里是为了能单独给 project 设置 LSP setting
M.on_init = function(client)
  --- read project root directory '.nvim/lsp.lua' file if it exists.
  if vim.fn.filereadable('.nvim/lsp.lua') == 0 then
    --print(".nvim/lsp.lua file is not exist.")
    return true
  end

  --print(".nvim/lsp.lua file exists.")
  local proj = dofile('.nvim/lsp.lua')  -- execute lua file, and get return value.

  --- overwrite LSP settings.
  --- lua print(vim.inspect(vim.tbl_values(vim.lsp.buf_get_clients())))
  client.config.settings = vim.tbl_deep_extend('force', client.config.settings, proj.settings)

  -- VVI: tell LSP configs are changed.
  client.notify("workspace/didChangeConfiguration")

  return true
end

return M



