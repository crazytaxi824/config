return {
  --command = "path/to/golangci-lint",

  --- VVI: 执行 golangci-lint 的 pwd. 默认是 params.root 即: null_ls.setup() 中的 root_dir / $ROOT
  --- params 回调参数 --- {{{
  --- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/MAIN.md#generators
  --    content,    -- current buffer content (table, split at newline)
  --    lsp_method, -- lsp method that triggered request (string)
  --    method,  -- null-ls method that triggered generator (string)
  --    row,     -- cursor's current row (number, zero-indexed)
  --    col,     -- cursor's current column (number)
  --    bufnr,   -- current buffer's number (number)
  --    bufname, -- current buffer's full path (string)
  --    ft,   -- current buffer's filetype (string)
  --    root, -- current buffer's root directory (string)
  -- -- }}}
  cwd = function(params)
    --- current buffer's dir, 相当于下面的 $DIRNAME.
    return vim.fn.fnamemodify(params.bufname, ":h")
  end,

  ---  可以通过设置 setup() 中的 debug = true, 打开 `:NullLsLog` 查看命令行默认参数.
  args = function(params)
    local golangci_args = {
      "run", "--fix=false", "--fast",

      --- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/HELPERS.md#args
      --- 不能使用 $FILENAME lint 单个文件. 会导致其他 package 中定义的 var 无法被 golangci 找到.
      --- 如果缺省设置, 相当于 $DIRNAME.
      -- "$DIRNAME",

      --- Path prefix to add to output.
      --- VVI: 必须要, 否则找不到文件. 默认是 pwd,
      --- 需要改为 cwd 执行时的 path.
      "--path-prefix", "$DIRNAME",

      "--print-issued-lines=false",
      "--out-format=json",
      "--issues-exit-code=0",
    }

    --- DEBUG: 用
    if __Debug_Neovim.null_ls then
      Notify('golangci-lint ' .. table.concat(golangci_args, " "), "DEBUG", {title="Null-ls"})
    end

    return golangci_args
  end,

  --- golangci-lint 配置文件位置自动查找 --- {{{
  --- golangci-lint 会自动寻找 '.golangci.yml', '.golangci.yaml', '.golangci.toml', '.golangci.json'.
  --- GolangCI-Lint also searches for config files in all directories from the directory of
  --- the first analyzed path up to the root.
  --- https://golangci-lint.run/usage/configuration/#linters-configuration
  -- -- }}}
  --extra_args = { '--config', vim.fn.getcwd() .. "/.golangci.yml"},  -- NOTE: 相对上面 cwd 的路径, 也可以使用绝对路径.

  --filetypes = { "go" },  -- 只对 go 文件生效.
}
