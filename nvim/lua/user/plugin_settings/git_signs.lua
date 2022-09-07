local git_signs_ok, git_signs = pcall(require, "gitsigns")
if not git_signs_ok then
  return
end

--- `:help gitsigns`
git_signs.setup({
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  --numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  --linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  --word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  preview_config = {
    --- Options passed to nvim_open_win
    border = {"▄","▄","▄","█","▀","▀","▀","█"},
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
})

--- highlights ---
vim.cmd('hi GitSignsCurrentLineBlame ctermfg=242')  -- current_line_blame 默认不开启.

--- keymaps ---
local opt = { noremap = true, silent = true }
local gitsigns_keymaps = {
  {'n', '<leader>g', '<cmd>Gitsigns toggle_signs<CR>', opt, "git: Toggle SignColumn"}
}

Keymap_set_and_register(gitsigns_keymaps)



