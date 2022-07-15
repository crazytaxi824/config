--- Debug plugins lazy load ------------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"go"},  --- NOTE: 目前只对 go 使用 debug
  callback = function()
    --- set command :Debug
    vim.api.nvim_buf_create_user_command(0, 'Debug',
      function()
        --- load nvim-api-ui (requires nvim-dap)
        require('packer').loader('nvim-dap-ui')  -- VVI: 相当于 ':PackerLoad nvim-dap-ui'

        local dap_status_ok, dap = pcall(require, 'dap')
        if dap_status_ok then
          --- 如果 dap 已经运行, 则不进行任何操作.
          if not dap.session() then
            dap.continue() -- start debug
          end
        end
      end,
      {bang=true, bar=true}
    )

    --- keymap <F9> to dap.toggle_breakpoint()
    vim.api.nvim_buf_set_keymap(0, 'n', '<F9>', '',
      {
        noremap=true,
        callback = function()
          --- load nvim-api-ui (requires nvim-dap)
          require('packer').loader('nvim-dap-ui')  -- VVI: 相当于 ':PackerLoad nvim-dap-ui'

          --- toggle breakpoint
          local dap_status_ok, dap = pcall(require, 'dap')
          if dap_status_ok then
            dap.toggle_breakpoint()
          end
        end,
      }
    )

    --- which-key <F9> toggle_breakpoint
    local wk_status_ok, wk = pcall(require, "which-key")
    if wk_status_ok then
      wk.register({['<leader>c<F9>'] = {"Debug - Toggle Breakpoint"}}, {mode="n", buffer=0})
    end

  end,
})



