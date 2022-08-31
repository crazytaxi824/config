--- LSP buffer 专用 keymaps.
--- NOTE: 只在有 LSP 的时候生效. 针对 buffer 设置 keymap.
--- 主要用在: null-ls.setup() on_attach 和 lspconfig.setup() on_attach 设置中. 当有 client 可以 attach 的时候设置 keymap.
--- null-ls 和 lspconfig 都会用到该 keymaps 设置.
--     lspconfig 会用到 textDocument_keymaps() & diagnostic_keymaps()
--     null-ls   只用到 diagnostic_keymaps()

local M = {}  -- module, 仅提供两个 keymaps 方法.

local opts = { noremap = true }

--- for lspconfig only -----------------------------------------------------------------------------
M.textDocument_keymaps = function(bufnr)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "i", "<F2>", "<C-o><cmd>lua vim.lsp.buf.rename()<CR>", opts)

  -- NOTE: 连续两次 F4 会进入 floating window, q 退出 floating window.
  -- 如果在 handlers.lua 中 overwrite 设置 {focusable = false}, 则不会进入 floating window.
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F4>", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "i", "<F4>", "<C-o><cmd>lua vim.lsp.buf.hover()<CR>", opts)

  --- 自定义的 hover_short() request, 在 hover() 基础上只显示 function signature, 不显示 comments.
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<S-CR>", "", {noremap = true,
    callback = require("user.lsp.lsp_config.user_lsp_request").hover_short})
  vim.api.nvim_buf_set_keymap(bufnr, "i", "<S-CR>", "", {noremap = true,
    callback = require("user.lsp.lsp_config.user_lsp_request").hover_short})
  --vim.api.nvim_buf_set_keymap(bufnr, "i", ",",
  --  ",<cmd>lua require('user.lsp.lsp_config.user_lsp_request').hover_short()<CR>",
  --  {noremap = true})

  --- definition, references, implementation.
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F12>", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F24>", "<cmd>lua vim.lsp.buf.references()<CR>", opts)  -- <S-F12>
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F36>", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts) -- <C-F12>

  --- 使用 hover 代替 signature_help, 因为有些 LSP 还不支持 signature_help, eg: typescript, javascript ...
  --vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)

  --- VVI: vim.lsp.handlers 中使用 User event 来触发 close hover window.
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", '<Esc><cmd>doautocmd User<CR>', opts)
end

--- for lspconfig && null-ls, format && diagnostic -------------------------------------------------
M.diagnostic_keymaps = function(bufnr)
  --- jump to diagnostics next error.
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F8>", '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F20>", '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts) -- <S-F8>

  --- 将 diagnostics error 放入 quickfix list.
  --- 也可以使用 vim.diagnostic.setqflist({open = false}) 禁止打开 quickfix window
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.diagnostic.setqflist()<CR>", opts)

  --- code action
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)

  --- which-key ---
  local status_ok, which_key = pcall(require, "which-key")
  if not status_ok then
    return
  end

  --- set key description manually ---
  which_key.register({
    c = {
      name = "Code",
      a = "LSP - Code Action",
    }
  },{mode='n',prefix='<leader>', buffer=bufnr})
end

return M


