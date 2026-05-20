-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#yamlls

return {
  settings = {
    yaml = {
      format = { enable = true },    -- 开启 auto format
      validate = { enable = true },  -- 开启 diagnostic, 默认不开启.
    },
  }
}

