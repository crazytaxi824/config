--- python3 ----------------------------------------------------------------------------------------
--- check virtual environment
local function venv()
  --- 项目环境
  local py_venv = vim.fs.root(0, '.venv')
  if not py_venv then
    return
  end

  if vim.uv.fs_stat(vim.fs.joinpath(py_venv, '.venv/bin/activate')) then
    return py_venv
  end
end

--- file is absolut path
local function py_run(file)
  local py_venv = venv()
  if not py_venv then
    Notify({
      "need to create python Virtual Environment first:",
      '  `python3.xx -m venv .venv` or `uv venv`',
      '  `source .venv/bin/activate`',
    })
    return
  end

  local py_path = vim.fs.joinpath(py_venv, '.venv/bin')

  local t = require('utils.my_term.instances').console
  -- t.cmd = "which python3 && python3 --version && python3 " .. file  -- DEBUG
  t.cmd = "python3 " .. file
  t.env = { PATH = py_path..":$PATH" }  -- same as 'source .venv/bin/activate'
  t:stop()
  t:run()
end

--- key mapping ------------------------------------------------------------------------------------
--- run current_file ---
vim.keymap.set('n', '<F5>', function() py_run(vim.fn.bufname()) end, {
  buffer = 0,
  desc = "Fn 5: code: Run File",
})



