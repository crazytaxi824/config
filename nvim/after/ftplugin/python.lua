--- python3 ----------------------------------------------------------------------------------------
local function py_run(file)
  -- require("utils.toggle_term").bottom.run("python3 -- " .. file)
  local t = require('utils.my_term.instances').exec_term
  t.cmd = "python3 -- " .. file
  t:stop()
  t:run()
end

--- key mapping ------------------------------------------------------------------------------------
--- run current_file ---
vim.keymap.set('n', '<F5>', function() py_run(vim.fn.bufname()) end, {
  noremap = true, buffer = true, desc = "code: Run File",
})



