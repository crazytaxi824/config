--- python3 ----------------------------------------------------------------------------------------

--- check virtual environment
local function venv(filepath)
  --- 项目环境
  local py_paths = vim.fs.find({'.venv/bin/python3'}, {
    path = vim.fs.dirname(filepath),
    upward = true,
    stop = vim.env.HOME,
    type = "file",
    limit = 1,
  })
  if #py_paths < 1 then
    return
  end
  return py_paths[1]
end

--- file is absolut path
---
--- @param filepath string
local function py_run(filepath)
  local py_path = venv(filepath)
  if not py_path then
    Notify({
      "need to create python Virtual Environment first:",
      '  `python3.xx -m venv .venv` or `uv venv`',
    })
    return
  end

  --- 先相对 HOME, 再相对 cwd. 不在当前 cwd 目录下的文件不会显示绝对路径.
  py_path = vim.fn.fnamemodify(py_path, ':~:.')
  filepath = vim.fn.fnamemodify(filepath, ':~:.')

  local t = require('myplugins.my_term').console()
  t:stop()
  t:run(py_path .. " -- " .. filepath)
end

--- key mapping ------------------------------------------------------------------------------------
--- run current_file ---
vim.keymap.set('n', '<F5>', function() py_run(vim.api.nvim_buf_get_name(0)) end, {
  buffer = 0,
  desc = "Fn 5: code: Run File",
})



