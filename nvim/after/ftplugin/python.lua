--- python3 ----------------------------------------------------------------------------------------
--- check virtual environment
local function venv()
  --- 项目环境
  local root = vim.fs.root(0, '.venv')
  if not root then
    return
  end

  local local_venv = vim.fs.joinpath(root, '.venv/bin/activate')
  if vim.uv.fs_stat(local_venv) then
    return local_venv
  end
end

--- file is absolut path
local function py_run(file)
  local py_env = venv()
  if not py_env then
    Notify({
      "need to create python Virtual Environment first:",
      '  `python3.xx -m venv .venv`',
      '  `source .venv/bin/activate`',
    })
    return
  end

  local t = require('utils.my_term.instances').console
  t.cmd = "source " .. py_env .. " && python3 --version && python3 " .. file
  t:stop()
  t:run()
end

--- key mapping ------------------------------------------------------------------------------------
--- run current_file ---
vim.keymap.set('n', '<F5>', function() py_run(vim.fn.bufname()) end, {
  buffer = 0,
  desc = "Fn 5: code: Run File",
})



