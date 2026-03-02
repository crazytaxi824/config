--- `:help dap-adapter`
local dap_status_ok, dap = pcall(require, "dap")
if not dap_status_ok then
  return
end

local utils = require("utils.go.deps.utils")

--- cache golang vscode extension filepath
---
--- @type string|nil
local cache_vscode_debug_path

--- NOTE: Debug adapters & configurations settings
--- https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#go
--- 插件 https://github.com/golang/vscode-go
--- 使用 vscode 插件运行 debug, vscode extension 位置 "~/.vscode/extensions/golang.go-0.46.1/dist/debugAdapter.js"
---
--- @return string[] filepath
local function find_vscode_extension()
  return vim.fs.find(function (name, path)
    return name == 'debugAdapter.js' and path:match('~/%.vscode/extensions/golang.*/dist')
  end, {
    path = "~/.vscode/extensions",
    limit = math.huge, -- NOTE: no limit
    type = "file",
  })
end


dap.adapters.go = function(callback, config)
  if not cache_vscode_debug_path then
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


--- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
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
dap.configurations.go = {
  --- vscode-go test project
  {
    name = "nvim-dap(vscode): Go Debug",
    type = "go", -- VVI: dap.adapters.go 名字要对应
    request = "launch",
    showLog = false,
    dlvToolPath = vim.fn.exepath("dlv"), -- Adjust to where delve is installed

    program = "${file}",
  },

  --- test function
  {
    name = "nvim-dap(vscode): Go Debug test (func)",
    type = "go",
    request = "launch",
    mode = "test",
    showLog = true,
    dlvToolPath = vim.fn.exepath("dlv"), -- Adjust to where delve is installed
    program = "${fileDirname}",

    args = function()
      --- 判断当前函数是否 TestXXX. 如果是, 则获取 test function name.
      local testfn_name, mode = utils.get_exact_testfn_name()
      if not testfn_name or not mode then
        return { "-test.v", "-test.run", "^" .. vim.fn.expand('<cword>') .. "$" }
      end

      if mode == 'run' then
        return { "-test.v", "-test.run", "^" .. testfn_name .. "$" }
      elseif mode == 'bench' then
        return {
          "-test.v",
          "-test.run", "^$",
          "-test.bench", "^" .. testfn_name .. "$",
          "-test.benchmem"
        }
      elseif mode == 'fuzz' then
        local fp = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
        local testdata = vim.fs.joinpath(fp, "testdata", "fuzz")
        --- debug fuzz 函数时, 只运行 Seed Corpus (f.Add 的数据) 和 testdata 里的失败案例.
        --- 所以需要给 -run, -fuzz 都设置函数名.
        return {
          "-test.v",
          "-test.run", "^$",
          "-test.fuzz", "^" .. testfn_name .. "$",
          "-test.fuzzcachedir", testdata,  -- fuzzing input data
          "-test.fuzztime", "15s",
        }
      else
        error("mode is not 'run'|'bench'|'fuzz'")
      end
    end
  },

  --- test run packages
  {
    name = "nvim-dap(vscode): Go Debug test run (pkg)",
    type = "go",
    request = "launch",
    mode = "test",
    showLog = false,
    dlvToolPath = vim.fn.exepath("dlv"), -- Adjust to where delve is installed

    program = "${fileDirname}",
  },
}


