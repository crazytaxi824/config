-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#sourcekit

return {
  -- `swift package init --type executable`, 会创建 Package.swift, Sources/, Tests/ 文件
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, 'Package.swift')
    if root then
      on_dir(root)
      return
    end

    Notify(
      {"'Package.swift' NOT found"},
      "WARN",
      {title={"LSP", "sourcekit.lua"}, timeout = false}
    )
  end,

  -- sudo xcode-select -s /Applications/Xcode.app/Contents/Developer  (XCode) has XCTest
  -- sudo xcode-select -s /Library/Developer/CommandLineTools  (CommandLineTools)
  -- 使用 XCode.app 中的 sourcekit-lsp 时需要设置环境变量, 如果使用 CommandLineTools 可以直接注释掉.
  cmd_env = {
    DEVELOPER_DIR = "/Applications/Xcode.app/Contents/Developer"
  },
}
