local save_file = require('utils.keymaps.save_file')
local goto_win  = require('utils.keymaps.jump_to_win')
local set       = require('utils.keymaps.set_register')
local wipe_term = require('utils.keymaps.wipeout_all_term_buf')
local close_buf = require('utils.keymaps.close_other_buf')
local toggle_comment = require('utils.keymaps.toggle_comments_color')
local close_wins = require('utils.keymaps.close_all_popup_win')

local M = {
  home = require('utils.keymaps.home'),
  page = require('utils.keymaps.page'),
  shift = require('utils.keymaps.shift'),
  section = require('utils.keymaps.jump_to_section'),
  move_char = require('utils.keymaps.move_next_char'),

  close_popup_wins = close_wins.close_pop_wins,
  win_choose = goto_win.choose,
  save_file = save_file.save,

  wipe_all_term_bufs = wipe_term.wipeout_all_terminals,
  close_other_bufs = close_buf.delete_all_other_buffers,
  toggle_comments_color = toggle_comment.toggle_comment_color,

  --- set & register keymap
  set = set.keymap_set_and_register,
}

return M
