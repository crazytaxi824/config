--- python3 ----------------------------------------------------------------------------------------
--- check virtual environment
local function venv()
  --- 项目环境
  local local_venv = '.venv/bin/activate'
  if vim.uv.fs_stat(local_venv) then
    return local_venv
  end

  --- 全局环境
  -- local global_venv = os.getenv("PYTHON_DEFAULT_ENV")
  -- if global_venv and vim.uv.fs_stat(global_venv .. '/bin/activate') then
  --   return global_venv .. '/bin/activate'
  -- end
end

--- file is absolut path
local function py_run(file)
  local py_env = venv()
  if not py_env then
    Notify({"need to create python Virtual Environment first:", "`python3.xx -m venv .venv`"})
    return
  end

  local t = require('utils.my_term.instances').console
  t.cmd = "source " .. py_env .. " && python3 -- " .. file
  t:stop()
  t:run()
end

--- key mapping ------------------------------------------------------------------------------------
--- run current_file ---
vim.keymap.set('n', '<F5>', function() py_run(vim.fn.bufname()) end, {
  buffer = 0,
  desc = "Fn 5: code: Run File",
})



