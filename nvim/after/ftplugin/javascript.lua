--- javascript -------------------------------------------------------------------------------------

--- `node file.js`
---
--- @param filepath string
local function js_run(filepath)
  local t = require('utils.my_term').console()
  t:stop()
  t:run({ "node", filepath })
end

--- keymap -----------------------------------------------------------------------------------------
local opt = { buffer = 0 }
local js_keymaps = {
  --- run current_file ---
  {'n', '<F5>', function() js_run(vim.fn.bufname()) end, opt, "Fn 5: code: Run File"},
}

require('utils.keymaps').set(js_keymaps)



