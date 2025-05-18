--- `:help dap-adapter`
local dap_status_ok, dap = pcall(require, "dap")
if not dap_status_ok then
  return
end

--- NOTE: Debug adapters & configurations settings
--- Some variables are supported --- {{{
---   "${port}": nvim-dap resolves a free port.
---   "${file}": Active filename
---   "${fileBasename}": The current file's basename
---   "${fileBasenameNoExtension}": The current file's basename without extension
---   "${fileDirname}": The current file's dirname
---   "${fileExtname}": The current file's extension
---   "${relativeFile}": The current file relative to |getcwd()|
---   "${relativeFileDirname}": The current file's dirname relative to |getcwd()|
---   "${workspaceFolder}": The current working directory of Neovim
---   "${workspaceFolderBasename}": The name of the folder opened in Neovim
-- -- }}}
--- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#python
dap.adapters.python = function(callback, config)
  if config.request == "attach" then
    local port = (config.connect or config).port
    local host = (config.connect or config).host or "127.0.0.1"
    callback({
      type = "server",
      port = assert(port, "`connect.port` is required for a python `attach` configuration"),
      host = host,
      options = {
        source_filetype = "python",
      },
    })
  else
    --- python3 filepath 必须存在
    if not config.pythonPath then
      return
    end

    --- VVI: python3 必须和 debugpy 在同一个 '.venv/bin/' 中
    local debugpy_path = vim.fs.joinpath(vim.fs.dirname(config.pythonPath), "debugpy")
    if vim.fn.executable(debugpy_path) == 0 then
      Notify("'.venv/bin/debugpy' is missing or Not executable", vim.log.levels.ERROR)
      return
    end

    callback({
      type = "executable",
      command = config.pythonPath, -- VVI: python3 必须和 debugpy 在同一个 '.venv/bin/' 中
      args = { "-m", "debugpy.adapter" },
      options = {
        source_filetype = "python",
      },
    })
  end
end

dap.configurations.python = {
  {
    -- The first three options are required by nvim-dap
    name = "nvim-dap: Python debugpy file",
    type = "python", -- VVI: dap.adapters.python 名字要对应
    request = "launch",

    -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
    program = "${file}", -- This configuration will launch the current file if used.
    pythonPath = function()
      -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
      local py_paths = vim.fs.find({'.venv/bin/python3'}, {
        upward = true,
        path = vim.api.nvim_buf_get_name(0),
        stop = vim.env.HOME,
        type = "file",
      })
      if #py_paths < 1 then
        Notify({"'.venv/bin/python3' is missing"}, vim.log.levels.ERROR)
        return
      end
      return py_paths[1]
    end,
  },
}



