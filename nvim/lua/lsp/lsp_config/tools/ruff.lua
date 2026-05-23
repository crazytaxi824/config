-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#ruff

--- 修改 lspconfig 中默认 root_dir 设置
return {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, {'pyproject.toml', 'ruff.toml', '.ruff.toml'})
    if root then
      on_dir(root)
      return
    end

    --- fallback
    on_dir(vim.uv.cwd())

    Notify(
      {"ruff root dir NOT found"},
      "WARN",
      { title={"LSP", "ruff.lua"}, timeout=3 }
    )
  end
}
