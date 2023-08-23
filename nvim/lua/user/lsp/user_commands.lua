--- LSP 常用功能函数
--- `:GetLspClientsInfo`   表示所有启动的 lsp
--- `:GetLspClientsInfo 0` 表示当前 buffer 的 attached lsp
vim.api.nvim_create_user_command("GetLspClientsInfo",
  function(params)
    --- opt 是 command 传入的 nargs 参数 --------------------------------------- {{{
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
    local bufnr = tonumber(params.args)
    local clients
    if bufnr then
      clients = vim.tbl_values(vim.lsp.get_active_clients({bufnr = bufnr}))
    else
      clients = vim.tbl_values(vim.lsp.get_active_clients())
    end

    vim.print(clients)
    -- for _, c in ipairs(clients) do
    --   print(c.name, c.supports_method('textDocument/documentHighlight'))
    -- end
  end,
  {bang=true, nargs="?"}  -- command options
)



