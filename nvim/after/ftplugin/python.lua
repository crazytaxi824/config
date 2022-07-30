--- python3 ----------------------------------------------------------------------------------------
local function py_run(file)
  _Exec("python3 -- " .. file)
end

--- key mapping ------------------------------------------------------------------------------------
local opt = {noremap = true, buffer = true}

--- run current_file ---
vim.keymap.set('n', '<F5>', function() py_run(vim.fn.expand('%')) end, opt)



