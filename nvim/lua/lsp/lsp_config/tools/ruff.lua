-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#ruff

---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, {'pyproject.toml', 'ruff.toml', '.ruff.toml'})
    if root then
      on_dir(root)
      return
    end

    -- fallback
    on_dir(vim.uv.cwd())

    Notify(
      {"ruff root dir NOT found"},
      "WARN",
      { title={"LSP", "ruff.lua"}, timeout=3 }
    )
  end,

  -- https://docs.astral.sh/ruff/editors/setup/#neovim
  -- https://docs.astral.sh/ruff/editors/settings/#configuration
  -- NOTE: 必须放在 init_options 中
  init_options = {
    settings = {
      -- https://docs.astral.sh/ruff/configuration/
      -- 以下设置也可以放在 pyproject.toml [tool.ruff] 中
      configuration = {
        ["line-length"] = 79,
        lint = {
          -- https://docs.astral.sh/ruff/rules/#rules
          ["extend-select"] = {"E501"},  -- add "line too long"
        },
      },
    },
  },
}
