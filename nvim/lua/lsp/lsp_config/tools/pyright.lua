-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#pyright

--- 修改 lspconfig 中默认 root_dir 设置
return {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, 'pyproject.toml')
    if root then
      on_dir(root)
      return
    end

    --- fallback
    on_dir(vim.uv.cwd())

    Notify(
      {"pyright root dir NOT found"},
      "WARN",
      { title={"LSP", "pyright.lua"}, timeout=3 }
    )
  end,

  --- NOTE: 这里的设置和 pyproject.toml 中的 [tool.pyright] venvPath & venv 设置只要有一个成功 pyright 就可以正常工作
  --- 自动探测 python venv 环境
  on_init = function(client)
    local workspace = client.config.root_dir
    if workspace then
      --- .venv 在项目根目录
      local venv_python = vim.fs.joinpath(workspace, ".venv/bin/python3")
      if vim.fn.executable(venv_python) == 1 then
        client.config.settings.python.pythonPath = venv_python
      end
    else
      --- 向上查找 .venv
      local py_paths = vim.fs.find({'.venv/bin/python3'}, {
        upward = true,
        stop = vim.env.HOME,
        type = "file",
        limit = 1,
      })
      if #py_paths < 1 then
        return
      end
      client.config.settings.python.pythonPath = py_paths[1]
    end
  end,

  --- https://github.com/microsoft/pyright/blob/main/docs/settings.md
  settings = {
    python = {
      --- NOTE: pythonPath & venvPath 不会自动寻找, 所以在 on_init() 中设置
      -- pythonPath =
      -- venvPath =
      analysis = {
        typeCheckingMode = "standard",   -- "off", "basic", "standard", "strict"
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
      },
    },
  },
}
