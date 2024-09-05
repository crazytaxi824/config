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
    {"n", "<F2>", function() vim.lsp.buf.rename() end, opts, "Fn: LSP: Rename"},
    {"i", "<F2>", function() vim.lsp.buf.rename() end, opts, "Fn: LSP: Rename"},

    --- NOTE: 连续两次 F4 会进入 floating window, q 退出 floating window.
    --- 如果在 handlers.lua 中 overwrite 设置 {focusable = false}, 则不会进入 floating window.
    {"n", "<F4>", function() vim.lsp.buf.hover() end, opts, "Fn: LSP: Hover"},
    {"i", "<F4>", function() vim.lsp.buf.hover() end, opts, "Fn: LSP: Hover"},

    --- NOTE: 自定义的 hover_short() request, 在 hover() 基础上只显示 function signature, 不显示 comments.
    --- 只有在 cursor inside 括号 Add(|) 中时才能使用, 主要是为了方便在使用函数的过程中查看函数的入参.
    {"n", "<S-CR>", function() hs.hover_short() end, opts, "Fn: LSP: Hover_Short"},
    {"i", "<S-CR>", function() hs.hover_short() end, opts, "Fn: LSP: Hover_Short"},

    {"n", "<F12>",   function() vim.lsp.buf.definition() end, opts, "Fn: LSP: Definition"},
    {"n", "<D-F12>", function() vim.lsp.buf.references() end, opts, "Fn: LSP: References"},
    {"n", "<F24>",   function() vim.lsp.buf.implementation() end, opts, "Fn: LSP: Implementation (Interface)"},  -- <S-F12>

    --- 使用 hover 代替 signature_help, 因为有些 LSP 还不支持 signature_help, eg: typescript, javascript ...
    -- {"n", "K", function() vim.lsp.buf.signature_help() end, opts},
  }

  require('utils.keymaps').set(textdoc_keymaps)
end

--- for lspconfig && null-ls, format && diagnostic -------------------------------------------------
local diagnostic_keymaps_loaded = {}

M.diagnostic_keymaps = function(bufnr)
  if diagnostic_keymaps_loaded[bufnr] then
    return
  end

  local opts = { silent=true, buffer=bufnr }
  local diag_keymaps = {
    --- jump to diagnostics next error.
    {"n", "<F8>",   function() vim.diagnostic.goto_next() end, opts, "Fn: diagnostic: goto Next Error"},
    {"n", "<D-F8>", function() vim.diagnostic.goto_prev() end, opts, "Fn: diagnostic: goto Prev Error"},

    --- 将 diagnostics error 放入 quickfix list.
    --- 也可以使用 vim.diagnostic.setqflist({open = false}) 禁止打开 quickfix window
    {"n", "<leader>q", function() vim.diagnostic.setqflist() end, opts, 'diagnostic: put errors into quickfix'},

    --- code action, for lspconfig & null-ls.
    {"n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts, 'LSP: Code Action'},
  }

  require('utils.keymaps').set(diag_keymaps, {
    { "<leader>c", buffer = bufnr, group = "Code" },
  })

  diagnostic_keymaps_loaded[bufnr] = true
end

return M
