--- "lewis6991/impatient.nvim" settings --------------------------------------------------------------
--- VVI: This must be populated before require('impatient') is run.
_G.__luacache_config = {     --- this is a Global var.
  chunks = {
    enable = true,
    path = vim.fn.stdpath('cache')..'/luacache_chunks',
  },
  modpaths = {
    enable = true,
    path = vim.fn.stdpath('cache')..'/luacache_modpaths',
  }
}

--- VVI: it is recommended you add the following near the start of your init.vim.
local status_ok, impatient = pcall(require, "impatient")
if status_ok then
  impatient.enable_profile()  -- 打开 profiling, 如果不打开则没有 `:LuaCacheProfile` 命令
end
