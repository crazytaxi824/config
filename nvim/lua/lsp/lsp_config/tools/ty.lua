-- https://docs.astral.sh/ty/

return {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, { 'pyproject.toml', 'ty.toml' })
    if root then
      on_dir(root)
      return
    end

    Notify(
      {"'pyproject.toml' NOT found"},
      "WARN",
      {title={"LSP", "basedpyright.lua"}, timeout = false}
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
