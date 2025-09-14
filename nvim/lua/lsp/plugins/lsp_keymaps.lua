--- LSP buffer 专用 keymaps
--- 只在有 LSP 的时候生效. 针对 buffer 设置 keymap.
--- 主要用在: null-ls.setup() on_attach 和 lspconfig.setup() on_attach 设置中.
--- 当有 client 可以 attach 的时候设置 keymap.
--- null-ls 和 lspconfig 都会用到该 keymaps 设置.
--     lspconfig 会用到 textDocument_keymaps() & diagnostic_keymaps()
--     null-ls   只用到 diagnostic_keymaps()

local hs = require("lsp.plugins.custom_requests.hover_short")

local M = {}  -- module, 仅提供两个 keymaps 方法.

local hover_opts = {
  --- `:help vim.lsp.util.open_floating_preview()`
  --- `:help vim.lsp.util.make_floating_popup_options()`
  --- `:help nvim_open_win()`
  focusable = false,  -- false: 重复执行 vim.lsp.buf.hover() 时不会进入 floating window.
  border = Nerd_icons.border,
  anchor_bias = 'above',  -- popup window 优先向上弹出
  max_width = math.floor(vim.go.columns * 0.8),

  --- events, to trigger close floating window
  --- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/util.lua
  close_events = {"WinScrolled"},  -- 默认 {"CursorMoved", "CursorMovedI", "InsertCharPre"}

  --- 有些 linter 类型的 lsp 不返回任何 result, 导致 handler 报错.
  silent = true,
}

--- for lspconfig only -----------------------------------------------------------------------------
M.textDocument_keymaps = function(bufnr)
  local opts = { silent=true, buffer=bufnr }
  local textdoc_keymaps = {
    {"n", "<F2>", function() vim.lsp.buf.rename() end, opts, "Fn 2: LSP: Rename"},
    {"i", "<F2>", function() vim.lsp.buf.rename() end, opts, "Fn 2: LSP: Rename"},

    --- NOTE: 连续两次 F4 会进入 floating window, q 退出 floating window.
    --- 如果在 handlers.lua 中 overwrite 设置 {focusable = false}, 则不会进入 floating window.
    {"n", "<F4>", function() vim.lsp.buf.hover(hover_opts) end, opts, "Fn 4: LSP: Hover"},
    {"i", "<F4>", function() vim.lsp.buf.hover(hover_opts) end, opts, "Fn 4: LSP: Hover"},

    --- NOTE: 自定义的 hover_short() request, 在 hover() 基础上只显示 function signature, 不显示 comments.
    --- 只有在 cursor inside 括号 Add(|) 中时才能使用, 主要是为了方便在使用函数的过程中查看函数的入参.
    {"n", "<S-CR>", function() hs.hover_short() end, opts, "Fn: LSP: Hover_Short"},
    {"i", "<S-CR>", function() hs.hover_short() end, opts, "Fn: LSP: Hover_Short"},

    {"n", "<F12>",   function() vim.lsp.buf.definition() end, opts, "Fn12: LSP: Definition"},
    {"n", "<D-F12>", function() vim.lsp.buf.references() end, opts, "Fn12: LSP: References"},
    {"n", "<F24>",   function() vim.lsp.buf.implementation() end, opts, "Fn12: LSP: Implementation (Interface)"},  -- <S-F12>
  }

  require('utils.keymaps').set(textdoc_keymaps)
end

--- for lspconfig && null-ls, format && diagnostic -------------------------------------------------
M.diagnostic_keymaps = function(bufnr)
  local opts = { silent=true, buffer=bufnr }
  local diag_keymaps = {
    --- jump to diagnostics next error.
    {"n", "<F8>",   function() vim.diagnostic.jump({count=1, float=true}) end, opts, "Fn 8: diagnostic: goto Next Error"},
    {"n", "<D-F8>", function() vim.diagnostic.jump({count=-1, float=true}) end, opts, "Fn 8: diagnostic: goto Prev Error"},

    --- 将 diagnostics error 放入 quickfix list.
    --- 也可以使用 vim.diagnostic.setqflist({open = false}) 禁止打开 quickfix window
    {"n", "<leader>q", function() vim.diagnostic.setqflist() end, opts, 'diagnostic: put errors into quickfix'},

    --- code action, for lspconfig & null-ls.
    {"n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts, 'LSP: Code Action'},
  }

  require('utils.keymaps').set(diag_keymaps)
end

return M
