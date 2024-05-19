local fp_hl = require('utils.filepath.highlight')
local fp_jump = require('utils.filepath.jump_to_file')

local M = {
  n_jump = fp_jump.n_jump_cWORD,
  v_jump = fp_jump.v_jump_selected,
}

M.setup = function(bufnr)
  local g_id = vim.api.nvim_create_augroup('my_filepath_highlight_' .. bufnr, {clear=true})

  --- autocmd highlight filepath under cursor
  vim.api.nvim_create_autocmd({"CursorHold"}, {
    group = g_id,
    buffer = bufnr,
    callback = function(params)
      fp_hl.highlight_filepath()
    end,
    desc = "highlight filepath under cursor",
  })

  --- clear highlight when cursor leave buffer.
  vim.api.nvim_create_autocmd({"BufLeave"}, {
    group = g_id,
    buffer = bufnr,
    callback = function(params)
      fp_hl.highlight_clear_cache()
    end,
    desc = "clear highlight when cursor leave buffer",
  })

  --- set keymap jump to file/dir
  local opts = { buffer = bufnr, noremap = true, silent = true, desc = "filepath: Jump to file" }
  vim.keymap.set('n', '<S-CR>', function() fp_jump.n_jump_cWORD() end, opts)
end

return M
