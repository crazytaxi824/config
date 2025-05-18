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
--- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go
--- 使用 vscode 插件运行 debug, vscode extension 位置 "~/.vscode/extensions/golang.go-0.46.1/dist/debugAdapter.js"
local vscode_debug_path = vim.fs.find({ "debugAdapter.js" }, { type = "file", path = "~/.vscode/extensions" })
local pattern = vim.fs.joinpath(vim.env.HOME, "%.vscode/extensions/golang.*/dist/debugAdapter%.js")
if #vscode_debug_path > 0 and string.match(vscode_debug_path[1], pattern) then
  dap.adapters.go = function(callback, config)
    callback({
      type = "executable",
      command = "node",
      args = { vscode_debug_path[1] },
      options = {
        source_filetype = "go",
      },
    })
  end
end

--- 直接使用 delve 工具对 go test 进行 debug
dap.adapters.delve = function(callback, config)
  if config.mode == "remote" and config.request == "attach" then
    callback({
      type = "server",
      host = config.host or "127.0.0.1",
      port = config.port or "38697",
      options = {
        source_filetype = "go",
      },
    })
  else
    callback({
      type = "server",
      port = "${port}",
      executable = {
        command = "dlv",
        args = { "dap", "-l", "127.0.0.1:${port}", "--log", "--log-output=dap" },
        detached = vim.fn.has("win32") == 0,
      },
      options = {
        source_filetype = "go",
      },
    })
  end
end

-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
  -- vscode-go test project
  {
    name = "nvim-dap: Go Debug",
    type = "go", -- VVI: dap.adapters.go 名字要对应
    request = "launch",
    showLog = false,
    program = "${file}",
    dlvToolPath = vim.fn.exepath("dlv"), -- Adjust to where delve is installed
  },

  -- dlv test packages
  {
    name = "nvim-dap: Go Debug test (pkg)",
    type = "delve", -- VVI: dap.adapters.delve 名字要对应
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}",
  },
}



