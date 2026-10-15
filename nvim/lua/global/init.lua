require("global.colors")  -- 有全局变量 "Colors", 很多 plugins 需要用到
require("global.nerd_icons")  -- nerd fonts icons
-- require("global.palettes") -- alt colors

Mason = {
  lock_file = vim.fs.joinpath(vim.fn.stdpath("config"), "mason-lock.json"),
  install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "mason_tools"),
}



