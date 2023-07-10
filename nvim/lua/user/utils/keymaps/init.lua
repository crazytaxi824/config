local hl_search = require('user.utils.keymaps.hl_search')
local home_key  = require('user.utils.keymaps.home_key')
local section   = require('user.utils.keymaps.jump_to_section')
local save_file = require('user.utils.keymaps.save_file')
local win       = require('user.utils.keymaps.jump_to_win')
local set       = require('user.utils.keymaps.set_register')

local M = {
  hl_search = {
    normal = hl_search.hl_search,
    visual = hl_search.hl_visual_search,
    delete = hl_search.delete,
  },
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

  --- set & register keymap
  set = set.keymap_set_and_register,
}

return M
