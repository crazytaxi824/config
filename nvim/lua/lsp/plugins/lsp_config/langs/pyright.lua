--- 主要是设置 lsp root_dir
return {
  root_dir = function(fname)
    local root = vim.fs.root(0, '.venv')
    if root then
      --- 如果找到 root 则返回 root
      return root
    end

    Notify(
      {
        "'.venv' NOT found in current or any parent directory.",
        "Please run:",
        "  'python3 -m venv .venv'",
        "  'pip3 install -U debugpy'"
      },
      "WARN",
      {title={"LSP", "gopls.lua"}, timeout = false}
    )
    return vim.uv.cwd()
  end
}
