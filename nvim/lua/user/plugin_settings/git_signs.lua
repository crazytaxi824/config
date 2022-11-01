local git_signs_ok, git_signs = pcall(require, "gitsigns")
if not git_signs_ok then
  return
end

--- `:help gitsigns`
git_signs.setup({
  --- sign define, 'BOX DRAWINGS HEAVY VERTICAL' & 'UPPER/LOWER ONE EIGHTH BLOCK', 'Left One Quarter Block'
  signs = {
    add    = {hl = 'GitSignsAdd'   , text = '┃', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
    change = {hl = 'GitSignsChange', text = '┃', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},

    --- NOTE: delete sign 应该显示在两行之间, 所以为了适应不同的情况需要设置两个 sign.
    --- delete 和 topdelete 的区别:
    --- 如果上一行被删除则在下一行的 signcolumn 中显示 ▔, 目前只有第一行被删除时用 topdelete.
    --- 如果下一行被删除则在上一行的 signcolumn 中显示 ▁, 通常情况下都是使用 delete, 将 delete sign 显示在上一行.
    topdelete = {hl = 'GitSignsDelete', text = '▔▔', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    delete    = {hl = 'GitSignsDelete', text = '▁▁', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},

    --- NOTE: 在显示 change 的行同时需要显示 delete/topdelete 的情况下, 即需要在同一行的 signcolumn 中显示两个状态.
    changedelete = {hl = 'GitSignsChange', text = '╋━', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
  },
  sign_priority = 10,  -- 默认是 6, vim.diagnostic DiagnosticSignHint priority 默认是 10.
                       -- 这里设置为 10 会覆盖 DiagnosticSignHint(10), 但是 < DiagnosticSignInfo(11).
  update_debounce = 300,  -- 更新频率, 默认 100
  attach_to_untracked = true,  -- 新建文件是否 attach gitsigns

  --- NOTE: 除了 signcolumn 外, 其他不推荐开启. 可以使用 `:Gitsigns preview_hunk` 查看修改记录,
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  --numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  --linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  --word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`, OR `git_signs.toggle_word_diff()`
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
--- signcolumn 中显示的颜色
vim.cmd('hi GitSignsAdd ctermfg=42')
vim.cmd('hi GitSignsChange ctermfg=213')
vim.cmd('hi GitSignsDelete ctermfg=167')

--- inline/virtual_text 中 highlight 添加/修改/删除的字符
vim.cmd('hi GitSignsAddInline ctermfg=233 ctermbg=42')
vim.cmd('hi GitSignsChangeInline ctermfg=233 ctermbg=213')
vim.cmd('hi GitSignsDeleteInline ctermfg=251 ctermbg=167')

--- prev_hunk() 时, 文字颜色
vim.cmd('hi GitSignsAddPreview ctermfg=42')
vim.cmd('hi GitSignsDeletePreview ctermfg=213')
vim.cmd('hi GitSignsDeletePreview ctermfg=240')

--- word_diff() 时, 通过 virtual_text 显示 deleted/changed 行的文字颜色
vim.cmd('hi GitSignsDeleteVirtLn ctermfg=240')

--- current_line_blame 默认不开启.
--vim.cmd('hi GitSignsCurrentLineBlame ctermfg=242')



