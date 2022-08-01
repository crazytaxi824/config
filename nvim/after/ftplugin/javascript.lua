--- javascript -------------------------------------------------------------------------------------
--- node js_file -----------------------------------------------------------------------------------
local function js_run(file)
  _Exec("node " .. file)
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

--- run current_file ---
vim.keymap.set('n', '<F5>', function() js_run(vim.fn.expand('%')) end, opt)

vim.keymap.set('n', '<F6>', function() js_jest(vim.fn.expand('%'), false) end, opt)
vim.keymap.set('n', '<F18>', function() js_jest(vim.fn.expand('%'), true) end, opt)  -- <S-F6>



