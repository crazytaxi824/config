local git_signs_ok, git_signs = pcall(require, "gitsigns")
if not git_signs_ok then
  return
end

-- keymaps ---------------------------------------------------------------------------------------- {{{
local function gitsigns_hunk_actions()
  local actions = git_signs.get_actions()
  vim.ui.select(vim.tbl_keys(actions), {
    prompt = 'gitsigns actions:',
  }, function(choice)
    if choice then
      actions[choice]()
    end
  end)
end

local function gs_keymaps(bufnr)
  local opt = { silent = true, buffer=bufnr }
  local gitsigns_keymaps = {
    {'n', '<leader>gn', function() git_signs.nav_hunk("next", {target="all"}) end, opt, "git: Jump to Next Hunk"},
    {'n', '<leader>gp', function() git_signs.nav_hunk("prev", {target="all"}) end, opt, "git: Jump to Prev Hunk"},
    {'n', '<leader>gb', function() git_signs.blame_line{full=true} end, opt, "git: Blame"},
    {'n', '<leader>gB', function() git_signs.toggle_current_line_blame() end, opt, "git: Toggle Blame line"},
    {'n', '<leader>gR', function() git_signs.reset_buffer() end, opt, "git: Reset current buffer"},
    {'n', '<leader>gs', function() git_signs.toggle_signs() end, opt, "git: Toggle sings"},
    {'n', '<leader>gg', function() gitsigns_hunk_actions() end, opt, "git: Actions for Hunk"},
    {'n', '<leader>gd', function() git_signs.preview_hunk_inline() end, opt, "git: Preview hunk"},
    {'n', '<leader>gf', function()
      vim.cmd.tabnew({ args = { vim.fn.bufname() }})  -- open current file in new Tab.
      git_signs.diffthis('~')  -- diff this file with old comment.
    end, opt, "git: Diff file"},
  }

  require('utils.keymaps').set(gitsigns_keymaps, {
    { "<leader>g", buffer = bufnr, group = "Git" }, -- 需要和 nvim-tree 中的设置相同.
  })
end
-- }}}

-- signs ------------------------------------------------------------------------------------------ {{{
-- text font: 'BOX DRAWINGS HEAVY VERTICAL', 'UPPER/LOWER ONE EIGHTH BLOCK', 'Left One Quarter Block'
local gs_signs = {
  add    = {text = '┃'},
  change = {text = '┃'},

  -- NOTE: delete sign 应该显示在两行之间, 所以为了适应不同的情况需要设置两个 sign.
  -- delete 和 topdelete 的区别:
  -- 如果上一行被删除则在下一行的 signcolumn 中显示 ▔, 目前只有第一行被删除时用 topdelete.
  -- 如果下一行被删除则在上一行的 signcolumn 中显示 ▁, 通常情况下都是使用 delete, 将 delete sign 显示在上一行.
  topdelete = {text = '▔▔'},
  delete    = {text = '▁▁'},

  -- NOTE: 在显示 change 的行同时需要显示 delete/topdelete 的情况下, 即需要在同一行的 signcolumn 中显示两个状态.
  changedelete = {text = '╋━'},
  untracked    = {text = '┆' },
}
-- }}}

-- `:help gitsigns`
git_signs.setup({
  signs = gs_signs,
  signs_staged = gs_signs,

  sign_priority = 6,  -- 默认是 6, vim.diagnostic DiagnosticSignHint priority 默认是 10.
                      -- 这里设置为 10 会覆盖 DiagnosticSignHint(10), 但是不会覆盖 DiagnosticSignInfo(11).

  update_debounce = 300,  -- 更新频率, 默认 100
  --attach_to_untracked = false,  -- 是否 attach gitsigns 到新建文件

  -- `:help current_line_blame_formatter`, check placeholder
  current_line_blame_formatter = '   [<abbrev_sha>], git blame: [<author>], <author_time:%d-%m-%Y> - <summary>',

  -- Options passed to 'vim.api.nvim_open_win()'
  preview_config = {
    border = Nerd_icons.border,
  },

  -- keymaps, `:help gitsigns-functions`
  on_attach = gs_keymaps,
})

-- highlights ------------------------------------------------------------------------------------- {{{
-- `:help gitsigns-highlight-groups`
vim.api.nvim_set_hl(0, 'GitSignsAdd',    {ctermfg=Colors.green.c, fg=Colors.green.g})
vim.api.nvim_set_hl(0, 'GitSignsChange', {ctermfg=Colors.magenta.c, fg=Colors.magenta.g})
vim.api.nvim_set_hl(0, 'GitSignsDelete', {ctermfg=Colors.red.c, fg=Colors.red.g})

-- inline/virtual_text 中 highlight 添加/修改/删除的字符
vim.api.nvim_set_hl(0, 'GitSignsAddInline',    {
  ctermfg=Colors.black.c, fg=Colors.black.g,
  ctermbg=Colors.green.c, bg=Colors.green.g,
})
vim.api.nvim_set_hl(0, 'GitSignsChangeInline', {
  ctermfg=Colors.black.c, fg=Colors.black.g,
  ctermbg=Colors.magenta.c, bg=Colors.magenta.g,
})
vim.api.nvim_set_hl(0, 'GitSignsDeleteInline', {
  ctermfg=Colors.white.c, fg=Colors.white.g,
  ctermbg=Colors.red.c, bg=Colors.red.g,
})

-- prev_hunk() 时, 文字颜色. preview hunk 没有 'GitSignsChangePreview' 设置.
vim.api.nvim_set_hl(0, 'GitSignsAddPreview',    {ctermfg=Colors.green.c, fg=Colors.green.g})
vim.api.nvim_set_hl(0, 'GitSignsDeletePreview', {ctermfg=Colors.g240.c, fg=Colors.g240.g})

-- word_diff() 时, 通过 virtual_text 显示 deleted/changed 行的文字颜色
vim.api.nvim_set_hl(0, 'GitSignsDeleteVirtLn', {ctermfg=Colors.g240.c, fg=Colors.g240.g})

-- current_line_blame 默认不开启.
vim.api.nvim_set_hl(0, 'GitSignsCurrentLineBlame', {ctermfg=Colors.g246.c, fg=Colors.g246.g})

-- }}}

