--- 主要是设置 lsp root_dir
return {
  root_dir = function(fname)
    local root = vim.fs.root(0, {'pyproject.toml', 'ruff.toml', '.ruff.toml'})
    if root then
      return root
    end

    return vim.uv.cwd()
  end
}

