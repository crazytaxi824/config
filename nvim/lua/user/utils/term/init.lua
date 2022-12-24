local term_status_ok = pcall(require, "toggleterm.terminal")
if not term_status_ok then
  Notify("toggleterm.terminal cannot be loaded", "ERROR")
  return
end

local exec_bot_term = require("user.utils.term.exec_bot_term")
local exec_float_term = require("user.utils.term.exec_float_term")
local bg_term = require("user.utils.term.bg_term")
local instances = require("user.utils.term.instances")

local M = {
  bottom = {
    run      = exec_bot_term.exec,
    run_last = exec_bot_term.exec_last_cmd,
  },

  float = {
    run = exec_float_term.exec,
  },

  bg = {
    spawn = bg_term.bg_term_spawn,
    shutdown_all = bg_term.bg_term_shutdown_all,
  },

  toggle = {
    my_term = instances.toggle_my_term,
    all_terms = instances.toggle_all_my_terms,
  }
}

return M

