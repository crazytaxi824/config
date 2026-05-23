-- https://pyrefly.org/en/docs/

return {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, { 'pyproject.toml', 'pyrefly.toml' })
    if root then
      on_dir(root)
      return
    end

    --- fallback
    on_dir(vim.uv.cwd())

    Notify(
      {"pyrefly root dir NOT found"},
      "WARN",
      { title={"LSP", "pyrefly.lua"}, timeout=3 }
    )
  end,

  --- https://pyrefly.org/en/docs/configuration/
  --- pyrefly 不认 settings 设置, 必须在 pyproject.toml [tool.pyrefly] 或者 pyrefly.toml 中设置
}

