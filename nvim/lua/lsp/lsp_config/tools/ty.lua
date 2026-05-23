-- https://docs.astral.sh/ty/

return {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, { 'pyproject.toml', 'ty.toml' })
    if root then
      on_dir(root)
      return
    end

    --- fallback
    on_dir(vim.uv.cwd())

    Notify(
      {"ty root dir NOT found"},
      "WARN",
      { title={"LSP", "ty.lua"}, timeout=3 }
    )
  end,

  -- https://docs.astral.sh/ty/reference/configuration/
  settings = {
    ty = {
      configuration = {
        -- https://docs.astral.sh/ty/reference/configuration/#rules
        rules = {
          ["unresolved-reference"] = "warn",
        },
        -- https://docs.astral.sh/ty/reference/configuration/#analysis
        analysis = {
          -- # Disable support for `type: ignore` comments
          ["respect-type-ignore-comments"] = false
        },
        -- environment = {
        --   python = ".venv"  -- 自动查找
        -- },
      },
    },
  },
}
