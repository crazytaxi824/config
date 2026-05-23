-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#basedpyright

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
      {"basedpyright root dir NOT found"},
      "WARN",
      { title={"LSP", "basedpyright.lua"}, timeout=3 }
    )
  end,

  -- https://docs.basedpyright.com/latest/configuration/language-server-settings/
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "standard",   -- "off", "basic", "standard", "strict", "recommended"(*), "all"
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
      }
    },
    -- python = {
    --   pythonPath = ...  -- 自动寻找
    -- },
  },
}
