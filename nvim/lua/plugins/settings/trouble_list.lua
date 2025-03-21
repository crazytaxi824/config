local status_ok, trouble = pcall(require, "trouble")
if not status_ok then
  return
end

trouble.setup({
  auto_preview = true, -- automatically open preview when on an item
  focus = true, -- Focus the window when opened
  keys = {
    -- d = {action=function() end},
  },
  modes = {
    symbols = {
      focus = true,
      win = { position = "right", size={width=40}, },
    },
  },
})

--- keymaps ----------------------------------------------------------------------------------------
local opts = { silent=true }
local tree_keymaps = {
  {'n', '<leader>:',  '<cmd>Trouble symbols toggle focus=false<cr>', opts, 'Symbols (Trouble)'},
  {'n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', opts, 'Diagnostics (Trouble)'},
  {'n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', opts, 'Buffer Diagnostics (Trouble)'},
  {'n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', opts, 'Location List (Trouble)'},
  {'n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', opts, 'Quickfix List (Trouble)'},
  {'n', '<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>', opts, 'Symbols (Trouble)'},
  {'n', '<leader>xl', '<cmd>Trouble lsp toggle<cr>', opts, 'LSP Definitions / references / ... (Trouble)'},
  {'n', '<S-D-F12>',  '<cmd>Trouble lsp toggle<cr>', opts, 'LSP Definitions / references / ... (Trouble)'},
}

require('utils.keymaps').set(tree_keymaps, {
  { "<leader>x", group = "Trouble" },
})

