--- LSP buffer 专用 keymaps
--- 只在有 LSP 的时候生效. 针对 buffer 设置 keymap.
--- 主要用在: null-ls.setup() on_attach 和 lspconfig.setup() on_attach 设置中.
--- 当有 client 可以 attach 的时候设置 keymap.
--- null-ls 和 lspconfig 都会用到该 keymaps 设置.
--     lspconfig 会用到 textDocument_keymaps() & diagnostic_keymaps()
--     null-ls   只用到 diagnostic_keymaps()

local hs = require("lsp.plugins.custom_requests.hover_short")

local M = {}  -- module, 仅提供两个 keymaps 方法.

--- for lspconfig only -----------------------------------------------------------------------------
M.textDocument_keymaps = function(bufnr)
  local opts = { silent=true, buffer=bufnr }
  local textdoc_keymaps = {
    {"n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", opts, "LSP: Rename"},
    {"i", "<F2>", "<C-o><cmd>lua vim.lsp.buf.rename()<CR>", opts, "LSP: Rename"},

    --- NOTE: 连续两次 F4 会进入 floating window, q 退出 floating window.
    --- 如果在 handlers.lua 中 overwrite 设置 {focusable = false}, 则不会进入 floating window.
    {"n", "<F4>", "<cmd>lua vim.lsp.buf.hover()<CR>", opts, "LSP: Hover"},
    {"i", "<F4>", "<C-o><cmd>lua vim.lsp.buf.hover()<CR>", opts, "LSP: Hover"},

    --- NOTE: 自定义的 hover_short() request, 在 hover() 基础上只显示 function signature, 不显示 comments.
    --- 只有在 cursor inside 括号 Add(|) 中时才能使用, 主要是为了方便在使用函数的过程中查看函数的入参.
    {"n", "<S-CR>", function() hs.hover_short() end, opts, "LSP: Hover_Short"},
    {"i", "<S-CR>", function() hs.hover_short() end, opts, "LSP: Hover_Short"},

    {"n", "<F12>", "<cmd>lua vim.lsp.buf.definition()<CR>", opts, "LSP: Definition"},
    {"n", "<D-F12>", "<cmd>lua vim.lsp.buf.references()<CR>", opts, "LSP: References"},
    {"n", "<F24>", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts, "LSP: Implementation (Interface)"},  -- <S-F12>

    --- 使用 hover 代替 signature_help, 因为有些 LSP 还不支持 signature_help, eg: typescript, javascript ...
    -- {"n", "K", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts},
  }

  require('utils.keymaps').set(textdoc_keymaps)
end

--- for lspconfig && null-ls, format && diagnostic -------------------------------------------------
M.diagnostic_keymaps = function(bufnr)
  local opts = { silent=true, buffer=bufnr }
  local diag_keymaps = {
    --- jump to diagnostics next error.
    {"n", "<F8>", '<cmd>lua vim.diagnostic.goto_next()<CR>', opts, "diagnostic: goto Next Error"},
    {"n", "<D-F8>", '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts, "diagnostic: goto Prev Error"},

    --- 将 diagnostics error 放入 quickfix list.
    --- 也可以使用 vim.diagnostic.setqflist({open = false}) 禁止打开 quickfix window
    {"n", "<leader>q", "<cmd>lua vim.diagnostic.setqflist()<CR>", opts, 'diagnostic: put errors into quickfix'},

    --- code action, for lspconfig & null-ls.
    {"n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts, 'LSP: Code Action'},
  }

  require('utils.keymaps').set(diag_keymaps, {
    { "<leader>c", buffer = bufnr, group = "Code" },
  })
end

return M
