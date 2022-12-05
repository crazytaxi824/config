--- "lewis6991/impatient.nvim" settings --------------------------------------------------------------
--- DOC: https://github.com/lewis6991/impatient.nvim#configuration

local luacache_chunks = vim.fn.stdpath('cache')..'/luacache_chunks'
local luacache_modpaths = vim.fn.stdpath('cache')..'/luacache_modpaths'

--- 判断 luacache 文件是否存在.
if vim.fn.filereadable(luacache_chunks) == 1 and vim.fn.filereadable(luacache_modpaths) == 1 then
  --- VVI: This must be populated before require('impatient') is run.
  _G.__luacache_config = {     --- this is a Global var.
    chunks = {
      enable = true,
      path = luacache_chunks,
    },
    modpaths = {
      enable = true,
      path = luacache_modpaths,
    }
  }
end

--- VVI: it is recommended you add the following near the start of your init.vim.
local status_ok, impatient = pcall(require, "impatient")
if status_ok then
  impatient.enable_profile()  -- 打开 profiling, 如果不打开则没有 `:LuaCacheProfile` 命令
end



