--- 主要是设置 lsp root_dir
return {
  root_dir = function(fname)
    local root = vim.fs.root(0, {'.venv', 'pyproject.toml', 'ruff.toml', '.ruff.toml'})
    if root then
      return root
    end

    -- Notify(
    --   {
    --     "'.venv' NOT found in current or any parent directory.",
    --     "Please run:",
    --     "  `python3.xx -m venv .venv` or `uv venv`",
    --     "  `source .venv/bin/activate`",
    --     "  `pip3 install debugpy` or `uv pip install debugpy`"
    --   },
    --   "WARN",
    --   {title={"LSP", "gopls.lua"}, timeout = false}
    -- )
    return vim.uv.cwd()
  end
}

