--- python3 ----------------------------------------------------------------------------------------
--- check virtual environment
local function venv()
  --- 项目环境
  local py_paths = vim.fs.find({'.venv/bin/python3'}, {
    upward = true,
    path = vim.api.nvim_buf_get_name(0),
    stop = vim.env.HOME,
    type = "file",
  })
  if #py_paths < 1 then
    return
  end
  return py_paths[1]
end

--- file is absolut path
local function py_run(file)
  local py_path = venv()
  if not py_path then
    Notify({
      "need to create python Virtual Environment first:",
      '  `python3.xx -m venv .venv` or `uv venv`',
    })
    return
  end

  --- 先相对 HOME, 再相对 cwd.
  py_path = vim.fn.fnamemodify(py_path, ':~:.')
  file = vim.fn.fnamemodify(file, ':~:.')

  local t = require('utils.my_term.instances').console
  t.cmd = py_path .. " -- " .. file
  t:stop()
  t:run()
end

--- key mapping ------------------------------------------------------------------------------------
--- run current_file ---
vim.keymap.set('n', '<F5>', function() py_run(vim.fn.bufname()) end, {
  buffer = 0,
  desc = "Fn 5: code: Run File",
})



