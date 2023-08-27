--- javascript -------------------------------------------------------------------------------------
--- node js_file -----------------------------------------------------------------------------------
local function js_run(file)
  -- require("utils.toggle_term").bottom.run("node " .. file)
  local t = require('utils.my_term.instances').exec_term
  t.cmd = "node " .. file
  t:stop()
  t:run()
end

--- jest js_file -----------------------------------------------------------------------------------
local function js_jest(file, coverage)
  -- check xxx.test.js file
  if not string.match(file, ".*%.test%.js$") then
    Notify("not a test file.", "ERROR")
    return
  end

  local cmd = ''
  if coverage then
    cmd = "jest --coverage " .. file
  else
    cmd = "jest " .. file
  end

  -- require("utils.toggle_term").bottom.run(cmd)
  local t = require('utils.my_term.instances').exec_term
  t.cmd = cmd
  t:stop()
  t:run()
end

--- keymap -----------------------------------------------------------------------------------------
local opt = {noremap = true, buffer = true}
local js_keymaps = {
  --- run current_file ---
  {'n', '<F5>', function() js_run(vim.fn.bufname()) end, opt, "code: Run File"},

  --- jest test ---
  {'n', '<F6>', function() js_jest(vim.fn.bufname(), false) end, opt, "code: Run Test"},
  {'n', '<F18>', function() js_jest(vim.fn.bufname(), true) end, opt, "code: Run Test --coverage"},  -- <S-F6>
}

require('utils.keymaps').set(js_keymaps)



