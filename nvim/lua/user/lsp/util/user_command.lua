--- LSP 常用功能函数 -------------------------------------------------------------------------------
vim.api.nvim_create_user_command("GetLspClientsInfo",
  function(opt)
    --- opt 是 command 传入的 nargs 参数 --- {{{
    -- {
    --   args = "0 1 2",
    --   bang = false,
    --   count = -1,
    --   fargs = { "0 1 2" },
    --   line1 = 1,
    --   line2 = 1,
    --   mods = "",
    --   range = 0,
    --   reg = ""
    -- }
    -- -- }}}
    local bufnr = tonumber(opt.args)
    if bufnr then
      print(vim.inspect(vim.tbl_values(vim.lsp.buf_get_clients(bufnr))))
    else
      print(vim.inspect(vim.tbl_values(vim.lsp.buf_get_clients())))
    end
  end,
  {bang=true, bar=true, nargs="?"}  -- command options
)

