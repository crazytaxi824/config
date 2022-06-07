--- LSP buffer 专用 keymaps.
--- NOTE: 只在有 LSP 的时候生效. 针对 buffer 设置 keymap.

local M = {}  -- module, 仅提供两个 keymaps 方法.

local opts = { noremap = true }

M.textDocument_keymaps = function(bufnr)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "i", "<F2>", "<C-o><cmd>lua vim.lsp.buf.rename()<CR>", opts)

  -- NOTE: 连续两次 F4 会进入 floating window, q 退出 floating window.
  -- 如果在 handlers.lua 中 overwrite 设置 {focusable = false}, 则不会进入 floating window.
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F4>", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "i", "<F4>", "<C-o><cmd>lua vim.lsp.buf.hover()<CR>", opts)

  --- 自定义的 HoverShort, 在 hover() 基础上只显示 function signature, 不显示 comments.
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-CR>", "", {noremap = true, callback = HoverShort})  -- lua HoverShort()
  vim.api.nvim_buf_set_keymap(bufnr, "i", "<C-CR>", "", {noremap = true, callback = HoverShort})  -- lua HoverShort()

  --- definition, references, implementation.
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F12>", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F24>", "<cmd>lua vim.lsp.buf.references()<CR>", opts)  -- <S-F12>
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F36>", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts) -- <C-F12>

  --- 使用 hover 代替 signature_help, 因为有些 LSP 还不支持 signature_help, eg: typescript, javascript ...
  --vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)

  --- VVI: vim.lsp.handlers 中使用 CompleteDone event 来触发 close hover window.
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", '<Esc><cmd>doautocmd CompleteDone<CR>', opts)
end

M.diagnostic_keymaps = function(bufnr)
  --- jump to diagnostics next error.
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F8>", '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<F20>", '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts) -- <S-F8>

  --- 将 diagnostics error 放入 quickfix list.
  --- 也可以使用 vim.diagnostic.setqflist({open = false}) 禁止打开 quickfix window
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.diagnostic.setqflist()<CR>", opts)

  --- code action
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
end

return M


