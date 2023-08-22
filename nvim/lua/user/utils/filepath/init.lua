local fp_hl = require('user.utils.filepath.highlight')
local fp_jump = require('user.utils.filepath.jump_to_file')

local M = {
  n_jump = fp_jump.n_jump_cWORD,
  v_jump = fp_jump.v_jump_selected,
  v_system_open = fp_jump.v_system_open_selected,
}

M.setup = function(bufnr)
  --- autocmd highlight filepath under cursor
  vim.api.nvim_create_autocmd({"CursorHold"}, {
    buffer = bufnr,
    callback = function(params)
      fp_hl.highlight_filepath()
    end
  })

  --- clear highlight when cursor leave buffer.
  vim.api.nvim_create_autocmd({"BufLeave"}, {
    buffer = bufnr,
    callback = function(params)
      fp_hl.highlight_clear_cache()
    end
  })

  --- set keymap jump to file/dir
  local opts = { buffer = bufnr, noremap = true, silent = true, desc = "filepath: Jump to file" }
  vim.keymap.set('n', '<S-CR>', function() fp_jump.n_jump_cWORD() end, opts)
end

return M
