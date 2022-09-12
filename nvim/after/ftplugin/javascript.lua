--- javascript -------------------------------------------------------------------------------------
--- node js_file -----------------------------------------------------------------------------------
local function js_run(file)
  _Exec("node " .. file, true)  -- cache cmd for re-run.
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

  _Exec(cmd)
end

--- keymap -----------------------------------------------------------------------------------------
local opt = {noremap = true, buffer = true}
local js_keymaps = {
  --- run current_file ---
  {'n', '<F5>', function() js_run(vim.fn.expand('%')) end, opt, "code: Run"},

  --- jest test ---
  {'n', '<F6>', function() js_jest(vim.fn.expand('%'), false) end, opt, "code: Run Test"},
  {'n', '<F18>', function() js_jest(vim.fn.expand('%'), true) end, opt, "code: Run Test --coverage"},  -- <S-F6>
}

Keymap_set_and_register(js_keymaps)



