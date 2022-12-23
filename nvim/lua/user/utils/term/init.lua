local term_status_ok = pcall(require, "toggleterm.terminal")
if not term_status_ok then
  Notify("toggleterm.terminal cannot be loaded", "ERROR")
  return
end

local exec_bot_term = require("user.utils.term.exec_bot_term")
local exec_float_term = require("user.utils.term.exec_float_term")
local goto_winid = require("user.utils.term.goto_winid")
local cmd_term = require("user.utils.term.cmd_term")
local bg_term = require("user.utils.term.bg_term")

local M = {
  instance = {
    bot_exec = exec_bot_term.exec_bot_term,
    float_exec = exec_float_term.exec_float_term,

    h1 = cmd_term.h1_term,
    h2 = cmd_term.h2_term,
    h3 = cmd_term.h3_term,
    h4 = cmd_term.h4_term,
    h5 = cmd_term.h5_term,
    h6 = cmd_term.h6_term,
    v7 = cmd_term.v7_term,
    v8 = cmd_term.v8_term,
    v9 = cmd_term.v9_term,

    node_float = cmd_term.node_term,
    python_float = cmd_term.python_term,
  },

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

  goto_winid = goto_winid.fn,
}

return M

