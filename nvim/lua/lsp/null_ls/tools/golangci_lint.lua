--- 在 null-ls 中设置 golangci-lint
--- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/HELPERS.md

return {
  --command = "path/to/golangci-lint",

  ---  可以通过设置 setup() 中的 debug = true, 打开 `:NullLsLog` 查看命令行默认参数.
  args = function(params)
    local golangci_args = {
      "run", "--fast-only", "--fix=false",
      "--output.json.path=stdout",
      "--show-stats=false",  -- 不显示最后的 (N) issues.

      --- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/HELPERS.md#args
      --- NOTE: 不能使用 $FILENAME lint 单个文件. 会导致其他 package 中定义的 var 无法被 golangci 找到.
      --- 如果缺省该设置则会 lint 整个 project.
      "$DIRNAME",

      --- Path prefix to add to output.
      --- VVI: 默认情况下运行 golangci-lint run 时 output 中 filename 是一个相对 pwd/cwd 的相对文件路径.
      --- null-ls 中已经处理了 cwd 和 golangci-lint output 中 filename 的 filepath 拼接, 所以这里不要自己设置 --path-prefix.
      -- "--path-prefix", "$DIRNAME",
    }

    return golangci_args
  end,

  --- golangci-lint 配置文件位置自动查找 --------------------------------------- {{{
  --- DOCS: https://golangci-lint.run/usage/configuration/#linters-configuration
  --- golangci-lint 会自动寻找 '.golangci.yml', '.golangci.yaml', '.golangci.toml', '.golangci.json'.
  --- GolangCI-Lint also searches for config files in all directories from the directory of
  --- the first analyzed path up to the root.
  -- -- }}}
  --extra_args = { '--config', vim.uv.cwd() .. "/.golangci.yml"},  -- NOTE: 相对上面 cwd 的路径, 也可以使用绝对路径.

  --filetypes = { "go" },  -- 只对 go 文件生效.
}
