--- "lewis6991/impatient.nvim" settings --------------------------------------------------------------
--- DOC: https://github.com/lewis6991/impatient.nvim#configuration

local luacache_chunks = vim.fn.stdpath('cache')..'/luacache_chunks'
local luacache_modpaths = vim.fn.stdpath('cache')..'/luacache_modpaths'

--- VVI: This must be populated before require('impatient') is run.
_G.__luacache_config = {
  chunks = {
    enable = true,
    path = luacache_chunks,
  },
  modpaths = {
    enable = true,
    path = luacache_modpaths,
  }
}

--- VVI: it is recommended you add the following near the start of your init.vim.
local status_ok, impatient = pcall(require, "impatient")
if status_ok then
  impatient.enable_profile()  -- 打开 profiling, 如果不打开则没有 `:LuaCacheProfile` 命令
end



