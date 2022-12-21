local fp_hl = require('user.utils.filepath.highlight')
local fp_jump = require('user.utils.filepath.jump_to_file')

local M = {
  hl = fp_hl.highlight_filepath,
  jump = fp_jump.jump_to_file,
}

return M
