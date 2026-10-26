require("global.colors")  -- 有全局变量 "Colors", 很多 plugins 需要用到
require("global.nerd_icons")  -- nerd fonts icons
-- require("global.palettes") -- alt colors


---@class MyMasonTool
--
-- 在 mason.nvim 中的名字
---@field name string
--
-- 一个 tool 可能有多个可执行文件
---@field cmds string[]
--
-- tool 的 version
---@field version string
--
-- 在 lspconfig 中对应的名字.
-- 只有 lsp tools 有对应的 lspconfig 名字; linter, formatter 没有对应的 lspconfig 名字.
---@field lspconfig? string


Mason = {
  lock_file = vim.fs.joinpath(vim.fn.stdpath("config"), "mason-lock.json"),
  install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "mason_tools"),
}



