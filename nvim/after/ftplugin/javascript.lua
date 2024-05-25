--- javascript -------------------------------------------------------------------------------------
local function js_run(file)
  local t = require('utils.my_term.instances').console
  t.cmd = {"node", file}
  t:stop()
  t:run()
end

--- keymap -----------------------------------------------------------------------------------------
local opt = { buffer = 0 }
local js_keymaps = {
  --- run current_file ---
  {'n', '<F5>', function() js_run(vim.fn.bufname()) end, opt, "code: Run File"},
}

require('utils.keymaps').set(js_keymaps)



