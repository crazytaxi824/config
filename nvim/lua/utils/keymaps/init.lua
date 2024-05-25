local home_key  = require('utils.keymaps.home_key')
local section   = require('utils.keymaps.jump_to_section')
local save_file = require('utils.keymaps.save_file')
local win       = require('utils.keymaps.jump_to_win')
local set       = require('utils.keymaps.set_register')
local wipe_term = require('utils.keymaps.wipeout_all_term_buf')
local close_buf = require('utils.keymaps.close_other_buf')
local toggle_comment = require('utils.keymaps.toggle_comments_color')

local M = {
  home_key = {
    wrap = home_key.wrap,
    nowrap = home_key.nowrap,
  },
  section = {
    goto_prev = section.prev,
    goto_next = section.next,
  },

  win_choose = win.choose,
  save_file = save_file.save,

  wipe_all_term_bufs = wipe_term.wipeout_all_terminals,
  close_other_bufs = close_buf.delete_all_other_buffers,
  toggle_comments_color = toggle_comment.toggle_comment_color,

  --- set & register keymap
  set = set.keymap_set_and_register,
}

return M
