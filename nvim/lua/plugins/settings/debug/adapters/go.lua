--- `:help dap-adapter`
local dap_status_ok, dap = pcall(require, "dap")
if not dap_status_ok then
  return
end

--- cache golang vscode extension filepath
--- @type string|nil filepath
local cache_vscode_debug_path

--- NOTE: Debug adapters & configurations settings
--- https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go
--- 插件 https://github.com/golang/vscode-go
--- 使用 vscode 插件运行 debug, vscode extension 位置 "~/.vscode/extensions/golang.go-0.46.1/dist/debugAdapter.js"
---
--- @return string[] filepath
local function find_vscode_extension()
  local vscode_debug_path = vim.fs.find(function (name, path)
    return name == 'debugAdapter.js' and path:match('~/%.vscode/extensions/golang.*/dist')
  end, {
    path = "~/.vscode/extensions",
    limit = math.huge, -- NOTE: no limit
    type = "file",
  })

  return vscode_debug_path
end

dap.adapters.go = function(callback, config)
  if not cache_vscode_debug_path then
    print("ok")
    local vscode_debug_path = find_vscode_extension()
    if #vscode_debug_path < 1 then
      Notify("vscode extension 'golang' is missing")
      return
    end

    local release_ver = vscode_debug_path[1]  -- stable version
    local pre_release_ver = vscode_debug_path[#vscode_debug_path]  -- latest version

    cache_vscode_debug_path = pre_release_ver
  end

  callback({
    type = "executable",
    command = "node",
    args = { cache_vscode_debug_path },
    options = {
      source_filetype = "go",
    },
  })
end

--- 直接使用 delve 工具对 go test 进行 debug
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
      type = 'server',
      port = '${port}',
      executable = {
        command = 'dlv',
        args = { 'dap', '-l', '127.0.0.1:${port}', '--log', '--log-output=dap' },
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
    name = "nvim-dap(vscode): Go Debug",
    type = "go", -- VVI: dap.adapters.go 名字要对应
    request = "launch",
    showLog = false,
    program = "${file}",
    dlvToolPath = vim.fn.exepath("dlv"), -- Adjust to where delve is installed
  },

  -- dlv test packages
  {
    name = "nvim-dap(delve): Go Debug test (pkg)",
    type = "delve", -- VVI: dap.adapters.delve 名字要对应
    request = "launch",
    mode = "test",
    program = "./${relativeFileDirname}",
  },
}



