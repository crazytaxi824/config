--- python3 ----------------------------------------------------------------------------------------
local function py_run(file)
  _Exec("python3 -- " .. file, true)  -- cache cmd for re-run.
end

--- key mapping ------------------------------------------------------------------------------------
--- run current_file ---
vim.keymap.set('n', '<F5>', function() py_run(vim.fn.expand('%')) end, {
  noremap = true, buffer = true, desc = "code: Run File",
})



