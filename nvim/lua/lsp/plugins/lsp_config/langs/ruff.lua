--- 主要是设置 lsp root_dir
return {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, {'pyproject.toml', 'ruff.toml', '.ruff.toml'})
    if root then
      on_dir(root)
      return
    end

    Notify(
      {"'pyproject.toml', 'ruff.toml', '.ruff.toml' NOT found"},
      "WARN",
      {title={"LSP", "ruff.lua"}, timeout = false}
    )
  end
}
