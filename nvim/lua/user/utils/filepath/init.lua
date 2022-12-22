local fp_hl = require('user.utils.filepath.highlight')
local fp_jump = require('user.utils.filepath.jump_to_file')

local M = {
  highlight = fp_hl.highlight_filepath,
  n_jump = fp_jump.n_jump_cWORD,
  v_jump = fp_jump.v_jump_selected,
  v_system_open = fp_jump.v_system_open_selected,
}

return M
