local M = {
  home = require('utils.keymaps.home'),
  page = require('utils.keymaps.page'),
  shift = require('utils.keymaps.shift'),
  section = require('utils.keymaps.jump_to_section'),
  move_char = require('utils.keymaps.move_char'),

  close_popup_wins = require('utils.keymaps.close_all_popup_win').close_pop_wins,
  win_choose = require('utils.keymaps.jump_to_win').choose,
  save_file = require('utils.keymaps.save_file').save,

  wipe_all_term_bufs = require('utils.keymaps.wipeout_all_term_buf').wipeout_all_terminals,
  close_other_bufs = require('utils.keymaps.close_other_buf').delete_all_other_buffers,
  toggle_comments_color = require('utils.keymaps.toggle_comments_color').toggle_comment_color,

  -- set & register keymap
  set = require('utils.keymaps.set_register').keymap_set_and_register,
}

return M
