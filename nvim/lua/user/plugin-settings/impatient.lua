--- "lewis6991/impatient.nvim" settings --------------------------------------------------------------
--- NOTE: this is a Global var.
_G.__luacache_config = {
  chunks = {
    enable = true,
    path = vim.fn.stdpath('cache')..'/luacache_chunks',
  },
  modpaths = {
    enable = true,
    path = vim.fn.stdpath('cache')..'/luacache_modpaths',
  }
}

--- NOTE: 启动 impatient
--require('impatient').enable_profile()
local status_ok, impatient = pcall(require, "impatient")
if status_ok then
  impatient.enable_profile()  -- 打开 profiling, 如果不打开则没有 `:LuaCacheProfile` 命令
end
