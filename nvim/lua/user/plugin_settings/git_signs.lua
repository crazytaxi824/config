local git_signs_ok, git_signs = pcall(require, "gitsigns")
if not git_signs_ok then
  return
end

--- `:help gitsigns`
git_signs.setup({
  sign_priority = 11,  -- 默认是 6, vim.diagnostic sign priority 默认是 10.
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  --- NOTE: 以下不推荐默认开启. 可以使用 `:Gitsigns preview_hunk` 查看修改记录, 使用 `:Gitsigns next/prev_hunk` 跳转.
  --numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  --linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  --word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  --show_deleted  = false, -- Toggle with `:Gitsigns toggle_deleted`

  preview_config = {
    --- Options passed to nvim_open_win
    border = {"▄","▄","▄","█","▀","▀","▀","█"},
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },

  --- keymaps
  on_attach = function(bufnr)
    local opt = { noremap = true, silent = true, buffer=bufnr}
    local gitsigns_keymaps = {
      {'n', '<leader>gP', git_signs.preview_hunk, opt, "git: Preview Hunk"},
      {'n', '<leader>gn', git_signs.next_hunk, opt, "git: Jump to Next Hunk"},
      {'n', '<leader>gp', git_signs.prev_hunk, opt, "git: Jump to Prev Hunk"},
      {'n', '<leader>gd', function()
        git_signs.toggle_deleted()
        git_signs.toggle_word_diff()
      end, opt, "git: Toggle Show Diff Line & Word"},
    }

    Keymap_set_and_register(gitsigns_keymaps, {
      key_desc = {
        g = {name = "Git"}, --- NOTE: 需要和 nvim-tree 中的设置相同.
      },
      opts = {mode='n', prefix='<leader>', buffer=bufnr}
    })
  end,
})

--- highlights -------------------------------------------------------------------------------------
vim.cmd('hi GitSignsCurrentLineBlame ctermfg=242')  -- current_line_blame 默认不开启.

vim.cmd('hi GitSignsDeleteVirtLn ctermfg=240')  -- 文件中 virtual_text 颜色.
--vim.cmd('hi GitSignsDelete ctermfg=242')  -- delete signcolumn 中 _ color.
--vim.cmd('hi GitSignsDeletePreview ctermfg=242')  -- preview_hunk 中 deleted line 的颜色.



