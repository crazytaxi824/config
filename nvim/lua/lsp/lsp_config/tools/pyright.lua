--- 修改 lspconfig 中默认 root_dir 设置
return {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, 'pyproject.toml')
    if root then
      on_dir(root)
      return
    end

    Notify(
      {"'pyproject.toml' NOT found"},
      "WARN",
      {title={"LSP", "ruff.lua"}, timeout = false}
    )
  end
}
