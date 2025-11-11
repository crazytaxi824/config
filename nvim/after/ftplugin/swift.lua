local function swift_run(file)
  --- 先相对 HOME, 再相对 cwd. (absolut filepath)
  file = vim.fn.fnamemodify(file, ':~:.')

  local t = require('utils.my_term.instances').console
  t.cmd = "swift -- " .. file
  t:stop()
  t:run()
end

--- key mapping ------------------------------------------------------------------------------------
--- run current_file ---
vim.keymap.set('n', '<F5>', function() swift_run(vim.api.nvim_buf_get_name(0)) end, {
  buffer = 0,
  desc = "Fn 5: code: Run File",
})
