local util = require("null-ls.utils")

--- NOTE: 执行 golangci-lint 的 pwd. 默认是 params.root 即: null_ls.setup() 中的 root_dir / $ROOT
--- 这里的逻辑是参考 lspconfig/langs/gopls.lua 中 root_dir 的逻辑.
--- params 回调参数 --- {{{
--   content,    -- current buffer content (table, split at newline)
--   lsp_method, -- lsp method that triggered request (string)
--   method,  -- null-ls method that triggered generator (string)
--   row,     -- cursor's current row (number, zero-indexed)
--   col,     -- cursor's current column (number)
--   bufnr,   -- current buffer's number (number)
--   bufname, -- current buffer's full path (string)
--   ft,   -- current buffer's filetype (string)
--   root, -- current buffer's root directory (string)
-- -- }}}
local function pwd_root(params)
  return util.root_pattern('go.work')(params.bufname) or
      util.root_pattern('go.mod','.git')(params.bufname) or
      params.root
end

return {
  --command = "path/to/golangci-lint",

  --- VVI: 执行 golangci-lint 的 pwd. 默认是 params.root 即: null_ls.setup() 中的 root_dir / $ROOT
  cwd = pwd_root,

  ---  可以通过设置 setup() 中的 debug = true, 打开 `:NullLsLog` 查看命令行默认参数.
  args = function(params)
    --- VVI: 这里必须要使用 $DIRNAME.
    ---  如果使用 $FILENAME 意思是 lint 单个文件. 别的文件中定义的 var 无法被 golangci 找到.
    ---  如果缺省设置, 即不设置 $FILENAME 也不设置 $DIRNAME, 则每次 golangci 都会 lint 整个 project.
    return { "run", "--fix=false", "--fast", "--out-format=json", "$DIRNAME", "--path-prefix", pwd_root(params) }
  end,

  --- golangci-lint 配置文件位置自动查找 --- {{{
  --- golangci-lint 会自动寻找 '.golangci.yml', '.golangci.yaml', '.golangci.toml', '.golangci.json'.
  --- GolangCI-Lint also searches for config files in all directories from the directory of the first analyzed path up to the root.
  --- https://golangci-lint.run/usage/configuration/#linters-configuration
  -- -- }}}
  --extra_args = { '--config', ".golangci.yml"},  -- NOTE: 相对上面 cwd 的路径, 也可以使用绝对地址.

  --filetypes = { "go" },  -- 只对 go 文件生效.
}
