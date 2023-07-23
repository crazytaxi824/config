--- python3 ----------------------------------------------------------------------------------------
local function py_run(file)
  -- require("user.utils.toggle_term").bottom.run("python3 -- " .. file)
  local t = require('user.utils.m_terms').exec_term
  t.cmd = "python3 -- " .. file
  t:stop()
  t:run()
end

--- key mapping ------------------------------------------------------------------------------------
--- run current_file ---
vim.keymap.set('n', '<F5>', function() py_run(vim.fn.expand('%')) end, {
  noremap = true, buffer = true, desc = "code: Run File",
})



